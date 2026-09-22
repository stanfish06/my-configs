#!/usr/bin/env bash

set -euo pipefail

GITHUB_USER="stanfish06"
REPO_NAME="my-configs"
SOURCE_DIR="$HOME/.local/share/chezmoi"
BIN_DIR="$HOME/.local/bin"
SSH_KEY="$HOME/.ssh/id_ed25519"

USE_SUDO=auto
DRY_RUN=false

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; BLUE='\033[0;34m'; NC='\033[0m'
info()    { echo -e "${BLUE}[info]${NC} $*"; }
ok()      { echo -e "${GREEN}[info]${NC} $*"; }
warn()    { echo -e "${YELLOW}[warn]${NC} $*" >&2; }
die()     { echo -e "${RED}[error]${NC} $*" >&2; exit 1; }
step()    { echo; echo -e "${BLUE}=== $* ===${NC}"; }
run()     { if $DRY_RUN; then info "[dry-run] $*"; else "$@"; fi; }
have()    { command -v "$1" >/dev/null 2>&1; }

usage() {
    cat <<EOF
Usage: bootstrap.sh [OPTIONS]

  --no-sudo        skip system packages, locale and login shell (HPC, shared hosts)
  --sudo           fail instead of skipping when sudo is unavailable
  --dry-run        print every command instead of running it
  -h, --help       this text

  bash -c "\$(curl -fsSL https://raw.githubusercontent.com/$GITHUB_USER/$REPO_NAME/master/bootstrap.sh)"
EOF
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        --no-sudo) USE_SUDO=false; shift ;;
        --sudo) USE_SUDO=true; shift ;;
        --dry-run) DRY_RUN=true; shift ;;
        -h|--help) usage; exit 0 ;;
        *) usage; die "unknown option: $1" ;;
    esac
done

[[ ${EUID:-$(id -u)} -eq 0 ]] && die "run as your user, not root; sudo is requested where needed"

if [[ -f /etc/NIXOS || -L /run/current-system ]]; then
    die "nix-managed system: packages and dotfiles come from the flake + home-manager repo, not this script"
fi

case "$(uname -s)" in
    Darwin) OS=macos ;;
    Linux)  OS=linux ;;
    *)      die "unsupported OS: $(uname -s)" ;;
esac

if [[ $OS == macos ]]; then
    for b in /opt/homebrew/bin/brew /usr/local/bin/brew; do
        [[ -x $b ]] && eval "$("$b" shellenv)" && break
    done
    have brew && PM=brew || PM=none
elif have apt-get; then PM=apt
elif have pacman; then PM=pacman
elif have dnf; then PM=dnf
else PM=none
fi

if [[ $USE_SUDO == auto ]]; then
    if [[ $OS == macos ]]; then
        USE_SUDO=false
    elif have sudo && sudo -n true 2>/dev/null; then
        USE_SUDO=true
    elif have sudo && [[ -t 0 ]] && sudo -v 2>/dev/null; then
        USE_SUDO=true
    else
        warn "sudo unavailable or refused; skipping the system layer (rerun with --sudo after fixing, or pass --no-sudo to silence)"
        USE_SUDO=false
    fi
elif [[ $USE_SUDO == true ]] && [[ $OS == linux ]]; then
    have sudo || die "--sudo given but sudo is not installed"
    sudo -v || die "--sudo given but sudo refused"
fi

export PATH="$BIN_DIR:$HOME/.local/share/mise/shims:$PATH"

step "1/7 prerequisites (git, curl)"

pkg_install() {
    case "$PM" in
        brew)   run brew install "$@" ;;
        apt)    run sudo apt-get install -y "$@" ;;
        pacman) run sudo pacman -S --noconfirm --needed "$@" ;;
        dnf)    run sudo dnf install -y "$@" ;;
        *)      return 1 ;;
    esac
}

