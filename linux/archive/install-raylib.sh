#!/usr/bin/env zsh
sudo apt update
sudo apt install \
  libasound2-dev \
  libx11-dev \
  libxrandr-dev \
  libxi-dev \
  libgl1-mesa-dev \
  libglu1-mesa-dev \
  libxcursor-dev \
  libxinerama-dev \
  libwayland-dev \
  libxkbcommon-dev
git clone https://github.com/raylib-extras/raylib-quickstart.git && cd raylib-quickstart && cd build && ./premake5 gmake && cd .. && make && echo "done"
