#!/usr/bin/env bash
# Common functions for Linux setup scripts

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Print colored messages
print_info() {
    echo -e "${BLUE}[INFO]${NC} $*"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $*"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $*"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $*"
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
