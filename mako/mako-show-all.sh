#!/usr/bin/env bash
CONFIG="${XDG_CONFIG_HOME:-$HOME/.config}/mako/config"
TMP=$(mktemp)
current=$(grep -m1 '^max-visible=' "$CONFIG" | cut -d= -f2)
if [ "$current" -eq 5 ]; then
    sed "s/^max-visible=5/max-visible=1/" "$CONFIG" > "$TMP"
elif [ "$current" -eq 1 ]; then
    sed "s/^max-visible=1/max-visible=-1/" "$CONFIG" > "$TMP"
else
    sed "s/^max-visible=-1/max-visible=5/" "$CONFIG" > "$TMP"
fi
if [ -s "$TMP" ] && [ "$(wc -l < "$TMP")" -eq "$(wc -l < "$CONFIG")" ]; then
    cp "$TMP" "$CONFIG"
    makoctl reload
fi
rm -f "$TMP"
