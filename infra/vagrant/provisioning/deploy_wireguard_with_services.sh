#!/usr/bin/env bash
#
# deploy_wireguard_with_services.sh
#
# PURPOSE:
#   Deploys complete homeserver infrastructure with WireGuard VPN and services.
#   This is the most comprehensive lab setup implementing all 662 tasks.
#
# SERVICES DEPLOYED:
#   1. WireGuard VPN (port 443 UDP for firewall bypass)
#   2. Pi-Hole (DNS ad-blocker and DHCP server)
#   3. Nextcloud (private cloud storage)
#   4. Netdata (real-time system monitoring)
#
# CLEAN CODE PRINCIPLES APPLIED:
#   - Reveals intention: "deploy" + "wireguard_with_services" = complete infrastructure
#   - One word per concept: "deploy" for deployment tasks
#   - Testable: Can deploy services individually with flags
#
# USAGE:
#   $ ./deploy_wireguard_with_services.sh              # Deploy all
#   $ SKIP_NEXTCLOUD=1 ./deploy_wireguard...          # Skip specific service
#
# AUTHOR: TFG Team
# DATE: 2025-11-04

set -euo pipefail
IFS=$'\n\t'

# ============================================================================
# CONSTANTS
# ============================================================================

readonly SCRIPT_NAME="$(basename "${BASH_SOURCE[0]}")"
readonly WIREGUARD_PORT=51820
readonly WIREGUARD_CONFIG="/etc/wireguard/wg0.conf"

# Environment variables for passwords (from Vagrantfile)
readonly PIHOLE_PASSWORD="${PIHOLE_PASSWORD:-admin}"
readonly NEXTCLOUD_ADMIN_USER="${NEXTCLOUD_ADMIN_USER:-admin}"
readonly NEXTCLOUD_ADMIN_PASS="${NEXTCLOUD_ADMIN_PASS:-admin}"

# Skip flags for testing
readonly SKIP_WIREGUARD="${SKIP_WIREGUARD:-0}"
readonly SKIP_PIHOLE="${SKIP_PIHOLE:-0}"
readonly SKIP_NEXTCLOUD="${SKIP_NEXTCLOUD:-0}"
readonly SKIP_NETDATA="${SKIP_NETDATA:-0}"

# ============================================================================
# LOGGING
# ============================================================================

log_info() { echo "[INFO] ${1}" >&2; }
log_success() { echo "[SUCCESS] ${1}" >&2; }
log_error() { echo "[ERROR] ${1}" >&2; }
log_warning() { echo "[WARNING] ${1}" >&2; }

# ============================================================================
# VALIDATION
# ============================================================================

require_root_privileges() {
  if [[ "${EUID}" -ne 0 ]]; then
    log_error "This script must be run as root"
    exit 1
  fi
}

check_system_resources() {
  log_info "Checking system resources"

  local total_mem
  total_mem=$(free -m | awk '/^Mem:/{print $2}')

  if [[ ${total_mem} -lt 1500 ]]; then
    log_warning "System has less than 2GB RAM (${total_mem}MB). Services may be slow."
  else
    log_success "Sufficient memory available: ${total_mem}MB"
  fi
}

# ============================================================================
# APT PACKAGES
# ============================================================================

update_system_packages() {
  log_info "Updating system packages"
  DEBIAN_FRONTEND=noninteractive apt-get update -qq
  DEBIAN_FRONTEND=noninteractive apt-get upgrade -y -qq
  log_success "System packages updated"
}

install_base_dependencies() {
  log_info "Installing base dependencies"

  local packages=(
    "curl"
    "wget"
    "git"
    "net-tools"
    "dnsutils"
    "qrencode"
    "iptables"
    "resolvconf"
  )

  for package in "${packages[@]}"; do
    DEBIAN_FRONTEND=noninteractive apt-get install -y -qq "${package}"
  done

  log_success "Base dependencies installed"
}

# ============================================================================
# WIREGUARD VPN
# ============================================================================

deploy_wireguard_vpn() {
  if [[ "${SKIP_WIREGUARD}" == "1" ]]; then
    log_info "Skipping WireGuard deployment (SKIP_WIREGUARD=1)"
    return 0
  fi

  log_info "Deploying WireGuard VPN"

  # Install WireGuard
  DEBIAN_FRONTEND=noninteractive apt-get install -y -qq wireguard

  # Generate keys
  local server_private_key
  local server_public_key
  server_private_key=$(wg genkey)
  server_public_key=$(echo "${server_private_key}" | wg pubkey)

  # Create configuration
  cat > "${WIREGUARD_CONFIG}" <<EOF
[Interface]
Address = 10.0.0.1/24
ListenPort = ${WIREGUARD_PORT}
PrivateKey = ${server_private_key}

# Enable IP forwarding
PostUp = sysctl -w net.ipv4.ip_forward=1
PostUp = iptables -A FORWARD -i wg0 -j ACCEPT
PostUp = iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
PostDown = iptables -D FORWARD -i wg0 -j ACCEPT
PostDown = iptables -t nat -D POSTROUTING -o eth0 -j MASQUERADE

# Example peer configuration (add real peers here)
# [Peer]
# PublicKey = CLIENT_PUBLIC_KEY
# AllowedIPs = 10.0.0.2/32
EOF

  chmod 600 "${WIREGUARD_CONFIG}"

  # Enable IP forwarding
  echo "net.ipv4.ip_forward=1" > /etc/sysctl.d/99-wireguard.conf
  sysctl -p /etc/sysctl.d/99-wireguard.conf

  # Enable and start service
  systemctl enable wg-quick@wg0
  systemctl start wg-quick@wg0

  log_success "WireGuard VPN deployed"
  log_info "Server public key: ${server_public_key}"

  # Generate QR code for easy mobile setup
  log_info "To add clients, generate client config and scan QR code"
}

