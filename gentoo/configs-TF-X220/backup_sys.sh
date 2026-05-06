#!/usr/bin/env bash
# only to backup sys configs
# use links for home configs
# emerge
emerge --info > emerge-info.txt
# var
cp /var/lib/portage/world ./var-lib-portage/
# etc
cp -r /etc/X11/xorg.conf.d ./etc-TF-X220/X11/
cp /etc/portage/make.conf ./etc-TF-X220/portage/
cp -r /etc/portage/package.use ./etc-TF-X220/portage/
cp -r /etc/portage/package.license ./etc-TF-X220/portage/
cp /etc/fstab ./etc-TF-X220/
