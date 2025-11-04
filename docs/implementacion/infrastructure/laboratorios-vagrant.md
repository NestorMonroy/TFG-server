# Laboratorios Vagrant - VPN y Túneles de Red

Guía completa para usar los laboratorios Vagrant de VPN y túneles de red del proyecto TFG-Server.

---

**FECHA**: 2025-11-04
**ADR**: [ADR 0005 - Vagrant para Laboratorios VPN](../../diseno_solucion/arquitectura_sistemas/adr/0005-vagrant-laboratorios-vpn.md)
**CÓDIGO**: `infra/vagrant/`

---

## Resumen Ejecutivo

Los laboratorios Vagrant permiten **aprender, validar y desarrollar configuraciones de VPN** en entornos reproducibles sin afectar infraestructura productiva. Implementan automatización de las **662 tareas documentadas** en 12 documentos de análisis de túneles SSH y VPN.

### Beneficios

- ✅ **Reproducibilidad**: `make lab-quick` crea entorno idéntico
- ✅ **Velocidad**: 45 minutos → 5 minutos (automatizado)
- ✅ **Sin riesgo**: Errores solo afectan VM local
- ✅ **Sin costo**: VirtualBox es gratis
- ✅ **Educación**: Aprender ejecutando, no solo leyendo

---

## Prerequisitos

### 1. Software Requerido

| Software | Versión Mínima | Propósito |
|----------|----------------|-----------|
| Vagrant | 2.3.0+ | Orquestador de VMs |
| VirtualBox | 7.0+ | Proveedor de virtualización |
| Make | 3.81+ | Ejecución de comandos |

### 2. Instalación

#### macOS

```bash
brew install --cask vagrant virtualbox
```

#### Ubuntu/Debian

```bash
# VirtualBox
sudo apt update
sudo apt install virtualbox virtualbox-ext-pack

# Vagrant
wget https://releases.hashicorp.com/vagrant/2.4.0/vagrant_2.4.0_linux_amd64.deb
sudo dpkg -i vagrant_2.4.0_linux_amd64.deb
```

#### Windows

```powershell
choco install vagrant virtualbox
```

### 3. Verificar Instalación

```bash
vagrant --version  # Debería mostrar >= 2.3.0
vboxmanage --version  # Debería mostrar >= 7.0
```

---

## Laboratorios Disponibles

### Laboratorio 1: Quick Start

**Caso de uso**: Necesitas acceso YA a APIs bloqueadas (Claude, OpenAI, GitHub Copilot).

**Implementa**: Flujo 1 del análisis (45 min → 5 min)

**Servicios**:
- SSH en puerto 53 (TCP)
- Túnel SOCKS5 en puerto 1080
- Tests de conectividad automatizados

**Recursos**:
- RAM: 512 MB
- CPU: 1 core
- Disco: ~5 GB

**Iniciar**:

```bash
make lab-quick

# O directamente con Vagrant
cd infra/vagrant
vagrant up --vagrantfile=Vagrantfile.quick_start
```

**Probar**:

```bash
vagrant ssh

# Dentro de la VM
curl --socks5 localhost:1080 https://api.anthropic.com/v1/messages
```

**Aplicaciones**:
- GitHub Copilot a través del túnel
- Claude API sin geo-restricciones
- OpenAI API en redes restrictivas

---

### Laboratorio 2: Professional

**Caso de uso**: Equipo necesita túnel confiable en producción.

**Implementa**: Flujo 2 del análisis (4 horas → 15 min)

**Servicios**:
- SSH con autenticación por clave
- Fail2Ban (protección brute-force)
- UFW configurado (firewall)
- Servicio systemd con auto-restart
- Monitoreo básico (logs, métricas)

**Recursos**:
- RAM: 1024 MB
- CPU: 2 cores
- Disco: ~8 GB

**Iniciar**:

