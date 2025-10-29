#!/usr/bin/env bash
# Install mise

set -e

# Source common functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../lib/common.sh
source "${SCRIPT_DIR}/../lib/common.sh"

ZSH_CONFIG=~/.zshrc
BASH_CONFIG=~/.bashrc

install_mise() {
    if command -v mise >/dev/null 2>&1; then
        print_info "mise already exists, performing self-update..."
        mise self-update

        print_info "Updating autocompletion..."
        if [ -f "$BASH_CONFIG" ]; then
            install_packages bash-completion
            mkdir -p ~/.local/share/bash-completion/completions
            mise completion bash --include-bash-completion-lib > ~/.local/share/bash-completion/completions/mise
        fi
        if [ -f "$ZSH_CONFIG" ]; then
            print_info "For zsh, add mise to oh-my-zsh plugin list"
        fi
    else
        print_info "Installing mise-en-place..."
        # Update and install
        update_system

        # Download and install mise
        if [[ "$DRY_RUN" != "true" ]]; then
            curl https://mise.run | sh
        else
            print_info "[DRY RUN] Would install mise from https://mise.run"
        fi

        # Idempotent shell configuration
        # Only append activation lines if they don't already exist
        if [ -f "$BASH_CONFIG" ]; then
            safe_append_to_file 'eval "$(~/.local/bin/mise activate bash)"' "$BASH_CONFIG"
        fi

        if [ -f "$ZSH_CONFIG" ]; then
            safe_append_to_file 'eval "$(~/.local/bin/mise activate zsh)"' "$ZSH_CONFIG"
        fi

        # Mark as installed in state tracking
        mark_installed "mise" "latest"
    fi

    print_success "mise-en-place installed/updated successfully"
}

# Run if not sourced
if ! is_sourced; then
    install_mise
fi
