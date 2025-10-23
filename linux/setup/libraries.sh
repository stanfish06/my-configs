#!/usr/bin/env bash
# Install development libraries

set -e

# Source common functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../lib/common.sh
source "${SCRIPT_DIR}/../lib/common.sh"

install_x11_libraries() {
    print_info "Installing X11 development libraries..."
    install_packages \
        libx11-dev \
        libxinerama-dev \
        libxft-dev
}

install_math_libraries() {
    print_info "Installing math libraries..."
    install_packages \
        libopenblas-dev \
        libsuitesparse-dev
}

install_all_libraries() {
    print_info "Installing all development libraries..."
    update_system
    install_x11_libraries
    install_math_libraries
    print_success "All libraries installed successfully"
}

# Run if not sourced
if ! is_sourced; then
    if [[ $# -eq 0 ]]; then
        install_all_libraries
    else
        case "$1" in
            x11) install_x11_libraries ;;
            math) install_math_libraries ;;
            all) install_all_libraries ;;
            *)
                print_error "Unknown library group: $1"
                echo "Usage: $0 [x11|math|all]"
                exit 1
                ;;
        esac
    fi
fi
