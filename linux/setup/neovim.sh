#!/usr/bin/env bash
# Install Neovim editor

set -e

# Source common functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../lib/common.sh
source "${SCRIPT_DIR}/../lib/common.sh"

install_neovim() {
    print_info "Installing Neovim..."
    
    local nvim_url="https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz"
    local temp_file="/tmp/nvim-linux-x86_64.tar.gz"
    
    # Download Neovim
    curl -Lo "$temp_file" "$nvim_url"
    
    # Remove old installation if exists
    sudo rm -rf /opt/nvim-linux-x86_64
    
    # Extract to /opt
    sudo tar -C /opt -xzf "$temp_file"
    
    # Clean up
    rm -f "$temp_file"
    
    print_success "Neovim installed to /opt/nvim-linux-x86_64"
    print_info "Add this to your shell profile:"
    echo '  export PATH="$PATH:/opt/nvim-linux-x86_64/bin"'
}

# Run if not sourced
if ! is_sourced; then
    install_neovim
fi
