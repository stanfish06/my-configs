#!/usr/bin/env bash
# Clean up disk space by removing caches and old packages

set -e

# Source common functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../lib/common.sh
source "${SCRIPT_DIR}/../lib/common.sh"

clean_system_packages() {
    local pm
    pm=$(detect_package_manager)

    case "$pm" in
        apt)
            print_info "Cleaning apt cache..."
            sudo apt autoclean
            sudo apt autoremove -y
            sudo apt update
            ;;
        pacman)
            print_info "Cleaning pacman cache..."
            sudo pacman -Scc --noconfirm
            ;;
        dnf)
            print_info "Cleaning dnf cache..."
            sudo dnf clean all
            sudo dnf autoremove -y
            ;;
        nix)
            print_info "Cleaning nix store (user)..."
            nix-collect-garbage -d
            print_info "Cleaning nix store (system)..."
            sudo nix-collect-garbage -d
            ;;
        *)
            print_warning "Unknown package manager, skipping package cache cleanup"
            ;;
    esac
}

clean_language_package_managers() {
    print_info "Cleaning language package manager caches..."

    if command_exists conda; then
        print_info "Cleaning conda cache..."
        conda clean --all -y
    fi

    if command_exists pip3; then
        print_info "Cleaning pip cache..."
        pip3 cache purge
    elif command_exists pip; then
        print_info "Cleaning pip cache..."
        pip cache purge
    fi

    if command_exists npm; then
        print_info "Cleaning npm cache..."
        npm cache clean --force
    fi

    if command_exists cargo; then
        print_info "Cleaning cargo cache..."
        rm -rf "${CARGO_HOME:-$HOME/.cargo}/registry/cache/"
        rm -rf "${CARGO_HOME:-$HOME/.cargo}/git/db/"
    fi

    if command_exists go; then
        print_info "Cleaning go module cache..."
        go clean -modcache
    fi
}

clean_disk() {
    print_info "Cleaning disk space..."

    # Clean user cache
    print_info "Removing user cache..."
    if [[ "$DRY_RUN" != "true" ]]; then
        rm -rf ~/.cache/
    else
        print_info "[DRY RUN] Would remove ~/.cache/"
    fi

    # Clean journal logs
    print_info "Cleaning journal logs (keeping last 7 days)..."
    sudo journalctl --vacuum-time=7d

    clean_system_packages
    clean_language_package_managers

    print_success "Disk cleanup complete"
}

# Run if not sourced
if ! is_sourced; then
    clean_disk
fi
