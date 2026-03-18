#!/usr/bin/env bash
if [ "$1" = "$FOCUSED_WORKSPACE" ]; then
    perl -e 'select(undef, undef, undef, 0.01)'
    sketchybar --set $NAME drawing=on
else
    sketchybar --set $NAME drawing=off
fi
