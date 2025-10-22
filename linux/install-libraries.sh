#!/usr/bin/env zsh
set -e
# libaries
sudo apt update
sudo apt install \
  libx11-dev \
  libxinerama-dev \
  libxft-dev \
  libopenblas-dev \
  libsuitesparse-dev