```bash
make lab-professional

# O directamente
cd infra/vagrant
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

### Laboratorio 3: Complete Homeserver

**Caso de uso**: Servidor doméstico con VPN, DNS, cloud storage y monitoreo.

**Implementa**: Flujo 3 del análisis (9 horas → 30 min)

**Servicios**:
- WireGuard VPN (puerto 443 UDP)
- Pi-Hole (DNS ad-blocker)
- Nextcloud (cloud storage)
- Netdata (monitoreo en tiempo real)
- Cloudflare Tunnel (acceso remoto seguro)

**Recursos**:
- RAM: 2048 MB
- CPU: 2 cores
- Disco: ~15 GB

**Iniciar**:

```bash
make lab-complete

# O directamente
cd infra/vagrant
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

---

## Uso desde Makefile (Recomendado)

```bash
# Ver ayuda
make help

# Iniciar laboratorios
make lab-quick          # Lab 1: Quick Start
make lab-professional   # Lab 2: Professional
make lab-complete       # Lab 3: Complete Homeserver

# Ver estado
make lab-status

# Destruir todos los laboratorios
make lab-destroy
```

---

## Uso Avanzado de Vagrant

### Comandos Básicos

```bash
cd infra/vagrant

# Iniciar VM
vagrant up --vagrantfile=Vagrantfile.quick_start

# SSH a la VM
vagrant ssh

# Ver estado
vagrant status

# Detener VM (mantiene estado)
vagrant halt

# Destruir VM
vagrant destroy -f

# Reiniciar VM
vagrant reload

# Reprovisionar (volver a ejecutar scripts)
vagrant provision
```

### Snapshots (Recomendado)

```bash
# Crear snapshot antes de experimentos
vagrant snapshot save quick-start-base

# Listar snapshots
vagrant snapshot list

# Restaurar snapshot
vagrant snapshot restore quick-start-base

# Eliminar snapshot
vagrant snapshot delete quick-start-base
```

### Port Forwarding

Los Vagrantfiles ya incluyen port forwarding configurado:

| Lab | Guest Port | Host Port | Servicio |
|-----|------------|-----------|----------|
| Quick Start | 53 | 5353 | SSH tunnel |
| Professional | 22 | 2220 | SSH |
| Professional | 443 | 4430 | SSH alternativo |
| Complete | 51820 | 51820 | WireGuard |
| Complete | 80 | 8080 | HTTP (Pi-Hole, Nextcloud) |
| Complete | 443 | 8443 | HTTPS |
| Complete | 19999 | 19999 | Netdata |

---

## Scripts de Provisioning

Los scripts en `infra/vagrant/provisioning/` son **ejecutables independientemente** de Vagrant:

### Principios Clean Code Aplicados

Todos los scripts siguen los principios de **Clean Code** de Robert C. Martin:

#### Nombres que revelan intenciones

```bash
# ❌ MAL: Requiere comentario para entender
setup.sh  # ¿Qué setup? ¿SSH? ¿VPN? ¿Seguridad?

# ✅ BIEN: El nombre lo explica todo
establish_ssh_tunnel_on_port_53.sh
configure_professional_ssh_server.sh
deploy_wireguard_with_services.sh
```

#### Una palabra por concepto

| Verbo | Significado | Ejemplo |
|-------|-------------|---------|
| `establish_*` | Crear conexiones/túneles | `establish_ssh_tunnel_on_port_53.sh` |
| `configure_*` | Ajustar configuraciones | `configure_professional_ssh_server.sh` |
| `deploy_*` | Desplegar servicios completos | `deploy_wireguard_with_services.sh` |
| `install_*` | Instalar paquetes/dependencias | `install_security_packages.sh` |
| `validate_*` | Verificar estado/conectividad | `validate_tunnel_connectivity.sh` |

### Uso Independiente

```bash
cd infra/vagrant/provisioning

# Testear script sin ejecutar
./establish_ssh_tunnel_on_port_53.sh --dry-run

# Ejecutar con verbose
./configure_professional_ssh_server.sh --verbose

# Validar conectividad a host específico
./validate_tunnel_connectivity.sh 8.8.8.8

# Usar en servidor remoto
scp establish_ssh_tunnel_on_port_53.sh user@server:/tmp/
ssh user@server "bash /tmp/establish_ssh_tunnel_on_port_53.sh"
```

