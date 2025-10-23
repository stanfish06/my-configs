#!/usr/bin/env bash
# Install basic essential packages

set -e

# Source common functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../lib/common.sh
source "${SCRIPT_DIR}/../lib/common.sh"

install_basic_packages() {
    print_info "Installing basic essential packages..."
    
    update_system
    install_packages \
        curl \
        git \
        build-essential \
        net-tools \
        zsh \
        tmux \
        fd-find \
        fzf
    
    print_success "Basic packages installed successfully"
}

# Run if not sourced
if ! is_sourced; then
    install_basic_packages
fi
