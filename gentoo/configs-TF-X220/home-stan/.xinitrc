#!/bin/sh
choice="$(printf "xfce\ni3\nnone\n" | dmenu -p "Start: ")"

case "$choice" in
    xfce)
        exec startxfce4
        ;;
    i3)
        exec dbus-launch --exit-with-session i3
        ;;
    *)
        exit 0
        ;;
esac
