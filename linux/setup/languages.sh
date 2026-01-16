#!/usr/bin/env bash
# Install programming languages and runtimes

set -e

# Source common functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../lib/common.sh
source "${SCRIPT_DIR}/../lib/common.sh"

install_python() {
    print_info "Installing Python..."
    install_packages python3 python3-pip python3-venv
    mark_installed "python" "$(python3 --version 2>&1 | awk '{print $2}')"
}

install_nodejs() {
    print_info "Installing Node.js..."
    install_packages nodejs npm
    mark_installed "nodejs" "$(node --version 2>&1)"
}

install_r() {
    print_info "Installing R..."
    install_packages r-base r-base-dev
    mark_installed "r" "$(R --version 2>&1 | head -1 | awk '{print $3}')"
}

install_java() {
    print_info "Installing Java..."
    install_packages default-jre default-jdk
    mark_installed "java" "$(java -version 2>&1 | head -1 | awk -F '"' '{print $2}')"
}

install_haskell() {
    print_info "Installing Haskell..."
    install_packages build-essential curl libffi-dev libffi8 libgmp-dev libgmp10 libncurses-dev libncurses6 libtinfo6 pkg-config

    # Install GHCup with error handling
    if [[ "$DRY_RUN" != "true" ]]; then
        curl --proto '=https' --tlsv1.2 -sSf https://get-ghcup.haskell.org | sh
    else
        print_info "[DRY RUN] Would install Haskell from https://get-ghcup.haskell.org"
    fi

    mark_installed "haskell" "ghcup"
}

install_rust() {
    print_info "Installing Rust..."

    if command_exists rustup; then
        print_warning "Rust is already installed, updating..."
        rustup update
    else
        if [[ "$DRY_RUN" != "true" ]]; then
            curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
            curl -L --proto '=https' --tlsv1.2 -sSf https://raw.githubusercontent.com/cargo-bins/cargo-binstall/main/install-from-binstall-release.sh | bash
            # shellcheck source=/dev/null
            source "$HOME/.cargo/env"
        else
            print_info "[DRY RUN] Would install Rust from https://sh.rustup.rs"
        fi
    fi

    if command_exists rustc; then
        mark_installed "rust" "$(rustc --version | awk '{print $2}')"
    fi

    print_success "Rust installed successfully"

    install_rust_analyzer
}

install_rust_analyzer() {
    print_info "Installing Rust-analyzer..."
    rustup component add rust-analyzer
    print_success "Rust-analyzer installed successfully"
}

install_julia() {
    print_info "Installing Julia..."

    if command_exists juliaup; then
        print_warning "Julia is already installed, updating..."
        juliaup update
    else
        if [[ "$DRY_RUN" != "true" ]]; then
            curl -fsSL https://install.julialang.org | sh -s -- -y
        else
            print_info "[DRY RUN] Would install Julia from https://install.julialang.org"
        fi
    fi

    mark_installed "julia" "juliaup"

    print_success "Julia installed successfully"
}

install_go() {
    print_info "Installing Go..."

    local go_version="1.23.3"
    local go_release="go${go_version}.linux-amd64.tar.gz"
    local temp_file="/tmp/${go_release}"

    # Download Go with retry logic
    if ! download_with_retry "https://go.dev/dl/${go_release}" "$temp_file"; then
        print_error "Failed to download Go"
        return 1
    fi

    if [[ "$DRY_RUN" != "true" ]]; then
        # Remove old installation and extract
        sudo rm -rf /usr/local/go
        sudo tar -C /usr/local -xzf "$temp_file"

        # Clean up
        rm -f "$temp_file"
    else
        print_info "[DRY RUN] Would extract Go to /usr/local/go"
    fi

    mark_installed "go" "$go_version"

    print_success "Go installed to /usr/local/go"
    print_info "Add this to your shell profile:"
    echo '  export PATH="$PATH:/usr/local/go/bin"'
}

install_all_languages() {
    print_info "Installing all programming languages..."
    update_system
    install_python
    install_nodejs
    install_r
    install_java
    install_rust
    install_julia
    install_go
    print_success "All languages installed successfully"
}

# Run if not sourced
if ! is_sourced; then
    if [[ $# -eq 0 ]]; then
        install_all_languages
    else
        case "$1" in
            python) install_python ;;
            nodejs|node) install_nodejs ;;
            r) install_r ;;
            java) install_java ;;
            rust) install_rust ;;
            julia) install_julia ;;
            go) install_go ;;
            haskell) install_haskell ;;
            all) install_all_languages ;;
            *)
                print_error "Unknown language: $1"
                echo "Usage: $0 [python|nodejs|r|java|rust|julia|go|all]"
                exit 1
                ;;
        esac
    fi
fi
