# Guía de Contribución

¡Gracias por tu interés en contribuir a TFG-server! Esta guía te ayudará a configurar tu entorno y seguir nuestras prácticas de desarrollo.

## 📋 Tabla de Contenidos

- [Entorno de Desarrollo](#entorno-de-desarrollo)
- [Flujo de Trabajo](#flujo-de-trabajo)
- [Estándares de Código](#estándares-de-código)
- [Testing](#testing)
- [Documentación](#documentación)
- [Pull Requests](#pull-requests)

## 🛠️ Entorno de Desarrollo

### Opción 1: Desarrollo en Vagrant (Recomendado)

**Ventajas:**
- ✅ Entorno aislado sin contaminar tu sistema
- ✅ Todas las dependencias pre-instaladas
- ✅ Ejecutar CI/tests/docs sin SSH
- ✅ Reproducible en todos los sistemas operativos

**Setup:**

```bash
# 1. Instalar requisitos
# macOS:
brew install --cask vagrant virtualbox

# Ubuntu/Debian:
sudo apt install vagrant virtualbox

# Windows:
choco install vagrant virtualbox

# 2. Clonar repositorio
git clone https://github.com/NestorMonroy/TFG-server.git
cd TFG-server

# 3. Iniciar VM de desarrollo (10 min primera vez)
make lab-dev

# 4. Verificar que todo funciona
make lab-ci
```

**Desarrollo diario:**

```bash
# Editar archivos en tu editor favorito (VSCode, Vim, etc.)
# Los cambios se sincronizan automáticamente con la VM

# Ejecutar CI completo
make lab-ci

# Ejecutar solo tests
make lab-test

# Generar documentación
make lab-docs

# Ver preview de documentación en http://localhost:8000
make lab-docs-serve
```

### Opción 2: Desarrollo en Host

**Requisitos:**
- Python 3.8+
- Node.js 16+
- BATS (testing)
- shellcheck (linting)
- markdownlint-cli2

**Setup:**

```bash
# 1. Clonar repositorio
git clone https://github.com/NestorMonroy/TFG-server.git
cd TFG-server

# 2. Instalar dependencias
make setup
pip install -e .

# 3. Instalar git hooks
./scripts/bash/spec-hooks-install.sh

# 4. Verificar prerequisitos
./scripts/bash/check-prerequisites.sh

# 5. Ejecutar CI
make ci
```

## 🔄 Flujo de Trabajo

### 1. Crear rama de trabajo

```bash
# Usar script helper
./scripts/bash/create-new-feature.sh

# O manualmente siguiendo convención
git checkout -b feature/descripcion-corta
# feat/, fix/, docs/, refactor/, test/, chore/
```

### 2. Implementar cambios

```bash
# Recordatorio de tareas mínimas
./scripts/bash/implement.sh

# Asegúrate de:
# - Actualizar especificaciones si aplica
# - Escribir código siguiendo Clean Code
# - Agregar tests
# - Actualizar documentación
```

### 3. Validar localmente

**Con Vagrant:**
```bash
make lab-ci    # CI completo
make lab-test  # Solo tests
make lab-docs  # Generar docs
```

**Sin Vagrant:**
```bash
make ci        # CI completo
make lint      # Solo linting
make test      # Solo tests
make docs      # Generar docs
```

### 4. Commit

```bash
# Usar Conventional Commits
git add .
git commit -m "feat: agregar soporte para X"
# Los git hooks validarán automáticamente

# Tipos de commit:
# feat:     Nueva funcionalidad
# fix:      Corrección de bug
# docs:     Solo documentación
# refactor: Refactorización sin cambiar funcionalidad
# test:     Agregar o corregir tests
# chore:    Tareas de mantenimiento
```

### 5. Push y Pull Request

```bash
# Push a tu rama
git push -u origin feature/tu-feature

# Crear PR en GitHub
# - Título descriptivo
# - Descripción clara del cambio
# - Incluir tests
# - CI debe pasar
```

## 📝 Estándares de Código

### Clean Code Principles

Seguimos los principios de Clean Code de Robert C. Martin:

1. **Nombres que revelan intenciones**
   ```bash
   # ❌ MAL
   setup.sh

   # ✅ BIEN
   configure_professional_ssh_server.sh
   ```

2. **Funciones pequeñas**
   - Una función = una responsabilidad
   - Máximo 20-30 líneas

3. **Evitar comentarios innecesarios**
   ```bash
   # ❌ MAL
   # Incrementar i
   i=$((i + 1))

   # ✅ BIEN
   readonly MAX_RETRIES=3
   for attempt in $(seq 1 "$MAX_RETRIES"); do
   ```

Ver guía completa: `docs/gobernanza/estandares/claude-code-guidelines.md`

### Bash Scripts

```bash
#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

# Variables en readonly cuando sea posible
readonly SCRIPT_NAME="$(basename "${BASH_SOURCE[0]}")"

# Funciones con nombres descriptivos
validate_prerequisites() {
    # ...
}
```

## 🧪 Testing

### BATS Tests

```bash
# Ejecutar todos los tests
make test

# O con Vagrant
make lab-test

# Tests deben:
# - Cubrir casos felices y edge cases
# - Ser independientes
# - Limpiar después de ejecutar
```

### Agregar nuevo test

```bash
# test/mi_feature.bats
@test "mi_feature hace lo esperado" {
    run ./mi_script.sh
    [ "$status" -eq 0 ]
    [[ "$output" =~ "esperado" ]]
}
```

## 📚 Documentación

### Generar documentación

**Con Vagrant:**
```bash
# Generar HTML
make lab-docs

# Ver preview en http://localhost:8000
make lab-docs-serve
```

**Sin Vagrant:**
```bash
# Generar HTML
make docs

# Servir localmente
mkdocs serve
```

### Actualizar documentación

1. **README.md**: Para cambios que afecten setup/uso
2. **ADRs**: Para decisiones arquitectónicas (`docs/diseno_solucion/arquitectura_sistemas/adr/`)
3. **Procedimientos**: Para workflows (`docs/procedimientos/`)
4. **Código**: Docstrings y comentarios cuando agreguen valor

## 🔍 Pull Requests

### Checklist antes de crear PR

- [ ] ✅ CI pasa localmente (`make lab-ci` o `make ci`)
- [ ] ✅ Tests agregados/actualizados
- [ ] ✅ Documentación actualizada
- [ ] ✅ Commits siguen Conventional Commits
- [ ] ✅ Sin archivos temporales o credenciales
- [ ] ✅ Branch actualizado con main/master

### Template de PR

```markdown
## Descripción
Breve descripción del cambio

## Tipo de cambio
- [ ] Bug fix
- [ ] Nueva funcionalidad
- [ ] Breaking change
- [ ] Documentación

## Testing
Cómo se probó este cambio

## Checklist
- [ ] Tests agregados
- [ ] Documentación actualizada
- [ ] CI pasa
```

## 📖 Recursos

- [Clean Code Guidelines](docs/gobernanza/estandares/claude-code-guidelines.md)
- [Procedimiento Desarrollo Local](docs/procedimientos/procedimiento_desarrollo_local.md)
- [Vagrant Labs](infra/vagrant/README.md)
- [ADR 0005: Vagrant](docs/diseno_solucion/arquitectura_sistemas/adr/0005-vagrant-laboratorios-vpn.md)
- [Conventional Commits](https://www.conventionalcommits.org/)

## ❓ ¿Necesitas ayuda?

- Abre un issue en GitHub
- Consulta `docs/TROUBLESHOOTING.md`
- Revisa los ADRs existentes

---

**Gracias por contribuir! 🎉**
