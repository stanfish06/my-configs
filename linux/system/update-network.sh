#!/usr/bin/env bash
# Update network DNS settings

set -e

# Source common functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../lib/common.sh
source "${SCRIPT_DIR}/../lib/common.sh"

update_network_dns() {
    print_warning "This script will modify DNS settings"
    print_info "Target DNS servers: Google (8.8.8.8) and Cloudflare (1.1.1.1)"

    # Check if systemd-resolved is managing DNS
    if systemctl is-active --quiet systemd-resolved 2>/dev/null; then
        print_info "Detected systemd-resolved, configuring permanent DNS..."

        # Backup existing resolved.conf
        backup_file /etc/systemd/resolved.conf

        if [[ "$DRY_RUN" == "true" ]]; then
            print_info "[DRY RUN] Would configure systemd-resolved"
            return 0
        fi

        # Configure systemd-resolved
        sudo tee /etc/systemd/resolved.conf > /dev/null <<EOF
[Resolve]
DNS=8.8.8.8 1.1.1.1
FallbackDNS=8.8.4.4 1.0.0.1
DNSSEC=allow-downgrade
DNSOverTLS=no
EOF

        # Restart systemd-resolved
        sudo systemctl restart systemd-resolved

        print_success "DNS configured via systemd-resolved (permanent)"
    elif [[ -L /etc/resolv.conf ]]; then
        print_warning "/etc/resolv.conf is a symlink, DNS changes may not persist"
        print_info "Consider using NetworkManager or netplan for permanent DNS configuration"

        # Still attempt to update but warn user
        backup_file /etc/resolv.conf

        if [[ "$DRY_RUN" == "true" ]]; then
            print_info "[DRY RUN] Would append to /etc/resolv.conf"
            return 0
        fi

        # Check if DNS entries already exist
        if line_exists_in_file "nameserver 8.8.8.8" /etc/resolv.conf; then
            print_info "DNS entries already present in /etc/resolv.conf"
        else
            sudo tee -a /etc/resolv.conf > /dev/null <<EOF
nameserver 8.8.8.8
nameserver 1.1.1.1
EOF
            print_success "DNS temporarily updated (may be overwritten by DHCP)"
        fi
    else
        print_info "Configuring DNS via /etc/resolv.conf..."

        backup_file /etc/resolv.conf

        if [[ "$DRY_RUN" == "true" ]]; then
            print_info "[DRY RUN] Would append to /etc/resolv.conf"
            return 0
        fi

        # Check if DNS entries already exist
        if line_exists_in_file "nameserver 8.8.8.8" /etc/resolv.conf; then
            print_info "DNS entries already present in /etc/resolv.conf"
        else
            sudo tee -a /etc/resolv.conf > /dev/null <<EOF
nameserver 8.8.8.8
nameserver 1.1.1.1
EOF
            print_success "DNS updated"
        fi
    fi

    print_info "Current DNS configuration:"
    if systemctl is-active --quiet systemd-resolved 2>/dev/null; then
        resolvectl status | grep "DNS Servers" || cat /etc/resolv.conf
    else
        cat /etc/resolv.conf
    fi
}

# Run if not sourced
if ! is_sourced; then
    update_network_dns
fi
