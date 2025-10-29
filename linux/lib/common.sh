#!/usr/bin/env bash
# Common functions for Linux setup scripts

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Global configuration
SETUP_DIR="$HOME/.linux-setup"
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

# Detect package manager
detect_package_manager() {
    if command_exists apt; then
        echo "apt"
    elif command_exists pacman; then
        echo "pacman"
    elif command_exists dnf; then
        echo "dnf"
    else
        echo "unknown"
    fi
}

# Update system packages
update_system() {
    local pm
    pm=$(detect_package_manager)
    
    print_info "Updating system packages..."
    case "$pm" in
        apt)
            sudo apt update
            ;;
        pacman)
            sudo pacman -Sy
            ;;
        dnf)
            sudo dnf check-update || true
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
    
    print_info "Installing packages: $*"
    case "$pm" in
        apt)
            sudo apt install -y "$@"
            ;;
        pacman)
            sudo pacman -S --noconfirm "$@"
            ;;
        dnf)
            sudo dnf install -y "$@"
            ;;
        *)
            print_error "Unknown package manager"
            return 1
            ;;
    esac
}

# Check if script is sourced or executed
is_sourced() {
    [[ "${BASH_SOURCE[1]}" != "${0}" ]]
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
# Initialize state file if it doesn't exist
init_state_file() {
    init_setup_dirs

    if [[ ! -f "$STATE_FILE" ]]; then
        echo '{"installed": {}, "metadata": {"created": "'$(date -Iseconds)'", "last_updated": "'$(date -Iseconds)'"}}' > "$STATE_FILE"
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
        python3 << 'EOF'
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
# Check available disk space in MB
check_disk_space() {
    local required_mb=${1:-5000}
    local available_mb=$(df -m "$HOME" | awk 'NR==2 {print $4}')

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

    if ! ping -c 1 -W 2 8.8.8.8 >/dev/null 2>&1; then
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

# Run all pre-flight checks
run_preflight_checks() {
    local required_space=${1:-5000}

    print_info "Running pre-flight checks..."

    check_disk_space "$required_space" || return 1
    check_network || return 1
    check_sudo_access || return 1

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
