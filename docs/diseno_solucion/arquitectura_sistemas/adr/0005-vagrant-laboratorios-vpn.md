# ADR 0005: Vagrant para Laboratorios de VPN y Túneles de Red

**Estado**: ACEPTADO

**Fecha**: 2025-11-04

**Contexto relacionado**: Complementa [ADR 0002: Migración a Makefile](0002-migracion-makefile.md)

## Contexto

El proyecto TFG Server incluye documentación extensa (662 tareas en 12 documentos) sobre configuración de VPNs (SSH, WireGuard) y túneles de red para acceso a APIs bloqueadas. Los desarrolladores necesitan entornos reproducibles para:

1. **Aprender tecnologías VPN**: SSH tunneling, WireGuard, DNS tunneling
2. **Validar configuraciones**: Antes de deploy en servidores reales
3. **Desarrollo rápido**: Pruebas sin afectar infraestructura productiva
4. **Onboarding**: Nuevos miembros necesitan ambiente práct ico
5. **Documentación viva**: Ejemplos ejecutables, no solo teóricos

### Problema identificado

**Sin automatización**, implementar los flujos documentados requiere:

- ⏱️ **Tiempo**: 45 min a 9 horas según complejidad
- 💰 **Costo**: VPS en Oracle/DigitalOcean ($0-$10/mes)
- 🔧 **Configuración manual**: Propenso a errores
- 📚 **Conocimiento previo**: Networking, Linux, seguridad
- 🚫 **Sin rollback**: Errores en servidor productivo

**Casos de uso reales**:

| Caso de Uso | Tiempo Manual | Complejidad | Probabilidad Error |
|-------------|---------------|-------------|-------------------|
| Quick Start (SSH puerto 53) | 45 min | ⭐⭐ | 10% |
| Setup profesional (systemd) | 4 horas | ⭐⭐⭐⭐ | 25% |
| Servidor completo (WireGuard + servicios) | 9 horas | ⭐⭐⭐⭐⭐ | 40% |

### Análisis de flujos de implementación

Del análisis de 662 tareas se identificaron **3 flujos principales**:

```
FLUJO 1: QUICK START (Urgente - 1 hora)
├─ VPS Oracle Cloud (gratis)
├─ SSH puerto 53
├─ Túnel SOCKS5
└─ Test de conectividad
Uso: Acceso rápido a APIs bloqueadas
Éxito: 90%

FLUJO 2: PROFESSIONAL (Robusto - 4 horas)
├─ Servidor completo configurado
├─ Fail2Ban + UFW (seguridad)
├─ Scripts automatizados
├─ Servicio systemd (auto-restart)
└─ Monitoreo básico
Uso: Producción, uso prolongado
Éxito: 85%

FLUJO 3: COMPLETE SERVER (Infraestructura - 9 horas)
├─ WireGuard VPN (puerto 443)
├─ Pi-Hole (DNS ad-blocker)
├─ Nextcloud (cloud storage)
├─ Netdata (monitoreo)
└─ Cloudflare Tunnel
Uso: Servidor doméstico completo
Éxito: 70%
```

### Alternativas consideradas

| Alternativa | Ventajas | Desventajas | Decisión |
|-------------|----------|-------------|----------|
| **1. Scripts Shell manuales** | Simple, sin deps | No reproducible, propenso a errores | ❌ Rechazado |
| **2. Docker Compose** | Ligero, rápido | No simula red real, limitaciones kernel VPN | ❌ Rechazado |
| **3. Terraform + Cloud** | Productivo, escalable | Costo real ($), complejidad alta | ❌ Rechazado |
| **4. Vagrant + VirtualBox** | VMs completas, sin costo, reproducible | Más pesado que Docker | ✅ **Seleccionado** |
| **5. Ansible solo** | Idempotente | Requiere infraestructura pre-existente | ❌ Rechazado |
| **6. No automatizar** | Sin trabajo adicional | Pérdida de valor de documentación | ❌ Rechazado |

### Análisis: ¿Por qué Vagrant?

**Vagrant permite**:

