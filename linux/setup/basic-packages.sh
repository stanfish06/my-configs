#!/usr/bin/env bash
# Install basic essential packages

set -e

# Source common functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../lib/common.sh
source "${SCRIPT_DIR}/../lib/common.sh"

install_basic_packages() {
    print_info "Installing basic essential packages..."
    local pm
    pm=$(detect_package_manager)
    update_system
    case "$pm" in
        dnf)
            print_info "Detecting fedora system, use a different package list"
            install_packages \
                curl \
                git \
                net-tools \
                zsh \
                tmux \
                fd-find \
                gh \
                tree \
                wl-clipboard \
                cmake \
                fzf \
                ripgrep
            sudo dnf group install -y development-tools
            ;;
        nix)
            print_info "Detecting NixOS, using nixpkgs attribute names"
            nix-env -iA \
                nixpkgs.curl \
                nixpkgs.git \
                nixpkgs.zsh \
                nixpkgs.tmux \
                nixpkgs.fd \
                nixpkgs.gh \
                nixpkgs.tree \
                nixpkgs.wl-clipboard \
                nixpkgs.cmake \
                nixpkgs.fzf \
                nixpkgs.ripgrep \
                nixpkgs.nettools
            ;;
        *)
            install_packages \
                curl \
                git \
                build-essential \
                net-tools \
                zsh \
                tmux \
                fd-find \
                gh \
                tree \
                wl-clipboard \
                cmake \
                linux-headers-generic
            ;;
    esac
    print_success "Basic packages installed successfully"
}

# Run if not sourced
if ! is_sourced; then
    install_basic_packages
fi
