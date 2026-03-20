#!/usr/bin/env bash

set -e

# Source common functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../lib/common.sh
source "${SCRIPT_DIR}/../lib/common.sh"

install_kitty() {
    print_info "Installing Kitty..."
    update_system
    curl -L https://sw.kovidgoyal.net/kitty/installer.sh | sh /dev/stdin
    ln -sf ~/.local/kitty.app/bin/* ~/.local/bin/
    print_success "Kitty installed successfully"
}

# Run if not sourced
if ! is_sourced; then
    install_kitty
fi
