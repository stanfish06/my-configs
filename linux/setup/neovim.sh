#!/usr/bin/env bash
# Install Neovim editor

set -e

# Source common functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../lib/common.sh
source "${SCRIPT_DIR}/../lib/common.sh"

install_neovim() {
    print_info "Installing Neovim from github (try to use package manager unless that is too old)..."
    
    local arch
    local nvim_url
    local temp_file
    arch=$(uname -m)
    case "$arch" in
    x86_64)
        nvim_url="https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz"
        temp_file="/tmp/nvim-linux-x86_64.tar.gz"
        ;;
    aarch64)
        nvim_url="https://github.com/neovim/neovim/releases/latest/download/nvim-linux-arm64.tar.gz"
        temp_file="/tmp/nvim-linux-arm64.tar.gz"
        ;;
    arm64)
        nvim_url="https://github.com/neovim/neovim/releases/latest/download/nvim-macos-arm64.tar.gz"
        temp_file="/tmp/nvim-macos-arm64.tar.gz"
        ;;
    *)
        print_error "Unsupported architecture: $arch"
        return 1
        ;;
    esac
    
    # Download Neovim
    curl -Lo "$temp_file" "$nvim_url"
    
    # Remove old installation if exists
    sudo rm -rf /opt/nvim-*    
    # Extract to /opt
    sudo tar -C /opt -xzf "$temp_file"
    
    # Clean up
    rm -f "$temp_file"
    
    print_success "Neovim installed to /opt/nvim-(linux/macos)-(x86_64/arm64)"
    print_info "Add this to your shell profile:"
    echo '  export PATH="$PATH:/opt/nvim-(linux/macos)-(x86_64/arm64)/bin"'
}

# Run if not sourced
if ! is_sourced; then
    install_neovim
fi
