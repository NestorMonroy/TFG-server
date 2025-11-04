#!/usr/bin/env bats
#
# vagrant.bats
#
# Tests for Vagrant lab infrastructure and provisioning scripts
# ADR: docs/diseno_solucion/arquitectura_sistemas/adr/0005-vagrant-laboratorios-vpn.md

setup() {
    load 'test_helper/bats-support/load'
    load 'test_helper/bats-assert/load'

    DIR="$( cd "$( dirname "$BATS_TEST_FILENAME" )" >/dev/null 2>&1 && pwd )"
    PROJECT_ROOT="${DIR}/.."
    VAGRANT_DIR="${PROJECT_ROOT}/infra/vagrant"
    PROVISIONING_DIR="${VAGRANT_DIR}/provisioning"
}

# =============================================================================
# STRUCTURE TESTS
# =============================================================================

@test "infra/vagrant directory structure exists" {
    [[ -d "${VAGRANT_DIR}" ]]
    [[ -f "${VAGRANT_DIR}/README.md" ]]
    [[ -d "${PROVISIONING_DIR}" ]]
}

@test "all three Vagrantfiles exist" {
    [[ -f "${VAGRANT_DIR}/Vagrantfile.quick_start" ]]
    [[ -f "${VAGRANT_DIR}/Vagrantfile.professional_tunnel" ]]
    [[ -f "${VAGRANT_DIR}/Vagrantfile.complete_homeserver" ]]
}

@test "all provisioning scripts exist and are executable" {
    local scripts=(
        "establish_ssh_tunnel_on_port_53.sh"
        "configure_professional_ssh_server.sh"
        "deploy_wireguard_with_services.sh"
        "install_security_packages.sh"
        "validate_tunnel_connectivity.sh"
    )

    for script in "${scripts[@]}"; do
        local script_path="${PROVISIONING_DIR}/${script}"
        [[ -f "${script_path}" ]]
        [[ -x "${script_path}" ]]
    done
}

# =============================================================================
# CLEAN CODE NAMING TESTS
# =============================================================================

@test "provisioning scripts follow Clean Code naming conventions" {
    # Verify naming pattern: <verb>_<object>_<context>.sh

    # Should have establish_ prefix (creating connections)
    [[ -f "${PROVISIONING_DIR}/establish_ssh_tunnel_on_port_53.sh" ]]

    # Should have configure_ prefix (adjusting configurations)
    [[ -f "${PROVISIONING_DIR}/configure_professional_ssh_server.sh" ]]

    # Should have deploy_ prefix (deploying services)
    [[ -f "${PROVISIONING_DIR}/deploy_wireguard_with_services.sh" ]]

    # Should have install_ prefix (installing packages)
    [[ -f "${PROVISIONING_DIR}/install_security_packages.sh" ]]

    # Should have validate_ prefix (verifying state)
    [[ -f "${PROVISIONING_DIR}/validate_tunnel_connectivity.sh" ]]
}

@test "provisioning scripts have descriptive names (not abbreviated)" {
    # Should NOT have abbreviated names
    [[ ! -f "${PROVISIONING_DIR}/est_ssh.sh" ]]
    [[ ! -f "${PROVISIONING_DIR}/cfg_ssh.sh" ]]
    [[ ! -f "${PROVISIONING_DIR}/setup.sh" ]]
    [[ ! -f "${PROVISIONING_DIR}/config.sh" ]]

    # Names should be pronounceable
    # "establish SSH tunnel on port fifty-three"
    # "configure professional SSH server"
    # etc.
}

# =============================================================================
# SCRIPT SYNTAX TESTS
# =============================================================================

@test "all provisioning scripts have valid bash syntax" {
    local scripts=(
        "establish_ssh_tunnel_on_port_53.sh"
        "configure_professional_ssh_server.sh"
        "deploy_wireguard_with_services.sh"
        "install_security_packages.sh"
        "validate_tunnel_connectivity.sh"
    )

    for script in "${scripts[@]}"; do
        local script_path="${PROVISIONING_DIR}/${script}"
        run bash -n "${script_path}"
        assert_success
    done
}

