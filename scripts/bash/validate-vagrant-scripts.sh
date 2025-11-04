#!/usr/bin/env bash
#
# validate-vagrant-scripts.sh
#
# PURPOSE:
#   Validates Vagrant provisioning scripts for syntax, structure, and Clean Code compliance.
#   This script does NOT execute the provisioning scripts, only validates them.
#
# CLEAN CODE PRINCIPLES APPLIED:
#   - Reveals intention: "validate" + "vagrant_scripts" = verification without execution
#   - One word per concept: "validate" for verification tasks
#   - Testable: Can be executed in CI without Vagrant installed
#
# USAGE:
#   $ ./validate-vagrant-scripts.sh
#   $ ./validate-vagrant-scripts.sh --verbose
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
readonly PROVISIONING_DIR="${VAGRANT_DIR}/provisioning"

readonly VERBOSE="${1:-}"

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

log_verbose() {
  if [[ "${VERBOSE}" == "--verbose" ]]; then
    echo "[VERBOSE] ${1}" >&2
  fi
}

# ============================================================================
# VALIDATION FUNCTIONS
# ============================================================================

validate_directory_structure() {
  log_info "Validating directory structure"

  if [[ ! -d "${VAGRANT_DIR}" ]]; then
    log_error "Vagrant directory not found: ${VAGRANT_DIR}"
    return 1
  fi

  if [[ ! -d "${PROVISIONING_DIR}" ]]; then
    log_error "Provisioning directory not found: ${PROVISIONING_DIR}"
    return 1
  fi

  log_success "Directory structure valid"
  return 0
}

validate_vagrantfiles_exist() {
  log_info "Validating Vagrantfiles exist"

  local vagrantfiles=(
    "Vagrantfile.quick_start"
    "Vagrantfile.professional_tunnel"
    "Vagrantfile.complete_homeserver"
  )

  local missing=0

  for vf in "${vagrantfiles[@]}"; do
    if [[ ! -f "${VAGRANT_DIR}/${vf}" ]]; then
      log_error "Missing Vagrantfile: ${vf}"
      ((missing++))
    else
      log_verbose "Found: ${vf}"
    fi
  done

  if [[ ${missing} -eq 0 ]]; then
    log_success "All Vagrantfiles exist"
    return 0
  else
    log_error "${missing} Vagrantfile(s) missing"
    return 1
  fi
}

validate_provisioning_scripts_exist() {
  log_info "Validating provisioning scripts exist"

  local scripts=(
    "establish_ssh_tunnel_on_port_53.sh"
    "configure_professional_ssh_server.sh"
    "deploy_wireguard_with_services.sh"
    "install_security_packages.sh"
    "validate_tunnel_connectivity.sh"
  )

  local missing=0

  for script in "${scripts[@]}"; do
    if [[ ! -f "${PROVISIONING_DIR}/${script}" ]]; then
      log_error "Missing script: ${script}"
      ((missing++))
    else
      log_verbose "Found: ${script}"
    fi
  done

  if [[ ${missing} -eq 0 ]]; then
    log_success "All provisioning scripts exist"
    return 0
  else
    log_error "${missing} provisioning script(s) missing"
    return 1
  fi
}

validate_scripts_are_executable() {
  log_info "Validating scripts are executable"

  local scripts=(
    "establish_ssh_tunnel_on_port_53.sh"
    "configure_professional_ssh_server.sh"
    "deploy_wireguard_with_services.sh"
    "install_security_packages.sh"
    "validate_tunnel_connectivity.sh"
  )

  local not_executable=0

  for script in "${scripts[@]}"; do
    local script_path="${PROVISIONING_DIR}/${script}"

    if [[ ! -x "${script_path}" ]]; then
      log_error "Not executable: ${script}"
      ((not_executable++))
    else
      log_verbose "Executable: ${script}"
    fi
  done

  if [[ ${not_executable} -eq 0 ]]; then
    log_success "All scripts are executable"
    return 0
  else
    log_error "${not_executable} script(s) not executable"
    return 1
  fi
}

validate_bash_syntax() {
  log_info "Validating Bash syntax"

  local scripts=(
    "establish_ssh_tunnel_on_port_53.sh"
    "configure_professional_ssh_server.sh"
    "deploy_wireguard_with_services.sh"
    "install_security_packages.sh"
    "validate_tunnel_connectivity.sh"
  )

  local syntax_errors=0

  for script in "${scripts[@]}"; do
    local script_path="${PROVISIONING_DIR}/${script}"

    if bash -n "${script_path}"; then
      log_verbose "Syntax OK: ${script}"
    else
      log_error "Syntax error in: ${script}"
      ((syntax_errors++))
    fi
  done

  if [[ ${syntax_errors} -eq 0 ]]; then
    log_success "All scripts have valid Bash syntax"
    return 0
  else
    log_error "${syntax_errors} script(s) have syntax errors"
    return 1
  fi
}

validate_shebang() {
  log_info "Validating shebang lines"

  local scripts=(
    "establish_ssh_tunnel_on_port_53.sh"
    "configure_professional_ssh_server.sh"
    "deploy_wireguard_with_services.sh"
    "install_security_packages.sh"
    "validate_tunnel_connectivity.sh"
  )

  local missing_shebang=0

  for script in "${scripts[@]}"; do
    local script_path="${PROVISIONING_DIR}/${script}"
    local first_line

    first_line=$(head -n 1 "${script_path}")

    if [[ "${first_line}" == "#!/usr/bin/env bash" ]]; then
      log_verbose "Shebang OK: ${script}"
    else
      log_error "Invalid or missing shebang in: ${script}"
      ((missing_shebang++))
    fi
  done

  if [[ ${missing_shebang} -eq 0 ]]; then
    log_success "All scripts have correct shebang"
    return 0
  else
    log_error "${missing_shebang} script(s) have invalid shebang"
    return 1
  fi
}

