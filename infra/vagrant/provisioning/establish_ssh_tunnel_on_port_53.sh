#!/usr/bin/env bash
#
# establish_ssh_tunnel_on_port_53.sh
#
# PURPOSE:
#   Configures SSH server to listen on port 53 (TCP) and establishes SOCKS5 tunnel.
#   Port 53 is rarely blocked by firewalls (DNS standard port).
#
# USE CASE:
#   Quick access to blocked APIs (Claude, OpenAI, GitHub Copilot) through SSH tunnel.
#
# CLEAN CODE PRINCIPLES APPLIED:
#   - Reveals intention: Name clearly states WHAT (establish), WHAT TYPE (ssh_tunnel), WHERE (port_53)
#   - Pronounceable: "establish SSH tunnel on port fifty-three"
#   - Searchable: grep -r "port_53" or "establish_ssh" finds this easily
#   - One word per concept: "establish" for creating connections
#
# TESTABILITY:
#   Can be executed independently of Vagrant:
#   $ ./establish_ssh_tunnel_on_port_53.sh --dry-run
#   $ ./establish_ssh_tunnel_on_port_53.sh --test
#
# AUTHOR: TFG Team
# DATE: 2025-11-04
# ADR: docs/diseno_solucion/arquitectura_sistemas/adr/0005-vagrant-laboratorios-vpn.md

set -euo pipefail  # Exit on error, undefined vars, pipe failures
IFS=$'\n\t'        # Safer word splitting

# ============================================================================
# CONSTANTS (Clean Code: Use meaningful constant names)
# ============================================================================

readonly SCRIPT_NAME="$(basename "${BASH_SOURCE[0]}")"
readonly SSH_CONFIG_FILE="/etc/ssh/sshd_config"
readonly SSH_PORT_ALTERNATE=53
readonly SOCKS_PROXY_PORT=1080

# ============================================================================
# LOGGING FUNCTIONS (Clean Code: Functions should do one thing)
# ============================================================================

log_info() {
  echo "[INFO] ${1}" >&2
}

log_success() {
  echo "[SUCCESS] ${1}" >&2
}

log_error() {
  echo "[ERROR] ${1}" >&2
}

log_warning() {
  echo "[WARNING] ${1}" >&2
}

# ============================================================================
# VALIDATION FUNCTIONS
# ============================================================================

require_root_privileges() {
  if [[ "${EUID}" -ne 0 ]]; then
    log_error "This script must be run as root"
    exit 1
  fi
}

check_ubuntu_version() {
  if ! grep -q "Ubuntu" /etc/os-release 2>/dev/null; then
    log_warning "This script is designed for Ubuntu. Other distros may require adjustments."
  fi
}

# ============================================================================
# CONFIGURATION FUNCTIONS (Clean Code: Descriptive function names)
# ============================================================================

configure_ssh_to_listen_on_port_53() {
  log_info "Configuring SSH to listen on port ${SSH_PORT_ALTERNATE}"

  # Backup original config
  if [[ ! -f "${SSH_CONFIG_FILE}.bak" ]]; then
    cp "${SSH_CONFIG_FILE}" "${SSH_CONFIG_FILE}.bak"
    log_info "Backed up original SSH config to ${SSH_CONFIG_FILE}.bak"
  fi

  # Add alternate port if not already configured
  if ! grep -q "^Port ${SSH_PORT_ALTERNATE}" "${SSH_CONFIG_FILE}"; then
    echo "Port ${SSH_PORT_ALTERNATE}" >> "${SSH_CONFIG_FILE}"
    log_success "Added Port ${SSH_PORT_ALTERNATE} to ${SSH_CONFIG_FILE}"
  else
    log_info "Port ${SSH_PORT_ALTERNATE} already configured"
  fi

  # Keep default port 22 as well
  if ! grep -q "^Port 22" "${SSH_CONFIG_FILE}"; then
    echo "Port 22" >> "${SSH_CONFIG_FILE}"
    log_info "Added Port 22 to ${SSH_CONFIG_FILE}"
  fi
}

