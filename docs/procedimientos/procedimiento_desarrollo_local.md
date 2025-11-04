# Procedimiento - Desarrollo Local Guiado por Automatizaciones

**Propósito:** Establecer los pasos para preparar el entorno local y ejecutar el flujo diario de desarrollo usando los scripts y objetivos de `Makefile` documentados en `docs/automation/ci-cd.md`.

## Alcance
Aplica a cualquier contribución de código o documentación que se implemente desde estaciones de trabajo locales.

## Roles
- **Persona desarrolladora/analista:** ejecuta el flujo completo y corrige hallazgos.
- **Revisora técnica:** valida que las verificaciones se hayan ejecutado y resuelto.

## Prerrequisitos

### Desarrollo en host (tradicional)
- Repositorio clonado y dependencias instaladas (`make setup`, `pip install -e .`).
- Git hooks instalados mediante `./scripts/bash/spec-hooks-install.sh` para habilitar validaciones automáticas en `pre-commit`, `pre-push` y `post-commit`.
- Herramientas base verificadas con `./scripts/bash/check-prerequisites.sh`.

### Desarrollo en Vagrant (recomendado para entorno limpio)
- Vagrant >= 2.3.0 instalado
- VirtualBox >= 7.0 instalado
- Repositorio clonado en el host
- VM de desarrollo levantada con `make lab-dev`

**Ventajas de desarrollo en Vagrant:**
- ✅ Sin contaminar dependencias del host
- ✅ Reproducible: todos tienen el mismo ambiente
- ✅ Ejecutar CI/tests/docs sin SSH: `make lab-ci`, `make lab-test`, `make lab-docs`
- ✅ Preview de documentación en `http://localhost:8000` con `make lab-docs-serve`

## Frecuencia
Debe ejecutarse al iniciar un trabajo nuevo y repetirse antes de publicar ramas o abrir un Pull Request.

## Pasos

### Opción A: Desarrollo en host (tradicional)

1. **Crear rama de trabajo**
   - Ejecutar `./scripts/bash/create-new-feature.sh` y seguir las instrucciones para nombrar la rama.
2. **Implementar cambios**
   - Utilizar `./scripts/bash/implement.sh` como recordatorio de las tareas mínimas (actualizar especificaciones, código y documentación).
3. **Validación continua local**
   - Lanzar `make ci` (o `./scripts/bash/ci-local.sh`) para ejecutar lint, pruebas BATS y generación de documentación.
   - Si se necesita revisar un paso individual, usar `make lint`, `make test` o `make docs` según corresponda.
4. **Revisión manual adicional**
   - Consultar `docs/TROUBLESHOOTING.md` ante fallos recurrentes y documentar ajustes necesarios.
5. **Preparación para compartir**
   - Confirmar que no existen errores pendientes y que los hooks se ejecutan sin bloqueos.
   - Empaquetar cambios con mensajes de commit siguiendo el estándar Conventional Commits.

### Opción B: Desarrollo en Vagrant (recomendado para entorno limpio)

1. **Iniciar VM de desarrollo** (solo primera vez o después de `vagrant destroy`)
   - Ejecutar `make lab-dev` para crear VM con todas las dependencias
   - Esperar ~10 minutos mientras se instalan BATS, shellcheck, MkDocs, Python, Node.js, etc.

2. **Crear rama de trabajo** (en el host, NO dentro de la VM)
   - Ejecutar `./scripts/bash/create-new-feature.sh` y seguir las instrucciones para nombrar la rama.
   - Los cambios se sincronizan automáticamente con `/vagrant` en la VM gracias al synced folder.

3. **Implementar cambios** (en el host, con tu editor favorito)
   - Editar archivos normalmente en tu máquina
   - Los cambios aparecen instantáneamente en la VM

4. **Validación continua desde el host (SIN entrar a la VM)**
   - Ejecutar `make lab-ci` para correr CI completo dentro de la VM
   - Ejecutar `make lab-test` para correr solo tests
   - Ejecutar `make lab-lint` si existe, o `make lab-exec LAB=development CMD="make lint"`
   - Ver resultados directamente en la terminal del host

5. **Generar y visualizar documentación (SIN entrar a la VM)**
   - Ejecutar `make lab-docs` para generar documentación
     - Los archivos HTML aparecen en `site/` del host
   - Ejecutar `make lab-docs-serve` para preview en vivo
     - Abrir navegador en `http://localhost:8000`
     - Presionar Ctrl+C para detener el servidor

6. **Depuración dentro de la VM** (solo si es necesario)
   - SSH a la VM: `cd infra/vagrant && vagrant ssh --vagrantfile=Vagrantfile.development`
   - Ir al proyecto: `cd /vagrant`
   - Ejecutar comandos manualmente: `make ci`, `bats test/vagrant.bats`, etc.
   - Salir: `exit`

7. **Preparación para compartir**
   - Confirmar que `make lab-ci` pasa sin errores
   - Empaquetar cambios con mensajes de commit siguiendo el estándar Conventional Commits
   - Los commits se hacen en el host, NO dentro de la VM

## Entregables
- Rama actualizada con commits verificados.
- Evidencia de ejecución del flujo (`make ci` exitoso) disponible en el historial local.

## Métricas sugeridas
- Tiempo medio invertido entre `make ci` consecutivos.
- Número de fallos por tipo de verificación (lint/tests/docs) antes de la corrección.

## Referencias
- `docs/automation/ci-cd.md`
- `docs/local-development.md`
- `docs/TROUBLESHOOTING.md`
- `infra/vagrant/README.md` - Documentación completa de laboratorios Vagrant
- [ADR 0005: Vagrant para Laboratorios VPN](../diseno_solucion/arquitectura_sistemas/adr/0005-vagrant-laboratorios-vpn.md) - Decisión arquitectónica sobre Vagrant
