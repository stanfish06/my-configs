#!/usr/bin/env bash
# Install Raylib game development library

set -e

# Source common functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../lib/common.sh
source "${SCRIPT_DIR}/../lib/common.sh"

# The dependency list and the quickstart premake build are both X11-specific.
# On macOS, `brew install raylib` is the supported route.
skip_unless_linux "raylib deps here are X11-specific; on macOS run: brew install raylib"

install_raylib() {
    print_info "Installing Raylib dependencies..."
    
    update_system
    install_packages \
        libasound2-dev \
        libx11-dev \
        libxrandr-dev \
        libxi-dev \
        libgl1-mesa-dev \
        libglu1-mesa-dev \
        libxcursor-dev \
        libxinerama-dev \
        libwayland-dev \
        libxkbcommon-dev
    
    print_info "Cloning and building Raylib quickstart..."

    local temp_dir="/tmp/raylib-quickstart"

    if [[ "$DRY_RUN" == "true" ]]; then
        print_info "[DRY RUN] Would clone and build raylib-quickstart in $temp_dir"
        return 0
    fi

    rm -rf "$temp_dir"

    git clone https://github.com/raylib-extras/raylib-quickstart.git "$temp_dir"
    cd "$temp_dir"
    cd build
    ./premake5 gmake
    cd ..
    make
    
    print_success "Raylib setup complete"
    print_info "Raylib quickstart project is in: $temp_dir"
}

# Run if not sourced
if ! is_sourced; then
    install_raylib
fi
