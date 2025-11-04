# Laboratorios Vagrant para VPN y Túneles

Infraestructura automatizada para aprender, validar y desarrollar configuraciones de VPN (SSH, WireGuard) y túneles de red.

## Propósito

Este directorio contiene **3 laboratorios Vagrant** que implementan los flujos documentados en el análisis de 662 tareas:

1. **Quick Start** (45 min) - SSH túnel puerto 53
2. **Professional** (4 horas) - Servidor SSH seguro y robusto
3. **Complete Homeserver** (9 horas) - Infraestructura completa

## Prerequisitos

### Software requerido

```bash
# Verificar instalación
vagrant --version  # >= 2.3.0
vboxmanage --version  # >= 7.0
```

### Instalación

**macOS**:
```bash
brew install --cask vagrant virtualbox
```

**Ubuntu/Debian**:
```bash
# VirtualBox
sudo apt update
sudo apt install virtualbox virtualbox-ext-pack

# Vagrant
wget https://releases.hashicorp.com/vagrant/2.4.0/vagrant_2.4.0_linux_amd64.deb
sudo dpkg -i vagrant_2.4.0_linux_amd64.deb
```

**Windows**:
```powershell
choco install vagrant virtualbox
```

## Estructura del Proyecto

```
infra/vagrant/
├── README.md                                    # Este archivo
├── Vagrantfile.quick_start                      # Lab 1: SSH puerto 53
├── Vagrantfile.professional_tunnel              # Lab 2: Servidor SSH profesional
├── Vagrantfile.complete_homeserver              # Lab 3: Infraestructura completa
└── provisioning/
    ├── establish_ssh_tunnel_on_port_53.sh      # Crea túnel SSH puerto 53
    ├── configure_professional_ssh_server.sh    # Configura SSH + seguridad
    ├── deploy_wireguard_with_services.sh       # Despliega WireGuard + servicios
    ├── install_security_packages.sh            # Instala Fail2Ban, UFW, AIDE
    └── validate_tunnel_connectivity.sh         # Valida conectividad de túneles
```

## Uso Rápido

### Desde Makefile (Recomendado)

```bash
# Iniciar laboratorio Quick Start
make lab-quick

# Iniciar laboratorio Professional
make lab-professional

# Iniciar laboratorio Complete
make lab-complete

# Destruir todos los laboratorios
make lab-destroy
```

### Directamente con Vagrant

```bash
cd infra/vagrant

# Lab 1: Quick Start
vagrant up --vagrantfile=Vagrantfile.quick_start

# Lab 2: Professional
vagrant up --vagrantfile=Vagrantfile.professional_tunnel

# Lab 3: Complete Homeserver
vagrant up --vagrantfile=Vagrantfile.complete_homeserver

# SSH a la VM
vagrant ssh

# Destruir VM
vagrant destroy -f
```

## Laboratorios Disponibles

### Lab 1: Quick Start (SSH Túnel Puerto 53)

**Caso de uso**: Necesitas acceso YA a APIs bloqueadas (Claude, OpenAI).

**Tiempo**: 45 minutos (5 min automatizado).

**Recursos**: 512 MB RAM, 1 CPU.

**Qué hace**:
- ✅ Configura SSH en puerto 53 (TCP)
- ✅ Crea túnel SOCKS5 para proxy
- ✅ Valida conectividad con test automatizado
- ✅ Genera config para uso inmediato

**Iniciar**:
```bash
make lab-quick
# O
vagrant up --vagrantfile=Vagrantfile.quick_start
```

**Probar**:
```bash
vagrant ssh

# Dentro de la VM
curl --socks5 localhost:1080 https://api.anthropic.com/v1/messages
```

**Aplicaciones**:
- GitHub Copilot
- Claude API
- OpenAI API
- Servicios con geo-restricción

---

### Lab 2: Professional Tunnel (Servidor SSH Robusto)

**Caso de uso**: Equipo necesita túnel confiable en producción.

**Tiempo**: 4 horas (15 min automatizado).

**Recursos**: 1024 MB RAM, 2 CPUs.

**Qué hace**:
- ✅ SSH con autenticación por clave
- ✅ Fail2Ban (protección brute-force)
- ✅ UFW configurado (firewall)
- ✅ Servicio systemd con auto-restart
- ✅ Monitoreo básico (logs, métricas)

**Iniciar**:
```bash
make lab-professional
# O
vagrant up --vagrantfile=Vagrantfile.professional_tunnel
```

**Probar**:
```bash
vagrant ssh

# Ver estado del servicio
sudo systemctl status ssh-tunnel

# Ver logs Fail2Ban
sudo tail -f /var/log/fail2ban.log

# Ver reglas UFW
sudo ufw status verbose
```

**Aplicaciones**:
- Desarrollo profesional
- Equipos distribuidos
- Entornos CI/CD
- Staging/QA

---

### Lab 3: Complete Homeserver (Infraestructura Completa)

**Caso de uso**: Servidor doméstico con VPN, DNS, cloud storage y monitoreo.

**Tiempo**: 9 horas (30 min automatizado).

**Recursos**: 2048 MB RAM, 2 CPUs.

**Qué hace**:
- ✅ WireGuard VPN (puerto 443 UDP)
- ✅ Pi-Hole (DNS ad-blocker)
- ✅ Nextcloud (cloud storage)
- ✅ Netdata (monitoreo en tiempo real)
- ✅ Cloudflare Tunnel (acceso remoto seguro)

**Iniciar**:
```bash
make lab-complete
# O
vagrant up --vagrantfile=Vagrantfile.complete_homeserver
```

