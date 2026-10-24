#!/usr/bin/env sh
#   ./run.sh                                  # every host in inventory.yml
#   ./run.sh -l oracle-1                      # one host
#   ./run.sh -l greatlakes --skip-tags sudo   # user-level roles only (no root)
#   ./run.sh -t toolchain                     # one role
#   PLAYBOOK=cloud.yml ./run.sh -i <inv>      # another playbook (cloud/cloud uses this)
set -eu
cd "$(dirname "$0")"
uvx --from ansible-core ansible-galaxy collection install -r requirements.yml >/dev/null
exec uvx --from ansible-core ansible-playbook "${PLAYBOOK:-site.yml}" "$@"
