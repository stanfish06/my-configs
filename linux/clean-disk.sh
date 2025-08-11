#/bin/bash
rm -rf /var/cache/
rm -rf ~/.cache/
journalctl --vacuum-time=7d
