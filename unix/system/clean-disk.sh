#!/usr/bin/env bash
# Reclaim disk space by clearing caches and stale build artifacts.
#
# Works on Linux (apt/pacman/dnf/nix) and macOS (Homebrew).
# Everything here is regenerable: caches get rebuilt on next use. The one
# exception is --trash, which permanently deletes, so it is opt-in.
#
# Usage:
#   ./clean-disk.sh [--dry-run] [--trash] [--containers]

set -e

# Source common functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../lib/common.sh
source "${SCRIPT_DIR}/../lib/common.sh"

CLEAN_TRASH=false
CLEAN_CONTAINERS=false

parse_clean_args() {
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --dry-run)    DRY_RUN=true ;;
            --trash)      CLEAN_TRASH=true ;;
            --containers) CLEAN_CONTAINERS=true ;;
            --log)        ;; # consumed by setup.sh, ignore here
            *)
                print_error "Unknown option: $1"
                echo "Usage: $0 [--dry-run] [--trash] [--containers]"
                exit 1
                ;;
        esac
        shift
    done
}

# --- system package manager caches -----------------------------------------

clean_system_packages() {
    local pm
    pm=$(detect_package_manager)

    case "$pm" in
        brew)
            print_info "Cleaning Homebrew..."
            # --prune=all drops every cached download, not just outdated ones.
            run_cmd brew cleanup --prune=all -s || print_warning "brew cleanup reported errors"
            run_cmd brew autoremove || print_warning "brew autoremove reported errors"

            # brew cleanup can leave downloads behind; clear the cache dir too.
            local brew_cache
            brew_cache=$(brew --cache 2>/dev/null || true)
            if [[ -n "$brew_cache" && -d "$brew_cache" ]]; then
                purge_dir_contents "$brew_cache" "Homebrew download cache"
            fi
            ;;
        apt)
            print_info "Cleaning apt cache..."
            if have_sudo; then
                run_cmd sudo apt autoclean
                run_cmd sudo apt autoremove -y
                run_cmd sudo apt update
            else
                print_warning "No sudo access, skipping apt cleanup"
            fi
            ;;
        pacman)
            print_info "Cleaning pacman cache..."
            if have_sudo; then
                run_cmd sudo pacman -Scc --noconfirm
            else
                print_warning "No sudo access, skipping pacman cleanup"
            fi
            ;;
        dnf)
            print_info "Cleaning dnf cache..."
            if have_sudo; then
                run_cmd sudo dnf clean all
                run_cmd sudo dnf autoremove -y
            else
                print_warning "No sudo access, skipping dnf cleanup"
            fi
            ;;
        nix)
            print_info "Cleaning nix store (user)..."
            run_cmd nix-collect-garbage -d
            if have_sudo; then
                print_info "Cleaning nix store (system)..."
                run_cmd sudo nix-collect-garbage -d
            else
                print_warning "No sudo access, skipping system nix store"
            fi
            ;;
        *)
            print_warning "Unknown package manager, skipping package cache cleanup"
            ;;
    esac
}

# --- language / dev tool caches --------------------------------------------

# conda is usually a shell function, so command_exists misses it in a script.
find_conda() {
    if command_exists conda; then
        echo "conda"
        return 0
    fi

    local candidate
    for candidate in "$HOME/miniconda3/bin/conda" "$HOME/anaconda3/bin/conda" \
                     "$HOME/miniforge3/bin/conda" \
                     /opt/homebrew/Caskroom/miniconda/base/bin/conda; do
        if [[ -x "$candidate" ]]; then
            echo "$candidate"
            return 0
        fi
    done

    return 1
}