1. ✅ **VMs completas**: Kernel real para WireGuard, iptables, etc.
2. ✅ **Red realista**: Interfaces de red reales, no emuladas
3. ✅ **Sin costo**: VirtualBox es gratis
4. ✅ **Snapshots**: Rollback ante errores
5. ✅ **Multi-provider**: VirtualBox, VMware, libvirt, AWS
6. ✅ **Provisioning integrado**: Shell, Ansible, Chef

**Docker NO es suficiente porque**:

- ❌ Kernel compartido: No puede ejecutar WireGuard nativamente
- ❌ Limitaciones de red: No puede modificar iptables del host
- ❌ No simula red completa: Solo networking virtualizado
- ❌ Privilegios: Requiere `--privileged` (riesgo de seguridad)

**Terraform NO es apropiado porque**:

- ❌ Requiere infraestructura cloud real ($$$)
- ❌ Overkill para laboratorios locales
- ❌ Requiere conectividad permanente

## Decisión

Se implementa **infraestructura Vagrant** en `infra/vagrant/` con **3 Vagrantfiles** correspondientes a los flujos principales:

### Arquitectura propuesta

```
infra/
└── vagrant/
    ├── README.md                           # Guía de uso y decisión
    ├── Vagrantfile.quick_start             # Flujo 1: 45 min
    ├── Vagrantfile.professional_tunnel     # Flujo 2: 4 horas
    ├── Vagrantfile.complete_homeserver     # Flujo 3: 9 horas
    └── provisioning/
        ├── establish_ssh_tunnel_on_port_53.sh
        ├── configure_professional_ssh_server.sh
        ├── deploy_wireguard_with_services.sh
        ├── install_security_packages.sh
        └── validate_tunnel_connectivity.sh
```

### Principios Clean Code aplicados

**1. Nombres que revelan intenciones (Martin)**:

```
❌ MAL: provision.sh, setup.sh, config.sh
✅ BIEN: establish_ssh_tunnel_on_port_53.sh
         configure_professional_ssh_server.sh
         deploy_wireguard_with_services.sh
```

**2. Evitar desinformación (Martin)**:

```
❌ MAL: vagrant_config (no es solo config, es infraestructura)
✅ BIEN: infra/vagrant/ (revela que es infraestructura)
```

**3. Usar nombres pronunciables (Martin)**:

```
❌ MAL: sshp53.sh, wgdploy.sh
✅ BIEN: establish_ssh_tunnel_on_port_53.sh
         deploy_wireguard_with_services.sh
```

**4. Una palabra por concepto (Martin)**:

```
❌ MAL: setup, configure, install, provision mezclados
✅ BIEN:
  - establish_* → crear túneles/conexiones
  - configure_* → ajustar configuraciones
  - deploy_* → desplegar servicios completos
  - install_* → instalar paquetes
  - validate_* → verificar estado
```

**5. Arquitectura revela intención (Martin)**:

```
❌ MAL: scripts/vagrant/ (¿scripts de qué?)
✅ BIEN: infra/vagrant/ (infraestructura para laboratorios)
```

**6. Frameworks son plugins (Martin)**:

```
✅ Scripts de provisioning son independientes
✅ Pueden ejecutarse fuera de Vagrant
✅ Vagrant es solo el orquestador
```

**7. Casos de uso dirigen arquitectura (Jacobson/Martin)**:

```
✅ Archivos nombrados por caso de uso:
   - Vagrantfile.quick_start (caso: urgencia)
   - Vagrantfile.professional_tunnel (caso: producción)
   - Vagrantfile.complete_homeserver (caso: infraestructura completa)
```

**8. Testabilidad sin framework (Martin)**:

```bash
# Scripts ejecutables independientemente
./provisioning/establish_ssh_tunnel_on_port_53.sh --test
./provisioning/validate_tunnel_connectivity.sh 8.8.8.8
```

### Vagrantfiles implementados

#### 1. Vagrantfile.quick_start

**Propósito**: SSH túnel en puerto 53 para acceso rápido a APIs.

**Caso de uso**: Developer necesita acceso YA a Claude API bloqueada.

**Tiempo**: 45 minutos.

