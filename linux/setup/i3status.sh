#!/usr/bin/env bash
# Install i3status and its dependencies

set -e

# Source common functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../lib/common.sh
source "${SCRIPT_DIR}/../lib/common.sh"

install_i3status() {
    print_info "Installing i3status and dependencies..."
    
    update_system
    install_packages \
        autoconf \
        libconfuse-dev \
        libyajl-dev \
        libasound2-dev \
        libiw-dev \
        asciidoc \
        libpulse-dev \
        libnl-genl-3-dev \
        meson \
        i3status
    
    print_success "i3status installed successfully"
}

# Run if not sourced
if ! is_sourced; then
    install_i3status
fi
