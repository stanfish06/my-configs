#!/usr/bin/env bash
# Common functions for the unix setup scripts (Linux + macOS)
#
# Targets bash 3.2, which is what /bin/bash still is on macOS. Avoid bash 4+
# features here: no associative arrays, no ${var,,}, no mapfile/readarray.

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Global configuration
# Keep using a pre-existing ~/.linux-setup so state/backups survive the rename.
if [[ -d "$HOME/.linux-setup" && ! -d "$HOME/.unix-setup" ]]; then
    SETUP_DIR="$HOME/.linux-setup"
else
    SETUP_DIR="$HOME/.unix-setup"
fi
BACKUP_DIR="$SETUP_DIR/backups"
LOG_DIR="$SETUP_DIR/logs"
STATE_FILE="$SETUP_DIR/state.json"
DRY_RUN=${DRY_RUN:-false}
ENABLE_LOGGING=${ENABLE_LOGGING:-false}
LOG_FILE=""

# Initialize setup directory structure
init_setup_dirs() {
    mkdir -p "$BACKUP_DIR" "$LOG_DIR"
}

# Logging functionality
log_message() {
    local message="$*"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')

    if [[ "$ENABLE_LOGGING" == "true" && -n "$LOG_FILE" ]]; then
        echo "[$timestamp] $message" >> "$LOG_FILE"
    fi
}

# Print colored messages with optional logging
print_info() {
    echo -e "${BLUE}[INFO]${NC} $*"
    log_message "[INFO] $*"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $*"
    log_message "[SUCCESS] $*"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $*"
    log_message "[WARNING] $*"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $*"
    log_message "[ERROR] $*"
}

# Initialize logging for current session
init_logging() {
    if [[ "$ENABLE_LOGGING" == "true" ]]; then
        init_setup_dirs
        LOG_FILE="$LOG_DIR/$(date '+%Y%m%d-%H%M%S').log"
        log_message "=== Linux Setup Log Started ==="
        log_message "Command: $0 $*"
        print_info "Logging enabled: $LOG_FILE"
    fi
}

# Check if running as root
check_not_root() {
    if [[ $EUID -eq 0 ]]; then
        print_error "This script should NOT be run as root"
        exit 1
    fi
}

# Check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Detect OS family: macos | linux | unknown
detect_os() {
    case "$(uname -s)" in
        Darwin) echo "macos" ;;
        Linux)  echo "linux" ;;
        *)      echo "unknown" ;;
    esac
}

OS_FAMILY="$(detect_os)"

is_macos() { [[ "$OS_FAMILY" == "macos" ]]; }
is_linux() { [[ "$OS_FAMILY" == "linux" ]]; }

# Exit successfully when the calling script does not apply to this OS.
# Keeps `setup.sh full` from aborting on a Linux-only component.
skip_unless_linux() {
    if ! is_linux; then
        print_warning "Skipping $(basename "${0}") — ${1:-not applicable on $OS_FAMILY}"
        exit 0
    fi
}

# Homebrew installs to /opt/homebrew on Apple silicon, /usr/local on Intel.
# Non-interactive shells often miss it, so put it on PATH ourselves.
load_homebrew_env() {
    command_exists brew && return 0

    local candidate
    for candidate in /opt/homebrew/bin/brew /usr/local/bin/brew; do
        if [[ -x "$candidate" ]]; then
            eval "$("$candidate" shellenv)"
            return 0
        fi
    done

    return 1
}

# Detect package manager
detect_package_manager() {
    if [[ "$(detect_os)" == "macos" ]]; then
        if load_homebrew_env; then
            echo "brew"
        else
            echo "unknown"
        fi
        return
    fi

    if command_exists apt; then
        echo "apt"
    elif command_exists pacman; then
        echo "pacman"
    elif command_exists dnf; then
        echo "dnf"
    elif [[ -f /etc/NIXOS ]]; then
        echo "nix"
    else
        echo "unknown"
    fi
}