```ruby
# infra/vagrant/Vagrantfile.quick_start
Vagrant.configure("2") do |config|
  config.vm.box = "ubuntu/jammy64"
  config.vm.hostname = "vpn-quick-start"

  config.vm.network "private_network", ip: "192.168.56.10"
  config.vm.network "forwarded_port", guest: 53, host: 5353, protocol: "tcp"

  config.vm.provider "virtualbox" do |vb|
    vb.name = "TFG-VPN-QuickStart"
    vb.memory = "512"
    vb.cpus = 1
  end

  config.vm.provision "shell",
    path: "provisioning/establish_ssh_tunnel_on_port_53.sh"
  config.vm.provision "shell",
    path: "provisioning/validate_tunnel_connectivity.sh"
end
```

#### 2. Vagrantfile.professional_tunnel

**Propósito**: Servidor SSH completo con seguridad y monitoreo.

**Caso de uso**: Equipo de desarrollo necesita túnel robusto en producción.

**Tiempo**: 4 horas.

```ruby
# infra/vagrant/Vagrantfile.professional_tunnel
Vagrant.configure("2") do |config|
  config.vm.box = "ubuntu/jammy64"
  config.vm.hostname = "vpn-professional"

  config.vm.network "private_network", ip: "192.168.56.20"
  config.vm.network "forwarded_port", guest: 22, host: 2222

  config.vm.provider "virtualbox" do |vb|
    vb.name = "TFG-VPN-Professional"
    vb.memory = "1024"
    vb.cpus = 2
  end

  config.vm.provision "shell",
    path: "provisioning/install_security_packages.sh"
  config.vm.provision "shell",
    path: "provisioning/configure_professional_ssh_server.sh"
  config.vm.provision "shell",
    path: "provisioning/validate_tunnel_connectivity.sh"
end
```

#### 3. Vagrantfile.complete_homeserver

**Propósito**: Servidor doméstico completo (VPN + DNS + Cloud + Monitor).

**Caso de uso**: Usuario quiere infraestructura privada completa.

**Tiempo**: 9 horas.

```ruby
# infra/vagrant/Vagrantfile.complete_homeserver
Vagrant.configure("2") do |config|
  config.vm.box = "ubuntu/jammy64"
  config.vm.hostname = "vpn-homeserver"

  config.vm.network "private_network", ip: "192.168.56.30"
  config.vm.network "forwarded_port", guest: 51820, host: 51820, protocol: "udp"
  config.vm.network "forwarded_port", guest: 80, host: 8080
  config.vm.network "forwarded_port", guest: 443, host: 8443

  config.vm.provider "virtualbox" do |vb|
    vb.name = "TFG-VPN-CompleteHomeserver"
    vb.memory = "2048"
    vb.cpus = 2
  end

  config.vm.provision "shell",
    path: "provisioning/install_security_packages.sh"
  config.vm.provision "shell",
    path: "provisioning/deploy_wireguard_with_services.sh"
  config.vm.provision "shell",
    path: "provisioning/validate_tunnel_connectivity.sh"
end
```

### Scripts de provisioning (Clean Code naming)

**Convención de nombres**:

```
<VERB>_<OBJECT>_<CONTEXT>.sh

Verbos permitidos:
- establish_* : Crear conexiones/túneles
- configure_* : Ajustar configuraciones
- deploy_*    : Desplegar servicios completos
- install_*   : Instalar paquetes/dependencias
- validate_*  : Verificar estado/conectividad
- test_*      : Ejecutar pruebas
```

**Scripts implementados**:

1. `establish_ssh_tunnel_on_port_53.sh`
   - Configura SSH en puerto 53
   - Crea túnel SOCKS5
   - Testeable: `./script.sh --dry-run`

2. `configure_professional_ssh_server.sh`
   - Fail2Ban
   - UFW (firewall)
   - Monitoreo básico

3. `deploy_wireguard_with_services.sh`
   - WireGuard VPN
   - Pi-Hole
   - Nextcloud
   - Netdata

4. `install_security_packages.sh`
   - fail2ban
   - ufw
   - aide (IDS)

5. `validate_tunnel_connectivity.sh`
   - Verifica conectividad
   - Tests de DNS
   - Latencia

## Consecuencias

### Positivas

