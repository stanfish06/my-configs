#/usr/bin/env zsh
set -e
sudo apt update
sudo apt install \
  autoconf \
  libconfuse-dev \
  libyajl-dev \
  libasound2-dev \
  libiw-dev \
  asciidoc \
  libpulse-dev \
  libnl-genl-3-dev \
  meson
sudo apt install i3status
