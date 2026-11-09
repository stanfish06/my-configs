#!/bin/sh
choice="$(printf "xfce\ni3\nherbstluftwm\nnone\n" | dmenu -p "Start: ")"

set_trackpoint() {
    xinput set-prop \
        "TPPS/2 IBM TrackPoint" "libinput Accel Speed" \
        -0.4 2>/dev/null
}

case "$choice" in
    xfce)
        set_trackpoint
        exec startxfce4
        ;;
    i3)
        set_trackpoint
        exec dbus-launch --exit-with-session i3
        ;;
    herbstluftwm)
        set_trackpoint
        exec dbus-launch --exit-with-session herbstluftwm --locked
        ;;
    *)
        exit 0
        ;;
esac
