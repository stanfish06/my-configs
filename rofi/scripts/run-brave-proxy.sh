#!/usr/bin/env bash

CONFIG="$(dirname "$(readlink -f "$0")")/../config.rasi"

scheme=$(printf "socks5\nhttp\n" | rofi -dmenu -i -p "Proxy scheme" -theme "$CONFIG")
[ -z "$scheme" ] && exit 0

port=$(rofi -dmenu -p "Local proxy port" -theme "$CONFIG" -theme-str 'mainbox { children: [inputbar]; } listview { enabled: false; } inputbar { padding: 0; } prompt { padding: 6 6 6 10; } entry { padding: 6 10 6 0; }' < /dev/null)
[ -z "$port" ] && exit 0

brave --proxy-server="$scheme://127.0.0.1:$port" &
