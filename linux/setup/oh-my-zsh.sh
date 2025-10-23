#!/usr/bin/env bash
# Install Oh My Zsh

set -e

# Source common functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../lib/common.sh
source "${SCRIPT_DIR}/../lib/common.sh"

install_oh_my_zsh() {
    print_info "Installing Oh My Zsh..."
    
    if [[ -d "$HOME/.oh-my-zsh" ]]; then
        print_warning "Oh My Zsh is already installed"
        return 0
    fi
    
    # Download and run Oh My Zsh installer
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    
    print_success "Oh My Zsh installed successfully"
}

# Run if not sourced
if ! is_sourced; then
    install_oh_my_zsh
fi
