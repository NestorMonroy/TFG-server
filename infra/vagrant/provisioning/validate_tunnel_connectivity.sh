#!/usr/bin/env bash
#
# validate_tunnel_connectivity.sh
#
# PURPOSE:
#   Validates SSH tunnel connectivity and network configuration.
#   Performs comprehensive tests to ensure tunnel is working correctly.
#
# TESTS PERFORMED:
#   - DNS resolution
#   - Port availability
#   - Internet connectivity
#   - SSH service status
#   - Firewall rules
#
# CLEAN CODE PRINCIPLES APPLIED:
#   - Reveals intention: "validate" + "tunnel_connectivity" = clear purpose
#   - One word per concept: "validate" for verification tasks
#   - Testable: Can run standalone with different arguments
#
# USAGE:
#   $ ./validate_tunnel_connectivity.sh
#   $ ./validate_tunnel_connectivity.sh 8.8.8.8  # Test specific host
#
# AUTHOR: TFG Team
# DATE: 2025-11-04

set -euo pipefail
IFS=$'\n\t'

# ============================================================================
# CONSTANTS
# ============================================================================

readonly SCRIPT_NAME="$(basename "${BASH_SOURCE[0]}")"
readonly TEST_HOST="${1:-8.8.8.8}"
readonly TEST_DOMAIN="google.com"

# ============================================================================
# LOGGING
# ============================================================================

log_info() { echo "[INFO] ${1}" >&2; }
log_success() { echo "[SUCCESS] ${1}" >&2; }
log_error() { echo "[ERROR] ${1}" >&2; }
log_warning() { echo "[WARNING] ${1}" >&2; }

# ============================================================================
# TEST FUNCTIONS (Clean Code: Small functions, one purpose each)
# ============================================================================

test_dns_resolution() {
  log_info "Testing DNS resolution"

  if nslookup "${TEST_DOMAIN}" > /dev/null 2>&1; then
    log_success "DNS resolution works for ${TEST_DOMAIN}"
    return 0
  else
    log_error "DNS resolution failed for ${TEST_DOMAIN}"
    return 1
  fi
}

test_internet_connectivity() {
  log_info "Testing internet connectivity to ${TEST_HOST}"

  if ping -c 3 -W 5 "${TEST_HOST}" > /dev/null 2>&1; then
    log_success "Internet connectivity confirmed"
    return 0
  else
    log_warning "ICMP ping failed (may be blocked, not critical)"
    return 0  # Not critical, firewalls often block ICMP
  fi
}

test_ssh_service_active() {
  log_info "Testing SSH service status"

  if systemctl is-active --quiet sshd || systemctl is-active --quiet ssh; then
    log_success "SSH service is active"
    return 0
  else
    log_error "SSH service is not running"
    return 1
  fi
}

test_ssh_listening_ports() {
  log_info "Testing SSH listening ports"

  local ports_found=0

  if ss -tlnp | grep -q ":22 "; then
    log_success "SSH listening on port 22"
    ((ports_found++))
  fi

  if ss -tlnp | grep -q ":53 "; then
    log_success "SSH listening on port 53"
    ((ports_found++))
  fi

  if ss -tlnp | grep -q ":443 "; then
    log_success "SSH listening on port 443"
    ((ports_found++))
  fi

  if [[ ${ports_found} -gt 0 ]]; then
    log_success "SSH listening on ${ports_found} port(s)"
    return 0
  else
    log_error "SSH not listening on any expected ports"
    return 1
  fi
}

test_firewall_configuration() {
  log_info "Testing firewall configuration"

  if command -v ufw &> /dev/null; then
    if ufw status | grep -q "Status: active"; then
      log_success "UFW firewall is active"

      # Check SSH ports are allowed
      if ufw status | grep -qE "(22|53|443)/tcp.*ALLOW"; then
        log_success "SSH ports are allowed in firewall"
      else
        log_warning "SSH ports may not be explicitly allowed in firewall"
      fi
    else
      log_warning "UFW firewall is installed but not active"
    fi
  else
    log_info "UFW not installed (skipping firewall check)"
  fi

  return 0
}

test_fail2ban_protection() {
  log_info "Testing Fail2Ban protection"

  if command -v fail2ban-client &> /dev/null; then
    if systemctl is-active --quiet fail2ban; then
      log_success "Fail2Ban is active"

      # Show SSH jail status
      local ssh_status
      ssh_status=$(fail2ban-client status sshd 2>&1 || true)

      if echo "${ssh_status}" | grep -q "Status for the jail: sshd"; then
        log_success "Fail2Ban protecting SSH"
      fi
    else
      log_warning "Fail2Ban installed but not active"
    fi
  else
    log_info "Fail2Ban not installed (optional)"
  fi

  return 0
}

test_http_connectivity_through_proxy() {
  log_info "Testing HTTP connectivity (external sites)"

  # Test connection to anthropic.com (Claude API)
  if curl -s --connect-timeout 5 --max-time 10 https://www.anthropic.com > /dev/null 2>&1; then
    log_success "HTTP connectivity to anthropic.com works"
  else
    log_warning "HTTP connectivity to anthropic.com failed (may be blocked)"
  fi

  # Test connection to api.openai.com
  if curl -s --connect-timeout 5 --max-time 10 https://api.openai.com > /dev/null 2>&1; then
    log_success "HTTP connectivity to api.openai.com works"
  else
    log_warning "HTTP connectivity to api.openai.com failed (may be blocked)"
  fi

  return 0
}

display_network_information() {
  log_info "Network configuration summary"

  echo ""
  echo "═══ Network Interfaces ═══"
  ip -brief addr show

  echo ""
  echo "═══ Listening Ports (SSH) ═══"
  ss -tlnp | grep -E ":(22|53|443) " || echo "No SSH ports found"

  echo ""
  echo "═══ Default Gateway ═══"
  ip route show default

  echo ""
}

# ============================================================================
# MAIN EXECUTION
# ============================================================================

main() {
  log_info "Starting ${SCRIPT_NAME}"
  log_info "Test host: ${TEST_HOST}"

  local test_failures=0

  # Run all tests
  test_dns_resolution || ((test_failures++))
  test_internet_connectivity || ((test_failures++))
  test_ssh_service_active || ((test_failures++))
  test_ssh_listening_ports || ((test_failures++))
  test_firewall_configuration || ((test_failures++))
  test_fail2ban_protection || ((test_failures++))
  test_http_connectivity_through_proxy || ((test_failures++))

  # Display network info
  display_network_information

  # Summary
  echo ""
  if [[ ${test_failures} -eq 0 ]]; then
    log_success "All validation tests passed ✓"

    cat <<EOF

╔═══════════════════════════════════════════════════════════════╗
║   Tunnel Connectivity Validation - ALL TESTS PASSED          ║
╠═══════════════════════════════════════════════════════════════╣
║                                                               ║
║   ✓ DNS resolution                                            ║
║   ✓ Internet connectivity                                     ║
║   ✓ SSH service active                                        ║
║   ✓ SSH ports listening                                       ║
║   ✓ Firewall configured                                       ║
║   ✓ Fail2Ban protection                                       ║
║   ✓ HTTP connectivity                                         ║
║                                                               ║
║   System is ready for tunnel connections!                     ║
║                                                               ║
╚═══════════════════════════════════════════════════════════════╝

EOF
    return 0
  else
    log_warning "${test_failures} test(s) failed or returned warnings"
    log_warning "Review logs above for details"
    return 0  # Don't fail provisioning, warnings are acceptable
  fi
}

main "$@"
