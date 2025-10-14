#!/usr/bin/env bash

set -e
sudo apt update
# basic packages
sudo apt install \
  curl \
  git \
  build-essential \
  python3 \
  python3-pip \
  python3-venv \
  zsh \
  tmux \
  nodejs \
  npm

# oh my zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# neovim
curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz
sudo rm -rf /opt/nvim-linux-x86_64
sudo tar -C /opt -xzf nvim-linux-x86_64.tar.gz
# add path+="/opt/nvim-linux-x86_64/bin" to .zshrc
# or, add export PATH="$PATH:/opt/nvim-linux-x86_64/bin" to .bashrc

# rust
curl https://sh.rustup.rs -sSf | sh

# wezterm
curl -fsSL https://apt.fury.io/wez/gpg.key | sudo gpg --yes --dearmor -o /usr/share/keyrings/wezterm-fury.gpg
echo 'deb [trusted=yes] https://apt.fury.io/wez/ * *' | sudo tee /etc/apt/sources.list.d/wezterm.list
sudo chmod 644 /usr/share/keyrings/wezterm-fury.gpg
sudo apt update
sudo apt install wezterm-nightly

# fzf
sudo apt install fzf
# run this later for shell completion
# source <(fzf --zsh)

# copy config files
cp ../wezterm/linux/.wezterm.lua ~
ln -s "$(pwd)" ~/scripts

# clean up
rm *tar.gz