**Probar**:
```bash
vagrant ssh

# Verificar servicios
sudo systemctl status wg-quick@wg0    # WireGuard
sudo systemctl status pihole-FTL      # Pi-Hole
sudo systemctl status nextcloud       # Nextcloud
sudo systemctl status netdata         # Netdata

# Acceder a interfaces web (desde host)
# Pi-Hole: http://192.168.56.30/admin
# Nextcloud: http://192.168.56.30:8080
# Netdata: http://192.168.56.30:19999
```

**Aplicaciones**:
- Servidor doméstico completo
- Aprendizaje avanzado de VPN
- Proyecto personal de infraestructura
- Prototipo para producción

## Convenciones de Naming (Clean Code)

Todos los scripts siguen los principios de Clean Code de Robert Martin:

### Nombres que revelan intenciones

```bash
# ❌ MAL
setup.sh
config.sh
run.sh

# ✅ BIEN
establish_ssh_tunnel_on_port_53.sh
configure_professional_ssh_server.sh
deploy_wireguard_with_services.sh
```

### Una palabra por concepto

| Verbo | Significado | Ejemplo |
|-------|-------------|---------|
| `establish_*` | Crear conexiones/túneles | `establish_ssh_tunnel_on_port_53.sh` |
| `configure_*` | Ajustar configuraciones | `configure_professional_ssh_server.sh` |
| `deploy_*` | Desplegar servicios completos | `deploy_wireguard_with_services.sh` |
| `install_*` | Instalar paquetes/dependencias | `install_security_packages.sh` |
| `validate_*` | Verificar estado/conectividad | `validate_tunnel_connectivity.sh` |
| `test_*` | Ejecutar pruebas | `test_ssh_tunnel.sh` |

### Nombres pronunciables y buscables

```bash
# Pronunciable
"establish SSH tunnel on port fifty-three"

# Buscable
grep -r "establish_ssh" .
grep -r "port_53" .
```

## Scripts de Provisioning

Todos los scripts son **ejecutables independientemente** de Vagrant:

```bash
# Testear script sin ejecutar
./provisioning/establish_ssh_tunnel_on_port_53.sh --dry-run

# Ejecutar con verbose
./provisioning/configure_professional_ssh_server.sh --verbose

# Validar conectividad a host específico
./provisioning/validate_tunnel_connectivity.sh 8.8.8.8
```

### Principio: Frameworks son Plugins

Los scripts NO dependen de Vagrant. Vagrant es solo el orquestador.

```bash
# Funciona en cualquier Ubuntu/Debian
scp provisioning/establish_ssh_tunnel_on_port_53.sh user@server:/tmp/
ssh user@server "bash /tmp/establish_ssh_tunnel_on_port_53.sh"
```

## Troubleshooting

### Error: "Vagrant no encuentra VirtualBox"

```bash
# Verificar instalación
vboxmanage --version

# Reinstalar en macOS
brew reinstall --cask virtualbox

# En Ubuntu
sudo apt install --reinstall virtualbox
```

### Error: "No hay suficiente memoria"

```bash
# Reducir RAM en Vagrantfile
config.vm.provider "virtualbox" do |vb|
  vb.memory = "512"  # Cambiar según disponibilidad
end
```

### Error: "Puerto ya en uso"

```bash
# Encontrar proceso usando el puerto
lsof -i :2222

# Cambiar puerto en Vagrantfile
config.vm.network "forwarded_port", guest: 22, host: 3333  # Cambiar 2222 → 3333
```

### VM muy lenta

```bash
# Asignar más CPUs
config.vm.provider "virtualbox" do |vb|
  vb.cpus = 2  # O 4 si tu máquina tiene suficientes cores
end
```

## Snapshots (Recomendado)

Crear snapshots antes de experimentos:

```bash
# Crear snapshot
vagrant snapshot save quick-start-base

# Listar snapshots
vagrant snapshot list

# Restaurar
vagrant snapshot restore quick-start-base

# Eliminar snapshot
vagrant snapshot delete quick-start-base
```

## Limpieza

```bash
# Destruir VM pero mantener box
vagrant destroy -f

# Eliminar box descargada (liberar espacio)
vagrant box remove ubuntu/jammy64

# Limpiar todas las VMs
vagrant global-status --prune
```

## Extensiones Futuras

- [ ] Ansible playbooks como alternativa a Shell scripts
- [ ] Soporte para otros providers (VMware, libvirt)
- [ ] Tests automatizados con BATS
- [ ] Integración con CI/CD
- [ ] Vagrant Cloud para compartir boxes customizados

## Referencias

- [ADR 0005: Vagrant para Laboratorios VPN](../../docs/diseno_solucion/arquitectura_sistemas/adr/0005-vagrant-laboratorios-vpn.md)
- [Vagrant Documentation](https://www.vagrantup.com/docs)
- [VirtualBox Manual](https://www.virtualbox.org/manual/)
- [Clean Code - Robert C. Martin](https://www.amazon.com/Clean-Code-Handbook-Software-Craftsmanship/dp/0132350882)

## Contribuciones

Al agregar nuevos Vagrantfiles o scripts:

1. **Nombrar según Clean Code**: Nombres que revelan intenciones
2. **Scripts independientes**: Deben funcionar fuera de Vagrant
3. **Documentar casos de uso**: Explicar PARA QUÉ, no solo QUÉ
4. **Incluir tests**: `--dry-run`, `--test`, `--verbose` flags
5. **Actualizar README**: Este archivo debe reflejar cambios

## Licencia

Este proyecto usa la misma licencia que TFG-server.

---

**Mantenido por**: Equipo TFG
**Última actualización**: 2025-11-04
**ADR relacionado**: [ADR 0005](../../docs/diseno_solucion/arquitectura_sistemas/adr/0005-vagrant-laboratorios-vpn.md)
