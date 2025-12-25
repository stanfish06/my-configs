#!/usr/bin/env bash
find ~/Maildir/*/new -type f | while read -r file; do
    dir=$(dirname "$file")
    base=$(basename "$file")
    curdir="${dir%/new}/cur"
    mv "$file" "$curdir/${base}:2,S"
done