@test "all provisioning scripts have shebang" {
    local scripts=(
        "establish_ssh_tunnel_on_port_53.sh"
        "configure_professional_ssh_server.sh"
        "deploy_wireguard_with_services.sh"
        "install_security_packages.sh"
        "validate_tunnel_connectivity.sh"
    )

    for script in "${scripts[@]}"; do
        local script_path="${PROVISIONING_DIR}/${script}"
        run head -n 1 "${script_path}"
        assert_output --partial "#!/usr/bin/env bash"
    done
}

@test "all provisioning scripts use set -euo pipefail" {
    local scripts=(
        "establish_ssh_tunnel_on_port_53.sh"
        "configure_professional_ssh_server.sh"
        "deploy_wireguard_with_services.sh"
        "install_security_packages.sh"
        "validate_tunnel_connectivity.sh"
    )

    for script in "${scripts[@]}"; do
        local script_path="${PROVISIONING_DIR}/${script}"
        run grep -q "set -euo pipefail" "${script_path}"
        assert_success
    done
}

# =============================================================================
# DOCUMENTATION TESTS
# =============================================================================

@test "all provisioning scripts have header documentation" {
    local scripts=(
        "establish_ssh_tunnel_on_port_53.sh"
        "configure_professional_ssh_server.sh"
        "deploy_wireguard_with_services.sh"
        "install_security_packages.sh"
        "validate_tunnel_connectivity.sh"
    )

    for script in "${scripts[@]}"; do
        local script_path="${PROVISIONING_DIR}/${script}"

        # Should have PURPOSE section
        run grep -q "PURPOSE:" "${script_path}"
        assert_success

        # Should have CLEAN CODE PRINCIPLES section
        run grep -q "CLEAN CODE PRINCIPLES" "${script_path}"
        assert_success
    done
}

@test "Vagrant README exists and has required sections" {
    local readme="${VAGRANT_DIR}/README.md"

    run grep -q "## Propósito" "${readme}"
    assert_success

    run grep -q "## Prerequisitos" "${readme}"
    assert_success

    run grep -q "## Uso Rápido" "${readme}"
    assert_success

    run grep -q "## Convenciones de Naming (Clean Code)" "${readme}"
    assert_success
}

@test "laboratorios-vagrant.md documentation exists" {
    local doc="${PROJECT_ROOT}/docs/implementacion/infrastructure/laboratorios-vagrant.md"

    [[ -f "${doc}" ]]

    run grep -q "## Laboratorios Disponibles" "${doc}"
    assert_success

    run grep -q "### Laboratorio 1: Quick Start" "${doc}"
    assert_success

    run grep -q "### Laboratorio 2: Professional" "${doc}"
    assert_success

    run grep -q "### Laboratorio 3: Complete Homeserver" "${doc}"
    assert_success
}

# =============================================================================
# ADR TESTS
# =============================================================================

@test "ADR 0005 exists and is properly documented" {
    local adr="${PROJECT_ROOT}/docs/diseno_solucion/arquitectura_sistemas/adr/0005-vagrant-laboratorios-vpn.md"

    [[ -f "${adr}" ]]

    # Should have required MADR sections
    run grep -q "## Contexto" "${adr}"
    assert_success

    run grep -q "## Decisión" "${adr}"
    assert_success

    run grep -q "## Consecuencias" "${adr}"
    assert_success

    # Should reference Clean Code
    run grep -q "Clean Code" "${adr}"
    assert_success

    # Should reference Robert Martin
    run grep -q "Robert" "${adr}"
    assert_success
}

@test "ADR 0005 is listed in ADR README" {
    local adr_readme="${PROJECT_ROOT}/docs/diseno_solucion/arquitectura_sistemas/adr/README.md"

    run grep -q "0005" "${adr_readme}"
    assert_success

    run grep -q "Vagrant" "${adr_readme}"
    assert_success
}

# =============================================================================
# MAKEFILE INTEGRATION TESTS
# =============================================================================

@test "Makefile has lab-* targets" {
    local makefile="${PROJECT_ROOT}/Makefile"

    run grep -q "lab-quick:" "${makefile}"
    assert_success

    run grep -q "lab-professional:" "${makefile}"
    assert_success

    run grep -q "lab-complete:" "${makefile}"
    assert_success

    run grep -q "lab-status:" "${makefile}"
    assert_success

    run grep -q "lab-destroy:" "${makefile}"
    assert_success
}

