#!/bin/bash

cat <<EOF >> /etc/resolv.conf
nameserver 8.8.8.8
nameserver 1.1.1.1
EOF