# Tell the user how to get Homebrew rather than installing it behind their back.
require_homebrew() {
    if load_homebrew_env; then
        return 0
    fi

    print_error "Homebrew is required on macOS but was not found"
    print_info "Install it with:"
    echo '  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"'
    return 1
}

# Run a command, or describe it when DRY_RUN is set
run_cmd() {
    if [[ "$DRY_RUN" == "true" ]]; then
        print_info "[DRY RUN] Would run: $*"
        return 0
    fi

    "$@"
}

# Update system packages
update_system() {
    local pm
    pm=$(detect_package_manager)

    if [[ "$pm" == "nix" ]]; then
        print_info "NixOS detected — package management is handled by your flake + home-manager repo. Skipping."
        return 0
    fi

    print_info "Updating system packages..."
    case "$pm" in
        brew)
            run_cmd brew update
            ;;
        apt)
            run_cmd sudo apt update
            ;;
        pacman)
            run_cmd sudo pacman -Sy
            ;;
        dnf)
            run_cmd sudo dnf check-update || true
            ;;
        *)
            print_warning "Unknown package manager"
            return 1
            ;;
    esac
}

# Install packages based on package manager
install_packages() {
    local pm
    pm=$(detect_package_manager)

    if [[ "$pm" == "nix" ]]; then
        print_info "NixOS detected — package installation is handled by your flake + home-manager repo. Skipping."
        return 0
    fi

    print_info "Installing packages: $*"
    case "$pm" in
        brew)
            # brew exits non-zero if a formula is already installed and up to date
            run_cmd brew install "$@" || print_warning "Some formulae were already installed or unavailable"
            ;;
        apt)
            run_cmd sudo apt install -y "$@"
            ;;
        pacman)
            run_cmd sudo pacman -S --noconfirm "$@"
            ;;
        dnf)
            run_cmd sudo dnf install -y "$@"
            ;;
        *)
            print_error "Unknown package manager"
            return 1
            ;;
    esac
}

# Install macOS GUI applications (Homebrew casks). No-op elsewhere.
install_casks() {
    if ! is_macos; then
        print_warning "install_casks is macOS-only, skipping: $*"
        return 0
    fi

    require_homebrew || return 1

    print_info "Installing casks: $*"
    run_cmd brew install --cask "$@" || print_warning "Some casks were already installed or unavailable"
}

# Check if the current script is being sourced
is_sourced() {
    [[  "${BASH_SOURCE[1]}" != "${0}" ]]
}

# Backup functionality
# Creates timestamped backup of a file before modification
backup_file() {
    local file=$1

    if [[ "$DRY_RUN" == "true" ]]; then
        print_info "[DRY RUN] Would backup: $file"
        return 0
    fi

    if [[ ! -f "$file" ]]; then
        return 0
    fi

    init_setup_dirs
    local filename=$(basename "$file")
    local backup_path="$BACKUP_DIR/${filename}.$(date +%Y%m%d-%H%M%S).bak"

    cp "$file" "$backup_path"
    print_info "Backed up: $file -> $backup_path"
    log_message "Backed up $file to $backup_path"
}

# State tracking functionality
# ISO-8601 timestamp. `date -Iseconds` is GNU-only and missing on older macOS.
timestamp_iso() {
    date +%Y-%m-%dT%H:%M:%S%z
}

# Initialize state file if it doesn't exist
init_state_file() {
    init_setup_dirs

    if [[ ! -f "$STATE_FILE" ]]; then
        local now
        now=$(timestamp_iso)
        echo '{"installed": {}, "metadata": {"created": "'"$now"'", "last_updated": "'"$now"'"}}' > "$STATE_FILE"
    fi
}

