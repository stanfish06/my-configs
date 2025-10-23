#!/usr/bin/env bash
# Update network DNS settings

set -e

# Source common functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../lib/common.sh
source "${SCRIPT_DIR}/../lib/common.sh"

update_network_dns() {
    print_warning "This script will modify /etc/resolv.conf"
    print_info "Adding Google DNS (8.8.8.8) and Cloudflare DNS (1.1.1.1)..."
    
    sudo tee -a /etc/resolv.conf > /dev/null <<EOF
nameserver 8.8.8.8
nameserver 1.1.1.1
EOF
    
    print_success "DNS settings updated"
    print_info "Current DNS configuration:"
    cat /etc/resolv.conf
}

# Run if not sourced
if ! is_sourced; then
    update_network_dns
fi
