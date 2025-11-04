#!/usr/bin/env bash
#
# vagrant-exec.sh
#
# PURPOSE:
#   Executes commands inside Vagrant VMs without manual SSH.
#   Simplifies running CI, tests, and other commands in isolated environments.
#
# CLEAN CODE PRINCIPLES APPLIED:
#   - Reveals intention: "vagrant" + "exec" = execute in Vagrant
#   - One word per concept: "exec" for execution tasks
#   - Testable: Can be tested without running actual Vagrant commands
#
# USAGE:
#   $ ./vagrant-exec.sh development "make ci"
#   $ ./vagrant-exec.sh quick_start "ls -la"
#   $ ./vagrant-exec.sh --list
#
# AUTHOR: TFG Team
# DATE: 2025-11-04

set -euo pipefail
IFS=$'\n\t'

# ============================================================================
# CONSTANTS
# ============================================================================

readonly SCRIPT_NAME="$(basename "${BASH_SOURCE[0]}")"
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly PROJECT_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"
readonly VAGRANT_DIR="${PROJECT_ROOT}/infra/vagrant"

# ============================================================================
# LOGGING
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

# ============================================================================
# HELPER FUNCTIONS
# ============================================================================

show_usage() {
  cat <<EOF
Usage: ${SCRIPT_NAME} <lab> <command>

Execute commands inside Vagrant VMs.

Arguments:
  <lab>       Lab name: development, quick_start, professional, complete
  <command>   Command to execute inside the VM

Options:
  --list      List available labs
  --help      Show this help

Examples:
  # Run CI inside development VM
  ${SCRIPT_NAME} development "make ci"

  # Run tests inside development VM
  ${SCRIPT_NAME} development "make test"

  # List files in quick_start VM
  ${SCRIPT_NAME} quick_start "ls -la /vagrant"

  # Check services in complete homeserver
  ${SCRIPT_NAME} complete "systemctl status wg-quick@wg0"

EOF
}

list_available_labs() {
  cat <<EOF
Available Vagrant Labs:

  development         - Full development environment with all tools
  quick_start         - SSH tunnel on port 53 (minimal)
  professional        - Professional SSH server with security
  complete            - Complete homeserver (WireGuard + services)

Vagrantfiles:
  - Vagrantfile.development
  - Vagrantfile.quick_start
  - Vagrantfile.professional_tunnel
  - Vagrantfile.complete_homeserver

EOF
}

get_vagrantfile_name() {
  local lab="${1}"

  case "${lab}" in
    development)
      echo "Vagrantfile.development"
      ;;
    quick_start|quick)
      echo "Vagrantfile.quick_start"
      ;;
    professional|pro)
      echo "Vagrantfile.professional_tunnel"
      ;;
    complete|homeserver)
      echo "Vagrantfile.complete_homeserver"
      ;;
    *)
      log_error "Unknown lab: ${lab}"
      log_error "Use --list to see available labs"
      return 1
      ;;
  esac
}

check_vagrant_installed() {
  if ! command -v vagrant &> /dev/null; then
    log_error "Vagrant is not installed"
    log_error "Install: https://www.vagrantup.com/downloads"
    return 1
  fi
}

check_vm_running() {
  local vagrantfile="${1}"

  cd "${VAGRANT_DIR}"

  if vagrant status --vagrantfile="${vagrantfile}" | grep -q "running"; then
    return 0
  else
    return 1
  fi
}

execute_command_in_vm() {
  local vagrantfile="${1}"
  local command="${2}"

  log_info "Executing command in VM: ${command}"

  cd "${VAGRANT_DIR}"

  # Execute command via vagrant ssh
  if vagrant ssh --vagrantfile="${vagrantfile}" -c "${command}"; then
    log_success "Command executed successfully"
    return 0
  else
    log_error "Command failed with exit code $?"
    return 1
  fi
}

# ============================================================================
# MAIN EXECUTION
# ============================================================================

main() {
  # Handle flags
  if [[ $# -eq 0 ]] || [[ "${1}" == "--help" ]]; then
    show_usage
    exit 0
  fi

  if [[ "${1}" == "--list" ]]; then
    list_available_labs
    exit 0
  fi

  # Validate arguments
  if [[ $# -lt 2 ]]; then
    log_error "Missing arguments"
    show_usage
    exit 1
  fi

  local lab="${1}"
  local command="${2}"

  # Check Vagrant installed
  check_vagrant_installed

  # Get Vagrantfile name
  local vagrantfile
  vagrantfile=$(get_vagrantfile_name "${lab}")

  if [[ -z "${vagrantfile}" ]]; then
    exit 1
  fi

  # Check if VM is running
  if ! check_vm_running "${vagrantfile}"; then
    log_error "VM is not running: ${lab}"
    log_error "Start it with: make lab-${lab} OR vagrant up --vagrantfile=${vagrantfile}"
    exit 1
  fi

  # Execute command
  execute_command_in_vm "${vagrantfile}" "${command}"
}

main "$@"
