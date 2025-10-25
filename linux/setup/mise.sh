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
        echo "mise exists; do self update"
        mise self-update
        echo "update autocompletion"
        if [ -f "$BASH_CONFIG" ]; then
            install_packages bash-completion
            mkdir -p ~/.local/share/bash-completion/completions
            mise completion bash --include-bash-completion-lib > ~/.local/share/bash-completion/completions/mise
        fi
        if [ -f "$ZSH_CONFIG" ]; then
            echo "for zsh, add mise to oh-my-zsh plugin list"
        fi
    else
        print_info "Installing mise-en-place..."
        # Update and install
        update_system
        curl https://mise.run | sh
        if [ -f "$BASH_CONFIG" ]; then
            echo 'eval "$(~/.local/bin/mise activate bash)"' >> ~/.bashrc
        fi
        if [ -f "$ZSH_CONFIG" ]; then
            echo 'eval "$(~/.local/bin/mise activate zsh)"' >> ~/.zshrc
        fi
    fi

    print_success "mise-en-place installed/updated successfully"
}

# Run if not sourced
if ! is_sourced; then
    install_mise
fi
