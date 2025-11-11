#!/usr/bin/env bash
# Install atuin
set -e

# Source common functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../lib/common.sh
source "${SCRIPT_DIR}/../lib/common.sh"
ZSH_CONFIG=~/.zshrc
BASH_CONFIG=~/.bashrc

install_atuin() {
    if command -v atuin >/dev/null 2>&1; then
        print_info "atuin already exists, performing self-update..."
        atuin update
        if [ -f "$ZSH_CONFIG" ]; then
	    print_info "update .zshrc"
            safe_append_to_file 'eval "$(atuin init zsh)"' "$ZSH_CONFIG"
        fi
    else
        print_info "Installing atuin..."
        # Update and install
        update_system

        # Download and install atuin
        if [[ "$DRY_RUN" != "true" ]]; then
	    curl --proto '=https' --tlsv1.2 -LsSf https://setup.atuin.sh | sh
        else
            print_info "[DRY RUN] Would install atuin"
        fi

        # Idempotent shell configuration
        # Only append activation lines if they don't already exist
        if [ -f "$ZSH_CONFIG" ]; then
            safe_append_to_file 'eval "$(atuin init zsh)"' "$ZSH_CONFIG"
        fi

        # Mark as installed in state tracking
        mark_installed "atuin" "latest"
    fi

    print_success "atuin installed/updated successfully"
}

# Run if not sourced
if ! is_sourced; then
    install_atuin
fi