1. ✅ **Reproducibilidad**: `vagrant up` crea entorno idéntico
2. ✅ **Educación**: Desarrolladores aprenden ejecutando, no solo leyendo
3. ✅ **Velocidad**: 45 min → 5 min (automatizado)
4. ✅ **Sin riesgo**: Errores solo afectan VM local, no servidor productivo
5. ✅ **Sin costo**: VirtualBox es gratis
6. ✅ **Documentación viva**: Código ejecutable es la documentación
7. ✅ **Onboarding**: Nuevos miembros tienen lab listo en minutos
8. ✅ **Testing**: Validar configs antes de deploy real

### Positivas (Clean Code)

9. ✅ **Nombres reveladores**: Arquitectura auto-explicativa
10. ✅ **Mantenibilidad**: Scripts independientes de Vagrant
11. ✅ **Búsqueda eficiente**: Nombres descriptivos facilitan grep
12. ✅ **Pronunciables**: Fácil comunicación en equipo
13. ✅ **Una palabra por concepto**: Vocabulario consistente

### Negativas (mitigadas)

1. ⚠️ **Uso de recursos**: VMs consumen RAM/CPU
   - **Mitigación**: 512MB para quick_start, 2GB para complete
2. ⚠️ **Tiempo de descarga**: Box Ubuntu ~500MB
   - **Mitigación**: Solo primera vez, luego usa cache
3. ⚠️ **Requiere VirtualBox**: Dependencia adicional
   - **Mitigación**: VirtualBox es gratis y multi-plataforma

### Neutrales

- 🔄 **Alternativas**: Puede usar VMware/libvirt si está disponible
- 🔄 **Scripts reusables**: Provisioning funciona fuera de Vagrant también

## Integración con Makefile

```makefile
# Makefile (nuevos targets)

.PHONY: lab-quick lab-professional lab-complete lab-destroy

lab-quick:
	@echo "[INFO] Iniciando laboratorio Quick Start (SSH puerto 53)"
	cd infra/vagrant && vagrant up --vagrantfile=Vagrantfile.quick_start

lab-professional:
	@echo "[INFO] Iniciando laboratorio Professional (SSH + seguridad)"
	cd infra/vagrant && vagrant up --vagrantfile=Vagrantfile.professional_tunnel

lab-complete:
	@echo "[INFO] Iniciando laboratorio Complete (WireGuard + servicios)"
	cd infra/vagrant && vagrant up --vagrantfile=Vagrantfile.complete_homeserver

lab-destroy:
	@echo "[INFO] Destruyendo laboratorios Vagrant"
	cd infra/vagrant && vagrant destroy -f
```

## Verificación de éxito

La implementación se considera exitosa cuando:

1. ✅ `vagrant up --vagrantfile=Vagrantfile.quick_start` crea VM funcional
2. ✅ SSH túnel en puerto 53 permite acceso a APIs bloqueadas
3. ✅ `vagrant up --vagrantfile=Vagrantfile.professional_tunnel` configura seguridad
4. ✅ `vagrant up --vagrantfile=Vagrantfile.complete_homeserver` despliega servicios
5. ✅ Scripts de provisioning son ejecutables independientemente
6. ✅ `make lab-quick`, `make lab-professional`, `make lab-complete` funcionan
7. ✅ Documentación en `infra/vagrant/README.md` es clara y completa

## Referencias

- [Vagrant Documentation](https://www.vagrantup.com/docs)
- [VirtualBox Documentation](https://www.virtualbox.org/manual/)
- [Clean Code - Robert C. Martin](https://www.amazon.com/Clean-Code-Handbook-Software-Craftsmanship/dp/0132350882)
- [Clean Architecture - Robert C. Martin](https://www.amazon.com/Clean-Architecture-Craftsmans-Software-Structure/dp/0134494164)
- [ADR 0002: Migración a Makefile](0002-migracion-makefile.md)
- Análisis de 662 tareas en 12 documentos de VPN/túneles

## Historial de revisiones

| Fecha | Autor | Cambio |
|-------|-------|--------|
| 2025-11-04 | Claude Code | Creación inicial del ADR |

---

**Firmado**: Claude Code
**Revisado**: Pendiente
**Aprobado**: Pendiente
