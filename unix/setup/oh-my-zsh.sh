#!/usr/bin/env bash
# Install Oh My Zsh

set -e

# Source common functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../lib/common.sh
source "${SCRIPT_DIR}/../lib/common.sh"

OMZ_DIR="$HOME/.oh-my-zsh"

install_oh_my_zsh() {
    print_info "Installing Oh My Zsh..."

    if [[ -d "$OMZ_DIR" ]]; then
        print_warning "Oh My Zsh is already installed"
        return 0
    fi

    if [[ "$DRY_RUN" == "true" ]]; then
        print_info "[DRY RUN] Would install Oh My Zsh from raw.githubusercontent.com/ohmyzsh"
        return 0
    fi

    KEEP_ZSHRC=yes RUNZSH=no CHSH=no \
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

    print_success "Oh My Zsh installed successfully"
}

install_zsh_plugins() {
    local plugins_dir="$OMZ_DIR/custom/plugins"
    local name url
    for spec in \
        "zsh-vi-mode https://github.com/jeffreytse/zsh-vi-mode.git" \
        "zsh-autosuggestions https://github.com/zsh-users/zsh-autosuggestions.git" \
        "zsh-syntax-highlighting https://github.com/zsh-users/zsh-syntax-highlighting.git"
    do
        name="${spec%% *}"
        url="${spec#* }"
        if [[ -d "$plugins_dir/$name" ]]; then
            print_info "$name already present"
            continue
        fi
        run_cmd git clone --depth 1 "$url" "$plugins_dir/$name"
    done
    print_success "zsh plugins installed"
}

# Run if not sourced
if ! is_sourced; then
    install_oh_my_zsh
    install_zsh_plugins
fi
