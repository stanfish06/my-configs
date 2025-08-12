#!/bin/bash
# some trash locations
rm -rf /var/cache/
rm -rf ~/.cache/
journalctl --vacuum-time=7d

# pacman
pacman -Scc --noconfirm
