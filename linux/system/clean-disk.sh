#!/usr/bin/env bash
# Clean up disk space by removing caches and old packages

set -e

# Source common functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../lib/common.sh
source "${SCRIPT_DIR}/../lib/common.sh"

clean_disk() {
    print_info "Cleaning disk space..."
    
    # Clean user cache
    print_info "Removing user cache..."
    rm -rf ~/.cache/
    
    # Clean journal logs
    print_info "Cleaning journal logs (keeping last 7 days)..."
    sudo journalctl --vacuum-time=7d
    
    # Clean package manager cache
    local pm
    pm=$(detect_package_manager)
    
    case "$pm" in
        apt)
            print_info "Cleaning apt cache..."
            sudo apt autoclean
            sudo apt autoremove -y
            sudo apt update
            ;;
        pacman)
            print_info "Cleaning pacman cache..."
            sudo pacman -Scc --noconfirm
            ;;
        dnf)
            print_info "Cleaning dnf cache..."
            sudo dnf clean all
            sudo dnf autoremove -y
            ;;
        *)
            print_warning "Unknown package manager, skipping package cache cleanup"
            ;;
    esac
    
    print_success "Disk cleanup complete"
}

# Run if not sourced
if ! is_sourced; then
    clean_disk
fi
