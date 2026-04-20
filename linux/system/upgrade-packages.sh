#!/usr/bin/env bash
# Upgrade all system packages

set -e

# Source common functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../lib/common.sh
source "${SCRIPT_DIR}/../lib/common.sh"

upgrade_packages() {
    print_info "Upgrading system packages..."

    local pm
    pm=$(detect_package_manager)

    case "$pm" in
        apt)
            print_info "Updating package lists..."
            sudo apt update
            print_info "Upgrading packages..."
            sudo apt upgrade -y
            print_success "APT packages upgraded successfully"
            ;;
        pacman)
            print_info "Upgrading packages..."
            sudo pacman -Syu --noconfirm
            print_success "Pacman packages upgraded successfully"
            ;;
        dnf)
            print_info "Upgrading packages..."
            sudo dnf upgrade -y
            print_success "DNF packages upgraded successfully"
            ;;
        *)
            print_error "Unknown package manager"
            return 1
            ;;
    esac

    print_success "System package upgrade complete"
}

# Run if not sourced
if ! is_sourced; then
    upgrade_packages
fi
