#!/usr/bin/env bash

set -e
# Source common functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../lib/common.sh
source "${SCRIPT_DIR}/../lib/common.sh"

install_conda() {
    print_info "Installing miniconda..."
    update_system
    wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh
    bash Miniconda3-latest-Linux-x86_64.sh
    rm  Miniconda3-latest-Linux-x86_64.sh
    print_success "miniconda installed successfully"
}

# Run if not sourced
if ! is_sourced; then
    install_conda
fi
