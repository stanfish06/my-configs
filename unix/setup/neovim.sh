#!/usr/bin/env bash
# Install Neovim editor

set -e

# Source common functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../lib/common.sh
source "${SCRIPT_DIR}/../lib/common.sh"

install_neovim() {
    # On macOS the Homebrew formula tracks upstream closely, so prefer it and
    # avoid hand-managing a tarball under /opt.
    if is_macos; then
        print_info "Installing Neovim via Homebrew..."
        require_homebrew || return 1
        install_packages neovim
        print_success "Neovim installed successfully"
        return 0
    fi

    print_info "Installing Neovim from github (try to use package manager unless that is too old)..."

    local arch
    local asset
    local nvim_url
    local temp_file
    arch=$(uname -m)

    # Pick by OS *and* arch: bare "arm64" is reported by some Linux distros as
    # well as macOS, so arch alone cannot tell us which tarball we need.
    case "$arch" in
    x86_64|amd64)
        asset="nvim-linux-x86_64"
        ;;
    aarch64|arm64)
        asset="nvim-linux-arm64"
        ;;
    *)
        print_error "Unsupported architecture: $arch"
        return 1
        ;;
    esac

    nvim_url="https://github.com/neovim/neovim/releases/latest/download/${asset}.tar.gz"
    temp_file="/tmp/${asset}.tar.gz"

    # Download Neovim
    download_with_retry "$nvim_url" "$temp_file" || return 1

    if [[ "$DRY_RUN" == "true" ]]; then
        print_info "[DRY RUN] Would install Neovim to /opt/${asset}"
        return 0
    fi

    # Remove old installation if exists
    sudo rm -rf /opt/nvim-*
    # Extract to /opt
    sudo tar -C /opt -xzf "$temp_file"

    # Clean up
    rm -f "$temp_file"

    print_success "Neovim installed to /opt/${asset}"
    print_info "Add this to your shell profile:"
    echo "  export PATH=\"\$PATH:/opt/${asset}/bin\""
}

# Run if not sourced
if ! is_sourced; then
    install_neovim
fi