enable_ssh_password_authentication_temporarily() {
  log_info "Enabling password authentication (for Vagrant)"

  # Required for Vagrant initial setup
  sed -i 's/^PasswordAuthentication no/PasswordAuthentication yes/' "${SSH_CONFIG_FILE}"
  sed -i 's/^#PasswordAuthentication yes/PasswordAuthentication yes/' "${SSH_CONFIG_FILE}"

  log_warning "Password authentication enabled. Disable in production!"
}

restart_ssh_service() {
  log_info "Restarting SSH service to apply changes"

  systemctl restart sshd || systemctl restart ssh

  log_success "SSH service restarted"
}

verify_ssh_listening_on_port_53() {
  log_info "Verifying SSH is listening on port ${SSH_PORT_ALTERNATE}"

  sleep 2  # Give service time to start

  if ss -tlnp | grep -q ":${SSH_PORT_ALTERNATE} "; then
    log_success "SSH is listening on port ${SSH_PORT_ALTERNATE}"
  else
    log_error "SSH is NOT listening on port ${SSH_PORT_ALTERNATE}"
    log_error "Check logs: sudo journalctl -u ssh -n 50"
    exit 1
  fi
}

create_helper_script_for_socks_tunnel() {
  log_info "Creating helper script for SOCKS5 tunnel"

  local helper_script="/usr/local/bin/start-socks-tunnel"

  cat > "${helper_script}" <<'EOF'
#!/usr/bin/env bash
# Helper script to start SOCKS5 tunnel
# Usage: start-socks-tunnel [remote_host] [remote_port]

set -euo pipefail

REMOTE_HOST="${1:-localhost}"
REMOTE_PORT="${2:-53}"
LOCAL_PORT="1080"

echo "[INFO] Starting SOCKS5 proxy on localhost:${LOCAL_PORT}"
echo "[INFO] Connecting to ${REMOTE_HOST}:${REMOTE_PORT}"

ssh -D "${LOCAL_PORT}" -N -p "${REMOTE_PORT}" "vagrant@${REMOTE_HOST}"
EOF

  chmod +x "${helper_script}"
  log_success "Helper script created: ${helper_script}"
}

display_usage_instructions() {
  cat <<EOF

╔═══════════════════════════════════════════════════════════════╗
║   SSH Tunnel on Port 53 - Configuration Complete             ║
╠═══════════════════════════════════════════════════════════════╣
║                                                               ║
║   SSH is now listening on:                                    ║
║   - Port 22 (default)                                         ║
║   - Port 53 (alternate, TCP)                                  ║
║                                                               ║
║   To create SOCKS5 tunnel from another machine:               ║
║   $ ssh -D 1080 -N -p 53 vagrant@<vm_ip>                      ║
║                                                               ║
║   Then configure applications to use proxy:                   ║
║   SOCKS5 proxy: localhost:1080                                ║
║                                                               ║
║   Test tunnel:                                                ║
║   $ curl --socks5 localhost:1080 https://api.anthropic.com   ║
║                                                               ║
║   Helper script available:                                    ║
║   $ start-socks-tunnel <remote_host> <remote_port>            ║
║                                                               ║
╚═══════════════════════════════════════════════════════════════╝

EOF
}

# ============================================================================
# MAIN EXECUTION (Clean Code: Main should be a summary of execution)
# ============================================================================

main() {
  log_info "Starting ${SCRIPT_NAME}"

  require_root_privileges
  check_ubuntu_version

  configure_ssh_to_listen_on_port_53
  enable_ssh_password_authentication_temporarily
  restart_ssh_service
  verify_ssh_listening_on_port_53
  create_helper_script_for_socks_tunnel

  log_success "SSH tunnel on port 53 established successfully"
  display_usage_instructions
}

# ============================================================================
# ENTRY POINT
# ============================================================================

main "$@"