clean_language_package_managers() {
    print_info "Cleaning language package manager caches..."

    local conda_bin
    if conda_bin=$(find_conda); then
        print_info "Cleaning conda cache..."
        run_cmd "$conda_bin" clean --all -y || print_warning "conda clean reported errors"
    fi

    # uv's cache is frequently the largest single consumer on a dev machine.
    if command_exists uv; then
        print_info "Cleaning uv cache..."
        run_cmd uv cache clean --force || print_warning "uv cache clean reported errors"
    fi

    if command_exists pip3; then
        print_info "Cleaning pip cache..."
        run_cmd pip3 cache purge || print_warning "pip cache purge reported errors"
    elif command_exists pip; then
        print_info "Cleaning pip cache..."
        run_cmd pip cache purge || print_warning "pip cache purge reported errors"
    fi

    if command_exists npm; then
        print_info "Cleaning npm cache..."
        run_cmd npm cache clean --force || print_warning "npm cache clean reported errors"
    fi

    if command_exists pnpm; then
        print_info "Pruning pnpm store..."
        run_cmd pnpm store prune || print_warning "pnpm store prune reported errors"
    fi

    if command_exists yarn; then
        print_info "Cleaning yarn cache..."
        run_cmd yarn cache clean || print_warning "yarn cache clean reported errors"
    fi

    if command_exists cargo; then
        print_info "Cleaning cargo cache..."
        purge_path "${CARGO_HOME:-$HOME/.cargo}/registry/cache" "cargo registry cache"
        purge_path "${CARGO_HOME:-$HOME/.cargo}/git/db" "cargo git db"
    fi

    if command_exists go; then
        print_info "Cleaning go module cache..."
        run_cmd go clean -modcache || print_warning "go clean reported errors"
    fi

    if command_exists mise; then
        print_info "Pruning mise cache..."
        purge_dir_contents "${MISE_CACHE_DIR:-$HOME/.cache/mise}" "mise cache"
    fi
}

# --- container images -------------------------------------------------------

clean_containers() {
    [[ "$CLEAN_CONTAINERS" == "true" ]] || return 0

    local engine
    for engine in docker podman; do
        if command_exists "$engine"; then
            # Dangling images only: running/stopped containers are left intact.
            print_info "Pruning dangling $engine images..."
            run_cmd "$engine" image prune -f || print_warning "$engine image prune reported errors"
        fi
    done
}

# --- trash (destructive, opt-in) -------------------------------------------

clean_trash() {
    [[ "$CLEAN_TRASH" == "true" ]] || return 0

    print_warning "Emptying trash — this permanently deletes its contents"

    if is_macos; then
        purge_dir_contents "$HOME/.Trash" "Trash"
    else
        purge_dir_contents "$HOME/.local/share/Trash/files" "Trash files"
        purge_dir_contents "$HOME/.local/share/Trash/info" "Trash metadata"
    fi
}

# --- macOS specific ---------------------------------------------------------

# ~/Library/Caches entries already handled by a dedicated tool above, so we
# neither delete them twice nor double-count the reclaimed bytes.
cache_already_handled() {
    case "$1" in
        Homebrew|pip|uv|go-build|mise) return 0 ;;
        *) return 1 ;;
    esac
}

# Process to look for before clearing a given cache directory. Clearing a
# browser or player cache while it runs mostly works, but can confuse the app.
cache_owner_process() {
    case "$1" in
        com.spotify.client)          echo "Spotify" ;;
        BraveSoftware|com.brave.*)   echo "Brave Browser" ;;
        Google|com.google.Chrome)    echo "Google Chrome" ;;
        Comet|com.perplexity.comet)  echo "Comet" ;;
        com.openai.atlas)            echo "Atlas" ;;
        Mozilla|Firefox)             echo "firefox" ;;
        com.microsoft.VSCode)        echo "Visual Studio Code" ;;
        *)                           echo "" ;;
    esac
}

