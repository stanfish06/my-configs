#!/usr/bin/env bash
# Install alacritty terminal emulator

set -e

# Source common functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../lib/common.sh
source "${SCRIPT_DIR}/../lib/common.sh"

install_alacritty() {
    print_info "Installing Alacritty..."
    # Update and install
    update_system
    install_packages alacritty
    
    print_success "Alacritty installed successfully"
}

# Run if not sourced
if ! is_sourced; then
    install_alacritty
fi
