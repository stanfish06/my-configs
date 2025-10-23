#!/usr/bin/env bash
# Main Linux setup script - modular and easy to use

set -e

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source common functions
# shellcheck source=lib/common.sh
source "${SCRIPT_DIR}/lib/common.sh"

# Display usage information
show_usage() {
    cat << EOF
Linux Setup Script - Modular installation and configuration tool

Usage: $0 [COMMAND] [OPTIONS]

Commands:
  full              Run complete system setup (all components)
  basic             Install basic packages (curl, git, build-essential, etc.)
  editor            Install Neovim text editor
  terminal          Install WezTerm terminal emulator
  shell             Install Oh My Zsh shell framework
  languages [LANG]  Install programming languages (all, python, nodejs, r, java, rust, julia, go)
  libraries [LIB]   Install development libraries (all, x11, math)
  i3status          Install i3status bar
  raylib            Install Raylib game library
  clean             Clean disk space (remove caches and old packages)
  help              Show this help message

Examples:
  $0 full                    # Install everything
  $0 basic                   # Install basic packages only
  $0 languages python        # Install Python only
  $0 languages               # Install all languages
  $0 libraries x11           # Install X11 libraries only
  $0 clean                   # Clean up disk space

For more information about individual components, see the README.md file.
EOF
}

# Run full setup
run_full_setup() {
    print_info "Starting full Linux setup..."
    
    check_not_root
    
    # Basic setup
    print_info "=== Phase 1: Basic Packages ==="
    "${SCRIPT_DIR}/setup/basic-packages.sh"
    
    # Shell setup
    print_info "=== Phase 2: Shell Setup ==="
    "${SCRIPT_DIR}/setup/oh-my-zsh.sh"
    
    # Editor
    print_info "=== Phase 3: Editor (Neovim) ==="
    "${SCRIPT_DIR}/setup/neovim.sh"
    
    # Terminal
    print_info "=== Phase 4: Terminal (WezTerm) ==="
    "${SCRIPT_DIR}/setup/wezterm.sh"
    
    # Languages
    print_info "=== Phase 5: Programming Languages ==="
    "${SCRIPT_DIR}/setup/languages.sh" all
    
    # Libraries
    print_info "=== Phase 6: Development Libraries ==="
    "${SCRIPT_DIR}/setup/libraries.sh" all
    
    print_success "Full setup complete!"
    print_info "Please restart your shell or run 'source ~/.zshrc' (or ~/.bashrc)"
}

# Main command dispatcher
main() {
    if [[ $# -eq 0 ]]; then
        show_usage
        exit 0
    fi
    
    case "$1" in
        full)
            run_full_setup
            ;;
        basic)
            "${SCRIPT_DIR}/setup/basic-packages.sh"
            ;;
        editor)
            "${SCRIPT_DIR}/setup/neovim.sh"
            ;;
        terminal)
            "${SCRIPT_DIR}/setup/wezterm.sh"
            ;;
        shell)
            "${SCRIPT_DIR}/setup/oh-my-zsh.sh"
            ;;
        languages)
            shift
            "${SCRIPT_DIR}/setup/languages.sh" "$@"
            ;;
        libraries)
            shift
            "${SCRIPT_DIR}/setup/libraries.sh" "$@"
            ;;
        i3status)
            "${SCRIPT_DIR}/setup/i3status.sh"
            ;;
        raylib)
            "${SCRIPT_DIR}/setup/raylib.sh"
            ;;
        clean)
            "${SCRIPT_DIR}/system/clean-disk.sh"
            ;;
        help|--help|-h)
            show_usage
            ;;
        *)
            print_error "Unknown command: $1"
            echo ""
            show_usage
            exit 1
            ;;
    esac
}

# Run main function
main "$@"
