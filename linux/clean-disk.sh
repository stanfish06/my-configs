#!/bin/bash
# some trash locations
# rm -rf /var/cache/
rm -rf ~/.cache/
journalctl --vacuum-time=7d

# pacman
if command -v "pacman" >/dev/null 2>&1; then
  pacman -Scc --noconfirm
elif command -v "apt" >/dev/null 2>&1; then
  apt autoclean
  apt autoremove
  apt update
fi