validate_set_flags() {
  log_info "Validating 'set -euo pipefail' usage"

  local scripts=(
    "establish_ssh_tunnel_on_port_53.sh"
    "configure_professional_ssh_server.sh"
    "deploy_wireguard_with_services.sh"
    "install_security_packages.sh"
    "validate_tunnel_connectivity.sh"
  )

  local missing_set=0

  for script in "${scripts[@]}"; do
    local script_path="${PROVISIONING_DIR}/${script}"

    if grep -q "set -euo pipefail" "${script_path}"; then
      log_verbose "Set flags OK: ${script}"
    else
      log_error "Missing 'set -euo pipefail' in: ${script}"
      ((missing_set++))
    fi
  done

  if [[ ${missing_set} -eq 0 ]]; then
    log_success "All scripts use 'set -euo pipefail'"
    return 0
  else
    log_error "${missing_set} script(s) missing 'set -euo pipefail'"
    return 1
  fi
}

validate_clean_code_naming() {
  log_info "Validating Clean Code naming conventions"

  local naming_violations=0

  # Verify verb prefixes
  local expected_scripts=(
    "establish_ssh_tunnel_on_port_53.sh:establish"
    "configure_professional_ssh_server.sh:configure"
    "deploy_wireguard_with_services.sh:deploy"
    "install_security_packages.sh:install"
    "validate_tunnel_connectivity.sh:validate"
  )

  for entry in "${expected_scripts[@]}"; do
    local script="${entry%%:*}"
    local expected_verb="${entry##*:}"

    if [[ -f "${PROVISIONING_DIR}/${script}" ]]; then
      if [[ "${script}" =~ ^${expected_verb}_ ]]; then
        log_verbose "Clean Code naming OK: ${script}"
      else
        log_error "Naming violation: ${script} should start with '${expected_verb}_'"
        ((naming_violations++))
      fi
    fi
  done

  if [[ ${naming_violations} -eq 0 ]]; then
    log_success "All scripts follow Clean Code naming conventions"
    return 0
  else
    log_error "${naming_violations} naming violation(s)"
    return 1
  fi
}

validate_documentation_headers() {
  log_info "Validating documentation headers"

  local scripts=(
    "establish_ssh_tunnel_on_port_53.sh"
    "configure_professional_ssh_server.sh"
    "deploy_wireguard_with_services.sh"
    "install_security_packages.sh"
    "validate_tunnel_connectivity.sh"
  )

  local missing_docs=0

  for script in "${scripts[@]}"; do
    local script_path="${PROVISIONING_DIR}/${script}"

    # Check for PURPOSE section
    if ! grep -q "PURPOSE:" "${script_path}"; then
      log_error "Missing PURPOSE section in: ${script}"
      ((missing_docs++))
      continue
    fi

    # Check for CLEAN CODE PRINCIPLES section
    if ! grep -q "CLEAN CODE PRINCIPLES" "${script_path}"; then
      log_error "Missing CLEAN CODE PRINCIPLES section in: ${script}"
      ((missing_docs++))
      continue
    fi

    log_verbose "Documentation OK: ${script}"
  done

  if [[ ${missing_docs} -eq 0 ]]; then
    log_success "All scripts have proper documentation headers"
    return 0
  else
    log_error "${missing_docs} script(s) missing documentation"
    return 1
  fi
}

# ============================================================================
# SHELLCHECK VALIDATION (if available)
# ============================================================================

validate_with_shellcheck() {
  if ! command -v shellcheck &> /dev/null; then
    log_info "Shellcheck not available, skipping static analysis"
    return 0
  fi

  log_info "Running shellcheck on provisioning scripts"

  local scripts=(
    "establish_ssh_tunnel_on_port_53.sh"
    "configure_professional_ssh_server.sh"
    "deploy_wireguard_with_services.sh"
    "install_security_packages.sh"
    "validate_tunnel_connectivity.sh"
  )

  local shellcheck_errors=0

  for script in "${scripts[@]}"; do
    local script_path="${PROVISIONING_DIR}/${script}"

    if shellcheck "${script_path}"; then
      log_verbose "Shellcheck OK: ${script}"
    else
      log_error "Shellcheck errors in: ${script}"
      ((shellcheck_errors++))
    fi
  done

  if [[ ${shellcheck_errors} -eq 0 ]]; then
    log_success "All scripts pass shellcheck"
    return 0
  else
    log_error "${shellcheck_errors} script(s) have shellcheck errors"
    return 1
  fi
}

# ============================================================================
# MAIN EXECUTION
# ============================================================================

main() {
  log_info "Starting ${SCRIPT_NAME}"

  local validation_failures=0

  # Run all validations
  validate_directory_structure || ((validation_failures++))
  validate_vagrantfiles_exist || ((validation_failures++))
  validate_provisioning_scripts_exist || ((validation_failures++))
  validate_scripts_are_executable || ((validation_failures++))
  validate_bash_syntax || ((validation_failures++))
  validate_shebang || ((validation_failures++))
  validate_set_flags || ((validation_failures++))
  validate_clean_code_naming || ((validation_failures++))
  validate_documentation_headers || ((validation_failures++))
  validate_with_shellcheck || ((validation_failures++))

  echo ""
  if [[ ${validation_failures} -eq 0 ]]; then
    log_success "All validations passed ✓"
    log_success "Vagrant provisioning scripts are ready for use"
    return 0
  else
    log_error "${validation_failures} validation(s) failed"
    log_error "Please fix the issues above before using the scripts"
    return 1
  fi
}

main "$@"
