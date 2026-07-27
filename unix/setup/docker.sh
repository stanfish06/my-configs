#!/usr/bin/env bash
# Install Docker
#
# Linux: Docker CE from Docker's own apt repository (Debian).
# macOS: Colima + the docker CLI, which gives a daemon without Docker Desktop's
#        licensing constraints. Pass --desktop for Docker Desktop instead.

set -e

# Source common functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../lib/common.sh
source "${SCRIPT_DIR}/../lib/common.sh"

install_docker_macos() {
    require_homebrew || return 1

    if [[ "${1:-}" == "--desktop" ]]; then
        print_info "Installing Docker Desktop..."
        install_casks docker
        print_success "Docker Desktop installed — launch it once to start the daemon"
        return 0
    fi

    print_info "Installing Colima and the Docker CLI..."
    install_packages docker docker-compose colima

    print_success "Docker CLI and Colima installed"
    print_info "Start the daemon with:"
    echo "  colima start"
    print_info "Or install Docker Desktop instead with: $0 --desktop"
}

install_docker_linux() {
    local pm
    pm=$(detect_package_manager)

    if [[ "$pm" != "apt" ]]; then
        print_error "This script only automates Docker on apt-based systems (found: $pm)"
        print_info "See https://docs.docker.com/engine/install/ for $pm instructions"
        return 1
    fi

    check_sudo_access || return 1

    # Distro packages conflict with Docker CE. Only remove what is present, and
    # do not fail when none of them are installed.
    print_info "Removing conflicting distro packages (if any)..."
    local conflicting=""
    local pkg
    for pkg in docker.io docker-compose docker-doc podman-docker containerd runc; do
        if dpkg -s "$pkg" >/dev/null 2>&1; then
            conflicting="$conflicting $pkg"
        fi
    done
    if [[ -n "$conflicting" ]]; then
        # shellcheck disable=SC2086 # deliberate word splitting of the list
        run_cmd sudo apt remove -y $conflicting
    else
        print_info "No conflicting packages found"
    fi

    print_info "Adding Docker's official GPG key..."
    run_cmd sudo apt update
    run_cmd sudo apt install -y ca-certificates curl
    run_cmd sudo install -m 0755 -d /etc/apt/keyrings
    run_cmd sudo curl -fsSL https://download.docker.com/linux/debian/gpg \
        -o /etc/apt/keyrings/docker.asc
    run_cmd sudo chmod a+r /etc/apt/keyrings/docker.asc

    print_info "Adding the Docker apt repository..."
    if [[ "$DRY_RUN" == "true" ]]; then
        print_info "[DRY RUN] Would write /etc/apt/sources.list.d/docker.sources"
    else
        sudo tee /etc/apt/sources.list.d/docker.sources > /dev/null <<EOF
Types: deb
URIs: https://download.docker.com/linux/debian
Suites: $(. /etc/os-release && echo "$VERSION_CODENAME")
Components: stable
Signed-By: /etc/apt/keyrings/docker.asc
EOF
    fi

    run_cmd sudo apt update
    install_packages docker-ce docker-ce-cli containerd.io \
        docker-buildx-plugin docker-compose-plugin

    print_success "Docker installed successfully"
    print_info "To run docker without sudo: sudo usermod -aG docker \"\$USER\" (then re-login)"
}

install_docker() {
    if is_macos; then
        install_docker_macos "$@"
    else
        install_docker_linux
    fi
}

# Run if not sourced
if ! is_sourced; then
    install_docker "$@"
fi
