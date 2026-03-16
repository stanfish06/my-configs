#!/usr/bin/env bash
makoctl list | grep -oP '^Notification \K[0-9]+' | tail -n +6 | while read -r id; do
    makoctl dismiss -n "$id"
done