missing=""
have git  || missing="$missing git"
have curl || missing="$missing curl"
if [[ -n $missing ]]; then
    if [[ $PM == brew ]] || $USE_SUDO; then
        [[ $PM == apt ]] && run sudo apt-get update -qq
        # shellcheck disable=SC2086
        pkg_install $missing || die "could not install:$missing"
    elif ! have curl; then
        die "curl is required and cannot be installed without sudo"
    else
        warn "git missing and no sudo: chezmoi will clone with its built-in git; oh-my-zsh and tmux plugins need real git and will be skipped"
    fi
else
    ok "git and curl present"
fi

step "2/7 chezmoi init"

if ! have chezmoi; then
    info "installing chezmoi to $BIN_DIR"
    run mkdir -p "$BIN_DIR"
    if $DRY_RUN; then
        info "[dry-run] sh -c \"\$(curl -fsLS get.chezmoi.io)\" -- -b $BIN_DIR"
    else
        sh -c "$(curl -fsLS get.chezmoi.io)" -- -b "$BIN_DIR"
    fi
else
    ok "chezmoi present: $(chezmoi --version | head -1)"
fi

if [[ ! -f $SSH_KEY ]]; then
    info "generating $SSH_KEY"
    run mkdir -p "$HOME/.ssh"
    run chmod 700 "$HOME/.ssh"
    run ssh-keygen -t ed25519 -N "" -C "$(id -un)@$(hostname -s 2>/dev/null || hostname)" -f "$SSH_KEY"
fi

GITHUB_SSH_OK=false
if [[ -f $SSH_KEY ]]; then
    ssh -o BatchMode=yes -o ConnectTimeout=10 -o StrictHostKeyChecking=accept-new -o ControlMaster=no -o ControlPath=none -T git@github.com >/dev/null 2>&1 && rc=0 || rc=$?
    [[ $rc -eq 1 ]] && GITHUB_SSH_OK=true
fi
if $GITHUB_SSH_OK; then
    REPO_URL="git@github.com:$GITHUB_USER/$REPO_NAME.git"
    ok "github ssh key registered"
else
    REPO_URL="https://github.com/$GITHUB_USER/$REPO_NAME.git"
    warn "github ssh key not registered; cloning over https"
fi
if $GITHUB_SSH_OK && have git; then
    EXCLUDE_EXTERNALS=()
else
    EXCLUDE_EXTERNALS=(--exclude externals)
    warn "skipping externals (nvim, kitty, emacs): need registered github key and git"
fi

if [[ -d $SOURCE_DIR/.git ]]; then
    ok "source dir exists: $SOURCE_DIR"
    if $GITHUB_SSH_OK && [[ "$(git -C "$SOURCE_DIR" remote get-url origin 2>/dev/null)" == https://* ]]; then
        info "switching origin to ssh"
        run git -C "$SOURCE_DIR" remote set-url origin "$REPO_URL"
    fi
    run chezmoi init
else
    info "cloning $REPO_URL -> $SOURCE_DIR"
    run chezmoi init --use-builtin-git auto "$REPO_URL"
fi

UNIX="$SOURCE_DIR/unix/setup.sh"
$DRY_RUN || [[ -x $UNIX ]] || die "expected $UNIX after clone"

step "3/7 system packages (unix/setup.sh basic)"

if [[ $PM == brew ]] || $USE_SUDO; then
    if [[ -x $UNIX ]]; then
        DRY_RUN=$DRY_RUN "$UNIX" basic
    else
        info "[dry-run] $UNIX basic"
    fi

    if [[ $OS == linux ]]; then
        if ! locale -a 2>/dev/null | grep -qi '^en_US\.utf-\?8$'; then
            info "generating en_US.UTF-8 locale"
            case "$PM" in
                apt)
                    run sudo apt-get install -y locales
                    run sudo sed -i 's/^# *en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen
                    run sudo locale-gen
                    ;;
                pacman)
                    run sudo sed -i 's/^#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen
                    run sudo locale-gen
                    ;;
                dnf)
                    run sudo dnf install -y glibc-langpack-en
                    ;;
            esac
        else
            ok "en_US.UTF-8 locale present"
        fi
    fi