# Mark a component as installed in state file
mark_installed() {
    local component=$1
    local version=${2:-"unknown"}

    if [[ "$DRY_RUN" == "true" ]]; then
        print_info "[DRY RUN] Would mark installed: $component ($version)"
        return 0
    fi

    if [[ "$(detect_package_manager)" == "nix" ]]; then
        print_warning "NixOS detected — skipping state tracking (package installs are managed in your flake + home-manager repo)"
        return 0
    fi

    init_state_file

    # Use Python to update JSON if available, otherwise use basic jq
    if command_exists python3; then
        python3 << EOF
import json
from datetime import datetime

with open("$STATE_FILE", "r") as f:
    state = json.load(f)

state["installed"]["$component"] = {
    "version": "$version",
    "installed_at": datetime.now().isoformat()
}
state["metadata"]["last_updated"] = datetime.now().isoformat()

with open("$STATE_FILE", "w") as f:
    json.dump(state, f, indent=2)
EOF
    else
        # Fallback: simple append (not proper JSON update)
        print_warning "Python3 not available, state tracking limited"
    fi

    log_message "Marked $component ($version) as installed"
}

# Check if a component is already installed
is_installed() {
    local component=$1

    if [[ ! -f "$STATE_FILE" ]]; then
        return 1
    fi

    if command_exists python3; then
        python3 << EOF
import json
import sys

try:
    with open("$STATE_FILE", "r") as f:
        state = json.load(f)
    if "$component" in state.get("installed", {}):
        sys.exit(0)
    else:
        sys.exit(1)
except:
    sys.exit(1)
EOF
    else
        # Fallback: grep for component name
        grep -q "\"$component\"" "$STATE_FILE" 2>/dev/null
    fi
}

# Get all installed components
get_installed_components() {
    if [[ ! -f "$STATE_FILE" ]]; then
        return
    fi

    if command_exists python3; then
        python3 << EOF
import json

try:
    with open("$STATE_FILE", "r") as f:
        state = json.load(f)
    for component, info in state.get("installed", {}).items():
        version = info.get("version", "unknown")
        installed_at = info.get("installed_at", "unknown")
        print(f"{component}\t{version}\t{installed_at}")
except:
    pass
EOF
    fi
}

# Pre-flight validation checks
# Available space on the volume holding $HOME, in KB.
# -P forces POSIX single-line output so long device names cannot wrap.
free_space_kb() {
    local kb
    kb=$(df -Pk "$HOME" 2>/dev/null | awk 'NR==2 {print $4; exit}')
    # Always emit a number so arithmetic on the result cannot break.
    case "$kb" in
        ''|*[!0-9]*) echo 0 ;;
        *) echo "$kb" ;;
    esac
}

# Check available disk space in MB
check_disk_space() {
    local required_mb=${1:-5000}
    local available_mb=$(( $(free_space_kb) / 1024 ))

    if [[ $available_mb -lt $required_mb ]]; then
        print_error "Insufficient disk space: ${available_mb}MB available, ${required_mb}MB required"
        return 1
    fi

    print_info "Disk space check passed: ${available_mb}MB available"
    return 0
}

# Check network connectivity
check_network() {
    print_info "Checking network connectivity..."

    # -W is a per-packet timeout in ms on BSD ping but seconds on GNU ping,
    # and -t means TTL on GNU but overall deadline on BSD. Branch on the OS.
    local ping_args
    if is_macos; then
        ping_args="-c 1 -t 2"
    else
        ping_args="-c 1 -W 2"
    fi

    # shellcheck disable=SC2086 # intentional word splitting of the flag list
    if ! ping $ping_args 8.8.8.8 >/dev/null 2>&1; then
        print_error "No network connectivity"
        return 1
    fi

    print_info "Network connectivity check passed"
    return 0
}

# Check sudo access
check_sudo_access() {
    print_info "Checking sudo access..."

    if ! sudo -n true 2>/dev/null; then
        print_warning "Sudo access requires password"
        # Try to get sudo access
        if ! sudo true; then
            print_error "Failed to obtain sudo access"
            return 1
        fi
    fi

    print_info "Sudo access check passed"
    return 0
}

