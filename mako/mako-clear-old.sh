#!/usr/bin/env bash
makoctl list | jq -r '.data[][] | .id.data' | tail -n +6 | while read -r id; do
    makoctl dismiss -n "$id"
done