else
    warn "skipped (no sudo)"
fi

step "4/7 oh-my-zsh + plugins (unix/setup.sh shell)"

if have zsh && have git; then
    if [[ -x $UNIX ]]; then
        DRY_RUN=$DRY_RUN "$UNIX" shell
    else
        info "[dry-run] $UNIX shell"
    fi
else
    warn "zsh or git missing; skipped. .zshrc will complain until oh-my-zsh exists"
fi

if have zsh && [[ $OS == linux ]]; then
    zsh_path="$(command -v zsh)"
    current_shell="$(getent passwd "$(id -un)" 2>/dev/null | cut -d: -f7 || true)"
    if [[ $current_shell == "$zsh_path" ]]; then
        ok "login shell already $zsh_path"
    elif $USE_SUDO; then
        info "setting login shell to $zsh_path"
        run sudo chsh -s "$zsh_path" "$(id -un)"
    else
        warn "login shell is $current_shell; run: chsh -s $zsh_path"
    fi
fi

step "5/7 chezmoi apply"

run chezmoi apply --force "$HOME/.ssh"
run chezmoi apply --force "${EXCLUDE_EXTERNALS[@]}"

step "6/7 mise + tools"

if ! have mise; then
    info "installing mise to $BIN_DIR"
    if $DRY_RUN; then
        info "[dry-run] curl -fsSL https://mise.run | MISE_INSTALL_PATH=$BIN_DIR/mise sh"
    else
        curl -fsSL https://mise.run | MISE_INSTALL_PATH="$BIN_DIR/mise" sh
    fi
else
    ok "mise present: $(mise --version 2>/dev/null | head -1)"
fi

if [[ -f $HOME/.config/mise/config.toml ]] || $DRY_RUN; then
    mem_kb=$(awk '/MemTotal/ {print $2}' /proc/meminfo 2>/dev/null || echo 0)
    if [[ ${mem_kb:-0} -gt 0 && ${mem_kb:-0} -lt 2000000 ]]; then
        export MISE_JOBS=2
        info "MISE_JOBS=2 (low memory)"
    fi
    run mise install -y bun node uv
    run mise install -y || warn "some tools failed; see 'mise ls --missing' below"
else
    warn "$HOME/.config/mise/config.toml missing after apply; skipping tool install"
fi

step "7/7 tmux plugins + verify"

if have git && have tmux; then
    run mise run tpm-install 2>/dev/null || run git clone https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
    if [[ -f $HOME/.tmux.conf && ! -d $HOME/.tmux/plugins/tmux-sensible ]]; then
        run "$HOME/.tmux/plugins/tpm/bin/install_plugins"
    else
        ok "tmux plugins present"
    fi
else
    warn "git or tmux missing; tmux plugins skipped"
fi

echo
$DRY_RUN && { ok "dry run complete"; exit 0; }

status="$(chezmoi status "${EXCLUDE_EXTERNALS[@]}" 2>&1 || true)"
if [[ -z $status ]]; then
    ok "chezmoi: all managed files up to date"
else
    warn "chezmoi: pending changes"; echo "$status"
fi

missing_tools="$(mise ls --missing 2>/dev/null || true)"
if [[ -z $missing_tools ]]; then
    ok "mise: every tool in config.toml installed"
else
    warn "mise: tools not installed"; echo "$missing_tools"
fi

if ! $GITHUB_SSH_OK && [[ -f $SSH_KEY.pub ]]; then
    echo
    warn "add this key to github (auth + signing), then rerun bootstrap.sh to pull externals over ssh:"
    cat "$SSH_KEY.pub"
fi

echo
ok "done. log out and back in (or run 'zsh') to pick up the new shell"
