#!/usr/bin/env bash

set -e
# Source common functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../lib/common.sh
source "${SCRIPT_DIR}/../lib/common.sh"

install_conda() {
    print_info "Installing miniconda..."
    update_system

    # Installer names are Miniconda3-latest-<OS>-<arch>.sh
    local os_tag arch_tag
    case "$OS_FAMILY" in
        macos) os_tag="MacOSX" ;;
        linux) os_tag="Linux" ;;
        *)
            print_error "Unsupported OS: $OS_FAMILY"
            return 1
            ;;
    esac

    case "$(uname -m)" in
        x86_64|amd64)  arch_tag="x86_64" ;;
        arm64|aarch64) arch_tag="arm64" ;;
        *)
            print_error "Unsupported architecture: $(uname -m)"
            return 1
            ;;
    esac

    # Linux publishes aarch64, macOS publishes arm64.
    if [[ "$os_tag" == "Linux" && "$arch_tag" == "arm64" ]]; then
        arch_tag="aarch64"
    fi

    local installer="Miniconda3-latest-${os_tag}-${arch_tag}.sh"
    local temp_file="/tmp/${installer}"

    # curl is present by default on macOS; wget usually is not.
    download_with_retry "https://repo.anaconda.com/miniconda/${installer}" "$temp_file" || return 1

    if [[ "$DRY_RUN" == "true" ]]; then
        print_info "[DRY RUN] Would run $installer"
        return 0
    fi

    bash "$temp_file"
    rm -f "$temp_file"
    print_success "miniconda installed successfully"
}

# Run if not sourced
if ! is_sourced; then
    install_conda
fi
