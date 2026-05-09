#!/usr/bin/env bash

CONFIG="$(dirname "$(readlink -f "$0")")/../config.rasi"

choice=$(printf "hiddify-app\n" | rofi -dmenu -i -p "Proxy client" -theme "$CONFIG")

[ -z "$choice" ] && exit 0

case "$choice" in
    hiddify-app) hiddify-app & ;;
esac
