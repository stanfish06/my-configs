#!/usr/bin/env bash
# Install WezTerm terminal emulator

set -e

# Source common functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../lib/common.sh
source "${SCRIPT_DIR}/../lib/common.sh"

install_wezterm() {
    print_info "Installing WezTerm..."
    local pm
    pm=$(detect_package_manager)
    update_system
    case "$pm" in
        dnf)
            sudo dnf copr enable wezfurlong/wezterm-nightly
            # Update and install
            update_system
            install_packages wezterm
            ;;
        apt)
            # Add WezTerm repository key
            curl -fsSL https://apt.fury.io/wez/gpg.key | sudo gpg --yes --dearmor -o /usr/share/keyrings/wezterm-fury.gpg
            # Add WezTerm repository
            echo 'deb [trusted=yes] https://apt.fury.io/wez/ * *' | sudo tee /etc/apt/sources.list.d/wezterm.list
            sudo chmod 644 /usr/share/keyrings/wezterm-fury.gpg
            # Update and install
            update_system
            install_packages wezterm-nightly
            ;;
        *)
            print_error "unsupported plat"
            ;;
    esac
    
    print_success "WezTerm installed successfully"
}

# Run if not sourced
if ! is_sourced; then
    install_wezterm
fi