@test "Makefile lab targets reference correct Vagrantfiles" {
    local makefile="${PROJECT_ROOT}/Makefile"

    run grep "lab-quick:" -A 5 "${makefile}"
    assert_output --partial "Vagrantfile.quick_start"

    run grep "lab-professional:" -A 5 "${makefile}"
    assert_output --partial "Vagrantfile.professional_tunnel"

    run grep "lab-complete:" -A 5 "${makefile}"
    assert_output --partial "Vagrantfile.complete_homeserver"
}

# =============================================================================
# VAGRANTFILE VALIDATION TESTS
# =============================================================================

@test "Vagrantfiles have valid Ruby syntax" {
    skip "Ruby not required for CI, skip syntax check"

    # If ruby is available, validate syntax
    if command -v ruby &> /dev/null; then
        local vagrantfiles=(
            "Vagrantfile.quick_start"
            "Vagrantfile.professional_tunnel"
            "Vagrantfile.complete_homeserver"
        )

        for vf in "${vagrantfiles[@]}"; do
            run ruby -c "${VAGRANT_DIR}/${vf}"
            assert_success
        done
    fi
}

@test "Vagrantfiles configure VMs with appropriate resources" {
    # Quick Start: 512MB RAM, 1 CPU
    run grep "vb.memory" "${VAGRANT_DIR}/Vagrantfile.quick_start"
    assert_output --partial "512"

    run grep "vb.cpus" "${VAGRANT_DIR}/Vagrantfile.quick_start"
    assert_output --partial "1"

    # Professional: 1024MB RAM, 2 CPUs
    run grep "vb.memory" "${VAGRANT_DIR}/Vagrantfile.professional_tunnel"
    assert_output --partial "1024"

    run grep "vb.cpus" "${VAGRANT_DIR}/Vagrantfile.professional_tunnel"
    assert_output --partial "2"

    # Complete: 2048MB RAM, 2 CPUs
    run grep "vb.memory" "${VAGRANT_DIR}/Vagrantfile.complete_homeserver"
    assert_output --partial "2048"

    run grep "vb.cpus" "${VAGRANT_DIR}/Vagrantfile.complete_homeserver"
    assert_output --partial "2"
}

@test "Vagrantfiles reference correct provisioning scripts" {
    # Quick Start
    run grep "provisioning/establish_ssh_tunnel_on_port_53.sh" "${VAGRANT_DIR}/Vagrantfile.quick_start"
    assert_success

    run grep "provisioning/validate_tunnel_connectivity.sh" "${VAGRANT_DIR}/Vagrantfile.quick_start"
    assert_success

    # Professional
    run grep "provisioning/install_security_packages.sh" "${VAGRANT_DIR}/Vagrantfile.professional_tunnel"
    assert_success

    run grep "provisioning/configure_professional_ssh_server.sh" "${VAGRANT_DIR}/Vagrantfile.professional_tunnel"
    assert_success

    # Complete
    run grep "provisioning/deploy_wireguard_with_services.sh" "${VAGRANT_DIR}/Vagrantfile.complete_homeserver"
    assert_success
}

# =============================================================================
# TESTABILITY TESTS (Clean Code Principle)
# =============================================================================

@test "provisioning scripts are testable without Vagrant" {
    # Scripts should be executable independently
    # They should accept flags like --dry-run, --test, etc.

    local scripts=(
        "establish_ssh_tunnel_on_port_53.sh"
        "validate_tunnel_connectivity.sh"
    )

    for script in "${scripts[@]}"; do
        local script_path="${PROVISIONING_DIR}/${script}"

        # Should mention testability in header
        run grep -q "TESTABILITY" "${script_path}"
        assert_success
    done
}

# =============================================================================
# TOC.YML INTEGRATION TESTS
# =============================================================================

@test "toc.yml references Vagrant documentation" {
    local toc="${PROJECT_ROOT}/docs/toc.yml"

    run grep -q "Laboratorios Vagrant" "${toc}"
    assert_success

    run grep -q "laboratorios-vagrant.md" "${toc}"
    assert_success

    run grep -q "ADR 0005" "${toc}"
    assert_success
}