# Non-fatal sudo probe, cached for the life of the process. Lets callers do the
# unprivileged work and skip only the steps that genuinely need root.
SUDO_CHECKED=false
SUDO_AVAILABLE=false
have_sudo() {
    if [[ "$SUDO_CHECKED" != "true" ]]; then
        SUDO_CHECKED=true
        if sudo -n true 2>/dev/null || sudo true 2>/dev/null; then
            SUDO_AVAILABLE=true
        fi
    fi

    [[ "$SUDO_AVAILABLE" == "true" ]]
}

# Run all pre-flight checks
run_preflight_checks() {
    local required_space=${1:-5000}

    print_info "Running pre-flight checks..."

    check_disk_space "$required_space" || return 1
    check_network || return 1

    if is_macos; then
        # Homebrew refuses to run as root and installs into a user-writable
        # prefix, so there is nothing to escalate for.
        require_homebrew || return 1
    else
        check_sudo_access || return 1
    fi

    print_success "All pre-flight checks passed"
    return 0
}

# Download with retry logic
download_with_retry() {
    local url=$1
    local dest=$2
    local max_attempts=${3:-3}

    if [[ "$DRY_RUN" == "true" ]]; then
        print_info "[DRY RUN] Would download: $url -> $dest"
        return 0
    fi

    for ((i=1; i<=max_attempts; i++)); do
        print_info "Downloading (attempt $i/$max_attempts): $url"

        if curl -fLo "$dest" "$url"; then
            print_success "Download successful: $dest"
            log_message "Downloaded $url to $dest"
            return 0
        fi

        if [[ $i -lt $max_attempts ]]; then
            print_warning "Download failed, retrying in 2 seconds..."
            sleep 2
        fi
    done

    print_error "Download failed after $max_attempts attempts: $url"
    log_message "Download failed after $max_attempts attempts: $url"
    return 1
}

# Check if a line exists in a file (for idempotency)
line_exists_in_file() {
    local line=$1
    local file=$2

    if [[ ! -f "$file" ]]; then
        return 1
    fi

    grep -qF "$line" "$file" 2>/dev/null
}

# Disk-reclaim helpers
# ---------------------
# Running total of everything purge_* has removed, in KB.
RECLAIMED_KB=0

# Paths smaller than this are purged without a per-path log line, so a cache
# directory with hundreds of tiny entries does not bury the interesting output.
# They are still counted, and tallied into PURGE_QUIET_COUNT/PURGE_QUIET_KB.
PURGE_MIN_REPORT_KB=${PURGE_MIN_REPORT_KB:-10240}
PURGE_QUIET_COUNT=0
PURGE_QUIET_KB=0

# Reset the quiet tally before a batch, so a caller can summarise just its own.
reset_quiet_tally() {
    PURGE_QUIET_COUNT=0
    PURGE_QUIET_KB=0
}

# Log one purge, or fold it into the quiet tally when it is too small to matter.
# $1 verb ("remove"/"empty"), $2 past tense, $3 label, $4 size in KB
purge_report() {
    local verb=$1 past=$2 label=$3 size=$4

    if [[ $size -lt $PURGE_MIN_REPORT_KB ]]; then
        PURGE_QUIET_COUNT=$(( PURGE_QUIET_COUNT + 1 ))
        PURGE_QUIET_KB=$(( PURGE_QUIET_KB + size ))
        return 0
    fi

    if [[ "$DRY_RUN" == "true" ]]; then
        print_info "[DRY RUN] Would $verb $label ($(human_kb "$size"))"
    else
        print_info "$past $label ($(human_kb "$size"))"
    fi
}

# Report whatever the quiet tally accumulated since the last reset.
report_quiet_tally() {
    local what=${1:-smaller items}

    if [[ $PURGE_QUIET_COUNT -gt 0 ]]; then
        print_info "...plus $PURGE_QUIET_COUNT $what ($(human_kb "$PURGE_QUIET_KB"))"
    fi
}

