#!/usr/bin/env bash
# Install rofi terminal emulator

set -e

# Source common functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../lib/common.sh
source "${SCRIPT_DIR}/../lib/common.sh"

install_rofi() {
    print_info "Installing rofi..."
    # Update and install
    update_system
    install_packages \
	libmpdclient-dev \
	libxcb-util-dev \
	libxcb-xkb-dev \
	libxkbcommon-dev \
	libxcb-ewmh-dev \
	libxcb-cursor-dev \
	libxkbcommon-dev \
	libxcb-icccm4-dev \
	libxcb-randr0-dev \
	libxcb-xinerama0-dev \
	libxcb-keysyms1-dev \
	libstartup-notification0-dev \
	libxkbcommon-x11-dev \
	libxcb-imdkit-dev \
	flex \
	bison
    
    print_success "rofi dependencies installed successfully"
}

# Run if not sourced
if ! is_sourced; then
    install_rofi
fi
