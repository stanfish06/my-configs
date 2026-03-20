#!/usr/bin/env bash

set -e

# Source common functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../lib/common.sh
source "${SCRIPT_DIR}/../lib/common.sh"

install_nvidia() {
    print_info "Setup nvidia driver and cuda"
    
    # usually need to enable non free stuff for package manager, refer to official guide
    # may also need to add keyrings
    update_system
    install_packages \
        nvidia-driver \
        nvidia-kernel-dkms \
        cuda-toolkit \
        cuda-drivers \
        nvidia-cuda-dev \
        nvidia-cuda-toolkit
    # update linux kernel headers if not up-to-date
    apt install linux-headers-$(uname -r)
    # install/update nvidia module
    dkms install nvidia -k $(uname -r)
    print_success "Done"
    # need to check Path and LD lib path to make sure cuda bin and lib are in there
    # compile sample code to verify https://github.com/NVIDIA/cuda-samples.git
}

# Run if not sourced
if ! is_sourced; then
    install_basic_packages
fi
