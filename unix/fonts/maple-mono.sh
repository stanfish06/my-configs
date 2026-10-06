#!/usr/bin/env bash
curl -L https://github.com/subframe7536/maple-font/releases/latest/download/MapleMono-NF-CN.zip --output ~/.local/share/fonts/tmp.zip
unzip ~/.local/share/fonts/tmp.zip -d ~/.local/share/fonts
rm ~/.local/share/fonts/tmp.zip
rm ~/.local/share/fonts/LICENSE.txt
rm ~/.local/share/fonts/config.json
sudo fc-cache -fv