# Size of a path in KB, 0 when it does not exist.
path_size_kb() {
    [[ -e "$1" ]] || { echo 0; return 0; }
    du -sk "$1" 2>/dev/null | awk '{print $1; exit}'
}

# Render a KB count as a human-readable size.
human_kb() {
    awk -v kb="${1:-0}" 'BEGIN {
        split("KB MB GB TB", unit, " ")
        i = 1
        while (kb >= 1024 && i < 4) { kb /= 1024; i++ }
        printf "%.1f%s", kb, unit[i]
    }'
}

# Refuse to delete paths that would be catastrophic or are obviously a bug.
# Guards against an unset variable expanding to "" or "$HOME".
assert_safe_target() {
    local target=$1

    case "$target" in
        ""|"/"|"/*"|"$HOME"|"$HOME/"|"$HOME/*")
            print_error "Refusing to delete unsafe path: '$target'"
            return 1
            ;;
    esac

    # A ".." component would let an otherwise in-prefix path escape upward,
    # e.g. "$HOME/../.." resolves to "/".
    case "$target" in
        *..*)
            print_error "Refusing to delete path containing '..': '$target'"
            return 1
            ;;
    esac

    # Everything we clean lives under $HOME or a known system cache location.
    case "$target" in
        "$HOME"/*|/Library/Caches/*|/private/var/log/*|/var/log/*|/tmp/*) ;;
        *)
            print_error "Refusing to delete path outside known cache roots: '$target'"
            return 1
            ;;
    esac

    return 0
}

# Delete a path and add its size to RECLAIMED_KB. Honours DRY_RUN.
purge_path() {
    local target=$1
    local label=${2:-$1}
    local size

    [[ -e "$target" ]] || return 0
    assert_safe_target "$target" || return 1

    size=$(path_size_kb "$target")

    if [[ "$DRY_RUN" == "true" ]]; then
        purge_report "remove" "Removed" "$label" "$size"
    elif rm -rf -- "$target" 2>/dev/null; then
        purge_report "remove" "Removed" "$label" "$size"
    else
        # Partial failures are normal: SIP, open files, permissions.
        print_warning "Partially removed $label (some files were in use or protected)"
    fi

    RECLAIMED_KB=$(( RECLAIMED_KB + size ))
}

# Empty a directory but keep the directory itself, which matters for caches an
# app expects to exist (~/.cache, ~/Library/Caches, ~/.Trash).
purge_dir_contents() {
    local dir=$1
    local label=${2:-$1}
    local size

    [[ -d "$dir" ]] || return 0
    assert_safe_target "$dir" || return 1

    size=$(path_size_kb "$dir")
    if [[ $size -eq 0 ]]; then
        return 0
    fi

    if [[ "$DRY_RUN" == "true" ]]; then
        purge_report "empty" "Emptied" "$label" "$size"
    elif find "$dir" -mindepth 1 -maxdepth 1 -exec rm -rf -- {} + 2>/dev/null; then
        purge_report "empty" "Emptied" "$label" "$size"
    else
        print_warning "Partially emptied $label (some files were in use or protected)"
    fi

    RECLAIMED_KB=$(( RECLAIMED_KB + size ))
}

# Is a process matching this pattern currently running?
# Used to leave a running app's cache alone.
app_running() {
    [[ -n "$1" ]] || return 1
    pgrep -qf "$1" 2>/dev/null
}

# Safely append to file (only if line doesn't exist)
safe_append_to_file() {
    local line=$1
    local file=$2

    if [[ "$DRY_RUN" == "true" ]]; then
        print_info "[DRY RUN] Would append to $file: $line"
        return 0
    fi

    if line_exists_in_file "$line" "$file"; then
        print_info "Line already exists in $file, skipping"
        return 0
    fi

    backup_file "$file"
    echo "$line" >> "$file"
    print_info "Appended to $file: $line"
    log_message "Appended to $file: $line"
}
