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
        brew)
            print_info "Updating Homebrew..."
            run_cmd brew update
            print_info "Upgrading formulae..."
            run_cmd brew upgrade
            print_info "Upgrading casks..."
            # Casks that self-update reject --greedy upgrades; not an error.
            run_cmd brew upgrade --cask || print_warning "Some casks could not be upgraded"
            print_success "Homebrew packages upgraded successfully"
            ;;
        apt)
            print_info "Updating package lists..."
            run_cmd sudo apt update
            print_info "Upgrading packages..."
            run_cmd sudo apt upgrade -y
            print_success "APT packages upgraded successfully"
            ;;
        pacman)
            print_info "Upgrading packages..."
            run_cmd sudo pacman -Syu --noconfirm
            print_success "Pacman packages upgraded successfully"
            ;;
        dnf)
            print_info "Upgrading packages..."
            run_cmd sudo dnf upgrade -y
            print_success "DNF packages upgraded successfully"
            ;;
        nix)
            print_info "Nixos pkgs are handled via flake and home manager. Nothing to be done here."
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
