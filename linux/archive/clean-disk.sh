#!/bin/bash
# some trash locations
# rm -rf /var/cache/
rm -rf ~/.cache/
sudo journalctl --vacuum-time=7d

# pacman
if command -v "pacman" >/dev/null 2>&1; then
  sudo pacman -Scc --noconfirm
elif command -v "apt" >/dev/null 2>&1; then
  sudo apt autoclean
  sudo apt autoremove
  sudo apt update
fi

