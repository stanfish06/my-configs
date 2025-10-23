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
}

install_nodejs() {
    print_info "Installing Node.js..."
    install_packages nodejs npm
}

install_r() {
    print_info "Installing R..."
    install_packages r-base r-base-dev
}

install_java() {
    print_info "Installing Java..."
    install_packages default-jre default-jdk
}

install_rust() {
    print_info "Installing Rust..."
    
    if command_exists rustup; then
        print_warning "Rust is already installed, updating..."
        rustup update
    else
        curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
        # shellcheck source=/dev/null
        source "$HOME/.cargo/env"
    fi
    
    print_success "Rust installed successfully"
}

install_julia() {
    print_info "Installing Julia..."
    
    if command_exists juliaup; then
        print_warning "Julia is already installed, updating..."
        juliaup update
    else
        curl -fsSL https://install.julialang.org | sh -s -- -y
    fi
    
    print_success "Julia installed successfully"
}

install_go() {
    print_info "Installing Go..."
    
    local go_version="1.23.3"
    local go_release="go${go_version}.linux-amd64.tar.gz"
    local temp_file="/tmp/${go_release}"
    
    # Download Go
    wget -O "$temp_file" "https://go.dev/dl/${go_release}"
    
    # Remove old installation and extract
    sudo rm -rf /usr/local/go
    sudo tar -C /usr/local -xzf "$temp_file"
    
    # Clean up
    rm -f "$temp_file"
    
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
            all) install_all_languages ;;
            *)
                print_error "Unknown language: $1"
                echo "Usage: $0 [python|nodejs|r|java|rust|julia|go|all]"
                exit 1
                ;;
        esac
    fi
fi
