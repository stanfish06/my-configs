#!/usr/bin/env bash
# Install zoxide terminal emulator

set -e

# Source common functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../lib/common.sh
source "${SCRIPT_DIR}/../lib/common.sh"

install_chezmoi() {
    print_info "Installing chezmoi..."

    sh -c "$(curl -fsLS https://get.chezmoi.io)"

    print_success "chezmoi installed successfully"
}

# Run if not sourced
if ! is_sourced; then
    install_chezmoi
fi