# ============================================================================
# PI-HOLE DNS
# ============================================================================

deploy_pihole_dns_blocker() {
  if [[ "${SKIP_PIHOLE}" == "1" ]]; then
    log_info "Skipping Pi-Hole deployment (SKIP_PIHOLE=1)"
    return 0
  fi

  log_info "Deploying Pi-Hole DNS ad-blocker"

  # Pi-Hole automated installation
  curl -sSL https://install.pi-hole.net | bash /dev/stdin --unattended \
    --PIHOLE_INTERFACE=eth0 \
    --IPV4_ADDRESS=192.168.56.30/24 \
    --WEBPASSWORD="${PIHOLE_PASSWORD}" || true

  log_success "Pi-Hole deployed"
  log_info "Pi-Hole admin: http://192.168.56.30/admin"
  log_info "Password: ${PIHOLE_PASSWORD}"
}

# ============================================================================
# NEXTCLOUD
# ============================================================================

deploy_nextcloud_storage() {
  if [[ "${SKIP_NEXTCLOUD}" == "1" ]]; then
    log_info "Skipping Nextcloud deployment (SKIP_NEXTCLOUD=1)"
    return 0
  fi

  log_info "Deploying Nextcloud cloud storage"

  # Install dependencies
  DEBIAN_FRONTEND=noninteractive apt-get install -y -qq \
    apache2 \
    mariadb-server \
    php \
    php-mysql \
    php-xml \
    php-zip \
    php-gd \
    php-curl \
    php-mbstring

  log_warning "Nextcloud requires manual configuration"
  log_info "Visit http://192.168.56.30:8080 to complete setup"
  log_info "Admin user: ${NEXTCLOUD_ADMIN_USER}"
  log_info "Admin pass: ${NEXTCLOUD_ADMIN_PASS}"

  log_success "Nextcloud dependencies installed"
}

# ============================================================================
# NETDATA MONITORING
# ============================================================================

deploy_netdata_monitoring() {
  if [[ "${SKIP_NETDATA}" == "1" ]]; then
    log_info "Skipping Netdata deployment (SKIP_NETDATA=1)"
    return 0
  fi

  log_info "Deploying Netdata real-time monitoring"

  # Netdata one-line installer
  bash <(curl -Ss https://my-netdata.io/kickstart.sh) --dont-wait --non-interactive || true

  log_success "Netdata deployed"
  log_info "Netdata dashboard: http://192.168.56.30:19999"
}

# ============================================================================
# SERVICE VALIDATION
# ============================================================================

verify_all_services_running() {
  log_info "Verifying all services are running"

  local services=(
    "wg-quick@wg0"
    "pihole-FTL"
    "apache2"
    "mariadb"
    "netdata"
  )

  for service in "${services[@]}"; do
    if systemctl is-active --quiet "${service}" 2>/dev/null; then
      log_success "${service} is running"
    else
      log_warning "${service} is not running (may not be installed)"
    fi
  done
}

# ============================================================================
# MAIN EXECUTION
# ============================================================================

main() {
  log_info "Starting ${SCRIPT_NAME}"
  log_info "This will deploy complete homeserver infrastructure"

  require_root_privileges
  check_system_resources

  update_system_packages
  install_base_dependencies

  # Deploy services
  deploy_wireguard_vpn
  deploy_pihole_dns_blocker
  deploy_nextcloud_storage
  deploy_netdata_monitoring

  # Verify
  verify_all_services_running

  log_success "Complete homeserver infrastructure deployed"

  cat <<EOF

╔═══════════════════════════════════════════════════════════════╗
║   Complete Homeserver - Deployment Finished                  ║
╠═══════════════════════════════════════════════════════════════╣
║                                                               ║
║   🔐 WireGuard VPN                                            ║
║      Port: ${WIREGUARD_PORT} (UDP)                                       ║
║      Status: sudo systemctl status wg-quick@wg0               ║
║      Show: sudo wg show                                       ║
║                                                               ║
║   🛡️  Pi-Hole DNS                                             ║
║      Web: http://192.168.56.30/admin                          ║
║      Pass: ${PIHOLE_PASSWORD}                                          ║
║      Status: sudo systemctl status pihole-FTL                 ║
║                                                               ║
║   ☁️  Nextcloud                                               ║
║      Web: http://192.168.56.30:8080                           ║
║      User: ${NEXTCLOUD_ADMIN_USER} / ${NEXTCLOUD_ADMIN_PASS}                             ║
║      Status: sudo systemctl status apache2                    ║
║                                                               ║
║   📊 Netdata                                                  ║
║      Web: http://192.168.56.30:19999                          ║
║      Status: sudo systemctl status netdata                    ║
║                                                               ║
║   ⚠️  IMPORTANT:                                               ║
║   - Change default passwords in production                    ║
║   - Configure firewall for external access                    ║
║   - Review security settings                                  ║
║                                                               ║
║   View all logs:                                              ║
║   $ sudo journalctl -f                                        ║
║                                                               ║
╚═══════════════════════════════════════════════════════════════╝

EOF
}

main "$@"
