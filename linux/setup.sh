#!/usr/bin/env bash
# Main Linux setup script - modular and easy to use

set -e

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Parse flags before sourcing common.sh
for arg in "$@"; do
    case "$arg" in
        --log)
            export ENABLE_LOGGING=true
            ;;
        --dry-run)
            export DRY_RUN=true
            ;;
    esac
done

# Source common functions
# shellcheck source=lib/common.sh
source "${SCRIPT_DIR}/lib/common.sh"

# Initialize logging if enabled
init_logging "$@"

# Display usage information
show_usage() {
    cat << EOF
Linux Setup Script - Modular installation and configuration tool

Usage: $0 [COMMAND] [OPTIONS]

Global Options:
  --log         Enable detailed logging to ~/.linux-setup/logs/
  --dry-run     Show what would be done without making changes

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
  conda             Install miniconda
  mise              Install mise-en-place
  upgrade           Upgrade all system packages
  clean             Clean disk space (remove caches and old packages)
  network           update network DNS
  status            Show installed components and their versions
  help              Show this help message

Examples:
  $0 full                    # Install everything
  $0 full --log              # Install with detailed logging
  $0 basic --dry-run         # Preview basic packages installation
  $0 languages python        # Install Python only
  $0 languages               # Install all languages
  $0 libraries x11           # Install X11 libraries only
  $0 clean                   # Clean up disk space
  $0 status                  # Show what's installed

For more information about individual components, see the README.md file.
EOF
}

# Run full setup
run_full_setup() {
    print_info "Starting full Linux setup..."

    if [[ "$DRY_RUN" == "true" ]]; then
        print_warning "DRY RUN MODE: No changes will be made"
    fi

    check_not_root

    # Run pre-flight checks
    run_preflight_checks 10000 || {
        print_error "Pre-flight checks failed"
        exit 1
    }

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

# Show status of installed components
show_status() {
    print_info "Installed components:"
    echo ""

    if [[ ! -f "$STATE_FILE" ]]; then
        print_warning "No installation state found. Run './setup.sh full' to install components."
        return
    fi

    # Display installed components in a table format
    printf "%-20s %-20s %-30s\n" "COMPONENT" "VERSION" "INSTALLED AT"
    printf "%-20s %-20s %-30s\n" "---------" "-------" "------------"

    get_installed_components | while IFS=$'\t' read -r component version installed_at; do
        printf "%-20s %-20s %-30s\n" "$component" "$version" "$installed_at"
    done

    echo ""
    print_info "State file: $STATE_FILE"
    print_info "Backup directory: $BACKUP_DIR"
    print_info "Log directory: $LOG_DIR"
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
            "${SCRIPT_DIR}/setup/alacritty.sh"
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
        conda)
            "${SCRIPT_DIR}/setup/conda.sh"
            ;;
        mise)
            "${SCRIPT_DIR}/setup/mise.sh"
            ;;
        upgrade)
            "${SCRIPT_DIR}/system/upgrade-packages.sh"
            ;;
        clean)
            "${SCRIPT_DIR}/system/clean-disk.sh"
            ;;
        network)
            "${SCRIPT_DIR}/system/update-network.sh"
            ;;
        status)
            show_status
            ;;
        help|--help|-h)
            show_usage
            ;;
        --log|--dry-run)
            # These flags are handled earlier, skip them here
            shift
            if [[ $# -gt 0 ]]; then
                main "$@"
            else
                show_usage
            fi
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