clean_macos_app_caches() {
    local cache_root="$HOME/Library/Caches"
    [[ -d "$cache_root" ]] || return 0

    print_info "Cleaning application caches in ~/Library/Caches..."
    reset_quiet_tally

    local entry name owner
    for entry in "$cache_root"/*; do
        [[ -e "$entry" ]] || continue
        name=$(basename "$entry")

        if cache_already_handled "$name"; then
            continue
        fi

        owner=$(cache_owner_process "$name")
        if [[ -n "$owner" ]] && app_running "$owner"; then
            print_warning "Skipping $name — $owner is running"
            continue
        fi

        # shellcheck disable=SC2088 # a display label, not a path to expand
        purge_path "$entry" "~/Library/Caches/$name"
    done

    report_quiet_tally "smaller app caches"
}

clean_macos_developer() {
    print_info "Cleaning developer caches..."

    # All rebuilt on next build. Xcode Archives are deliberately left alone:
    # those are shipped artifacts, not cache.
    purge_dir_contents "$HOME/Library/Developer/Xcode/DerivedData" "Xcode DerivedData"
    purge_dir_contents "$HOME/Library/Developer/Xcode/iOS DeviceSupport" "Xcode iOS DeviceSupport"
    purge_dir_contents "$HOME/Library/Developer/Xcode/watchOS DeviceSupport" "Xcode watchOS DeviceSupport"
    purge_dir_contents "$HOME/Library/Developer/CoreSimulator/Caches" "CoreSimulator caches"

    if command_exists xcrun && xcrun simctl help >/dev/null 2>&1; then
        print_info "Deleting unavailable simulator runtimes..."
        run_cmd xcrun simctl delete unavailable || print_warning "simctl delete reported errors"
    fi
}

clean_macos_logs() {
    local log_root="$HOME/Library/Logs"
    [[ -d "$log_root" ]] || return 0

    print_info "Removing user logs older than 7 days..."

    if [[ "$DRY_RUN" == "true" ]]; then
        local count
        count=$(find "$log_root" -type f -mtime +7 2>/dev/null | wc -l | tr -d ' ')
        print_info "[DRY RUN] Would remove $count log file(s) from ~/Library/Logs"
        return 0
    fi

    find "$log_root" -type f -mtime +7 -delete 2>/dev/null || true
    print_info "Old user logs removed"
}

# Time Machine keeps local APFS snapshots that can hold tens of GB hostage.
clean_macos_snapshots() {
    command_exists tmutil || return 0

    local snapshots
    snapshots=$(tmutil listlocalsnapshots / 2>/dev/null | grep -c 'com.apple.TimeMachine' || true)
    if [[ -z "$snapshots" || "$snapshots" -eq 0 ]]; then
        return 0
    fi

    print_info "Found $snapshots local Time Machine snapshot(s)"

    if ! have_sudo; then
        print_warning "No sudo access, skipping local snapshot thinning"
        return 0
    fi

    # Ask APFS to reclaim up to 20GB, urgency 4 (most aggressive).
    run_cmd sudo tmutil thinlocalsnapshots / 21474836480 4 \
        || print_warning "Snapshot thinning reported errors"
}

clean_macos() {
    clean_macos_app_caches
    clean_macos_developer
    clean_macos_logs
    clean_macos_snapshots
}

# --- linux specific ---------------------------------------------------------

clean_linux() {
    print_info "Cleaning journal logs (keeping last 7 days)..."
    if ! command_exists journalctl; then
        print_info "journalctl not present, skipping journal cleanup"
    elif have_sudo; then
        run_cmd sudo journalctl --vacuum-time=7d
    else
        print_warning "No sudo access, skipping journal cleanup"
    fi
}

# --- entry point ------------------------------------------------------------

clean_disk() {
    local before after
    before=$(free_space_kb)

    print_info "Cleaning disk space on $OS_FAMILY..."
    if [[ "$DRY_RUN" == "true" ]]; then
        print_warning "DRY RUN MODE: nothing will be deleted"
    fi
    print_info "Free space before: $(human_kb "$before")"

    # Tool-managed cleanup first: each tool knows which of its own files are
    # still needed. The broad sweeps afterwards only mop up what is left.
    clean_system_packages
    clean_language_package_managers

    # The XDG cache dir exists on macOS too (uv, mise, and friends use it).
    # shellcheck disable=SC2088 # a display label, not a path to expand
    purge_dir_contents "${XDG_CACHE_HOME:-$HOME/.cache}" "~/.cache"

    if is_macos; then
        clean_macos
    elif is_linux; then
        clean_linux
    fi

    clean_containers
    clean_trash

    after=$(free_space_kb)

    echo ""
    print_success "Disk cleanup complete"
    print_info "Removed from tracked paths: $(human_kb "$RECLAIMED_KB")"

    if [[ "$DRY_RUN" != "true" ]]; then
        print_info "Free space after:  $(human_kb "$after")"
        # Deletions done by package managers are not counted in RECLAIMED_KB,
        # so report the volume-level delta as the authoritative number.
        if [[ "$after" -gt "$before" ]]; then
            print_success "Net space reclaimed: $(human_kb "$(( after - before ))")"
        fi
    fi

    if [[ "$CLEAN_TRASH" != "true" ]]; then
        print_info "Trash was left alone. Pass --trash to empty it as well."
    fi
}

# Run if not sourced
if ! is_sourced; then
    parse_clean_args "$@"
    clean_disk
fi
