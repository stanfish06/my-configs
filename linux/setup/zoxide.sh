#!/usr/bin/env bash
# Install zoxide terminal emulator

set -e

# Source common functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../lib/common.sh
source "${SCRIPT_DIR}/../lib/common.sh"

ZSH_CONFIG=~/.zshrc
BASH_CONFIG=~/.bashrc

install_zoxide() {
    print_info "Installing zoxide..."
    
    curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh

    if [ -f "$BASH_CONFIG" ]; then
        safe_append_to_file 'eval "$(zoxide init bash)"' "$BASH_CONFIG"
    fi
    if [ -f "$ZSH_CONFIG" ]; then
        safe_append_to_file 'eval "$(zoxide init zsh)"' "$ZSH_CONFIG"
    fi
    
    # Update and install
    update_system
    print_success "zoxide installed successfully"
}

# Run if not sourced
if ! is_sourced; then
    install_zoxide
fi