---

## Troubleshooting

### Error: "Vagrant no encuentra VirtualBox"

**Síntoma**:
```
The provider 'virtualbox' could not be found
```

**Solución**:
```bash
# Verificar instalación
vboxmanage --version

# Reinstalar en macOS
brew reinstall --cask virtualbox

# En Ubuntu
sudo apt install --reinstall virtualbox
```

### Error: "No hay suficiente memoria"

**Síntoma**:
```
The guest machine entered an invalid state
```

**Solución**:

Reducir RAM en Vagrantfile:

```ruby
config.vm.provider "virtualbox" do |vb|
  vb.memory = "512"  # Cambiar según disponibilidad
end
```

### Error: "Puerto ya en uso"

**Síntoma**:
```
Vagrant cannot forward the specified ports on this VM
```

**Solución**:

```bash
# Encontrar proceso usando el puerto
lsof -i :2222

# O cambiar puerto en Vagrantfile
config.vm.network "forwarded_port", guest: 22, host: 3333  # Cambiar 2222 → 3333
```

### VM muy lenta

**Solución**:

Asignar más CPUs en Vagrantfile:

```ruby
config.vm.provider "virtualbox" do |vb|
  vb.cpus = 2  # O 4 si tu máquina tiene suficientes cores
end
```

### Error de red: "No internet en VM"

**Solución**:

```bash
vagrant ssh

# Verificar DNS
nslookup google.com

# Reiniciar networking
sudo systemctl restart networking

# Verificar NAT
sudo dhclient -r
sudo dhclient
```

---

## Árbol de Decisión de Laboratorios

```
┌─ ¿Tienes < 1 hora?
│   ├─ SÍ → make lab-quick
│   └─ NO → Continuar
│
├─ ¿Necesitas máximo rendimiento?
│   ├─ SÍ → make lab-complete (WireGuard)
│   └─ NO → Continuar
│
├─ ¿Solo GitHub Copilot?
│   ├─ SÍ → make lab-quick
│   └─ NO → Continuar
│
├─ ¿Quieres aprender?
│   ├─ SÍ → make lab-complete (todos los servicios)
│   └─ NO → Continuar
│
└─ Caso general → make lab-professional
```

---

## Comparativa de Laboratorios

| Aspecto | Quick Start | Professional | Complete Homeserver |
|---------|-------------|--------------|---------------------|
| **Tiempo manual** | 45 min | 4 horas | 9 horas |
| **Tiempo automatizado** | 5 min | 15 min | 30 min |
| **Complejidad** | ⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ |
| **RAM** | 512 MB | 1 GB | 2 GB |
| **CPUs** | 1 | 2 | 2 |
| **Éxito esperado** | 90% | 85% | 70% |
| **Caso de uso** | Urgente | Producción | Aprendizaje |
| **Servicios** | 1 (SSH) | 3 (SSH+seguridad) | 5 (VPN+DNS+Cloud+Monitor) |

---

## Referencias

- [ADR 0005: Vagrant para Laboratorios VPN](../../diseno_solucion/arquitectura_sistemas/adr/0005-vagrant-laboratorios-vpn.md)
- [README de infra/vagrant/](../../../infra/vagrant/README.md)
- [Vagrant Documentation](https://www.vagrantup.com/docs)
- [VirtualBox Manual](https://www.virtualbox.org/manual/)
- [Clean Code - Robert C. Martin](https://www.amazon.com/Clean-Code-Handbook-Software-Craftsmanship/dp/0132350882)

---

## Contribuciones

Al agregar nuevos Vagrantfiles o scripts:

1. **Nombrar según Clean Code**: Nombres que revelan intenciones
2. **Scripts independientes**: Deben funcionar fuera de Vagrant
3. **Documentar casos de uso**: Explicar PARA QUÉ, no solo QUÉ
4. **Incluir tests**: `--dry-run`, `--test`, `--verbose` flags
5. **Actualizar documentación**: Este archivo y README de vagrant/

---

**Mantenido por**: Equipo TFG
**Última actualización**: 2025-11-04
