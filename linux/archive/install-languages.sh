#!/usr/bin/env zsh
# do not run as sudo or root
# python, R, js
set -e
sudo apt update
sudo apt install \
  curl \
  python3 \
  python3-pip \
  python3-venv \
  nodejs \
  npm \
  r-base \
  r-base-dev \
  default-jre \
  default-jdk

# rust
if command -v rustup >/dev/null 2>&1; then
    echo "remove old rust"
    rustup self uninstall
fi
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

# julia
if command -v rustup >/dev/null 2>&1; then
    echo "remove old julia"
    juliaup self uninstall
fi
curl -fsSL https://install.julialang.org | sh

# go
# add /usr/local/go/bin to path
go_release=go1.25.3.linux-amd64.tar.gz
wget https://go.dev/dl/$go_release
sudo rm -rf /usr/local/go && sudo tar -C /usr/local -xzf $go_release
rm *tar.gz
