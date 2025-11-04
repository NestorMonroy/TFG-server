# Directrices de Desarrollo con Claude Code
## Estándares para Desarrollo Asistido por IA

---

**FECHA:** 2025-11-04
**VERSIÓN:** 2.0.0
**ESTADO:** [VIGENTE] Estándar aplicable a todo el proyecto
**FUENTES:** Claude Code Version 2.0.0 (2025-09-29), Documentación oficial Anthropic

---

## RESUMEN EJECUTIVO

Este estándar establece las directrices fundamentales para el desarrollo asistido con Claude Code, garantizando que el asistente de IA actúe de manera precisa, minimalista y alineada con los principios del proyecto. Estas reglas se aplican **siempre** durante cualquier sesión de desarrollo y deben ser reforzadas mediante system reminders.

---

## 1. Principios Fundamentales

### 1.1 Precisión y minimalismo

> **Concepto clave:** Hacer exactamente lo que se solicita, sin acciones adicionales no requeridas.

Claude Code debe ejecutar únicamente las tareas explícitamente solicitadas por el usuario, evitando sobreingeniería o extensiones no autorizadas.

**Indicador lingüístico:** "Do what has been asked; nothing more, nothing less."

---

## 2. Gestión de Archivos

### 2.1 Restricción de creación de archivos

> **Regla obligatoria:** NUNCA crear archivos a menos que sean absolutamente necesarios para lograr el objetivo.

**Indicadores de cumplimiento:**
- ✓ Evaluar si el objetivo puede lograrse modificando archivos existentes
- ✓ Consultar al usuario antes de crear nuevos archivos cuando exista ambigüedad
- ✗ Crear archivos "por si acaso" o de manera preventiva

### 2.2 Prioridad de edición sobre creación

> **Regla obligatoria:** SIEMPRE preferir editar un archivo existente antes que crear uno nuevo.

**Razón:** Mantener la estructura del proyecto coherente y evitar proliferación innecesaria de archivos.

**Ejemplos válidos de edición vs creación:**

| Situación | Acción correcta | Acción incorrecta |
|-----------|----------------|-------------------|
| Agregar función a módulo existente | Editar el módulo | Crear nuevo archivo con la función |
| Actualizar documentación | Editar README.md existente | Crear nuevo-README.md |
| Corregir configuración | Editar config.json | Crear config-new.json |

---

## 3. Documentación

### 3.1 Restricción de archivos de documentación

> **Regla obligatoria:** NUNCA crear proactivamente archivos de documentación (*.md) o README. Solo crearlos si el usuario lo solicita explícitamente.

**Indicadores de cumplimiento:**
- ✓ Usuario solicita: "Crea un README para este módulo" → Crear
- ✗ Usuario solicita: "Implementa autenticación" → NO crear README automáticamente
- ✗ Después de implementar feature → NO crear documentación sin solicitud

**Excepciones permitidas:**
1. Usuario solicita explícitamente la creación
2. Estándar del proyecto requiere documentación obligatoria (verificar con usuario)
3. Parte de una plantilla o scaffold autorizado

---

## 4. Tabla resumen de reglas

| # | Regla | Aplicación | Prioridad |
|---|-------|-----------|-----------|
| 1 | Hacer solo lo solicitado | Todas las tareas | CRÍTICA |
| 2 | No crear archivos innecesarios | Gestión de archivos | CRÍTICA |
| 3 | Preferir edición sobre creación | Gestión de archivos | ALTA |
| 4 | No crear documentación proactivamente | Archivos *.md, README | ALTA |

---

## 5. System Reminders

Para garantizar el cumplimiento de estas directrices, se deben incluir los siguientes system reminders en el contexto de Claude Code:

```xml
<system-reminder>
As you answer the user's questions, you can use the following context:
## important-instruction-reminders
Do what has been asked; nothing more, nothing less.
NEVER create files unless they're absolutely necessary for achieving your goal.
ALWAYS prefer editing an existing file to creating a new one.
NEVER proactively create documentation files (*.md) or README files. Only create documentation files if explicitly requested by the User.

IMPORTANT: this context may or may not be relevant to your tasks. You should not respond to this context unless it is highly relevant to your task.
</system-reminder>
```

---

## 6. Mecanismos de aseguramiento

### 6.1 Validación pre-acción

Antes de crear cualquier archivo, Claude Code debe:

1. Verificar si existe un archivo similar que pueda editarse
2. Evaluar si la creación es absolutamente necesaria
3. En caso de duda, consultar al usuario

### 6.2 Checklist de cumplimiento

- [ ] ¿La tarea requiere crear un nuevo archivo?
- [ ] ¿Es imposible lograr el objetivo editando archivos existentes?
- [ ] ¿El usuario solicitó explícitamente la creación?
- [ ] ¿Es documentación (*.md)? → Requiere solicitud explícita

### 6.3 Revisión continua

Los desarrolladores deben:

1. Revisar periódicamente los archivos creados por Claude Code
2. Reportar violaciones a estas directrices
3. Reforzar las reglas mediante feedback explícito

---

## 7. Ejemplos prácticos

### 7.1 Escenario correcto

**Usuario:** "Agrega validación de email al formulario de registro"

**Claude Code:**
1. Identifica el archivo del formulario existente
2. Edita el archivo agregando la validación
3. NO crea archivos de configuración adicionales
4. NO crea documentación sobre la validación

### 7.2 Escenario incorrecto

**Usuario:** "Agrega validación de email al formulario de registro"

**Claude Code (incorrecto):**
1. ~~Crea nuevo archivo validators/email.js~~
2. ~~Crea README.md explicando el validador~~
3. ~~Crea tests/email.test.js sin que se soliciten~~
4. ~~Crea CHANGELOG.md con el cambio~~

**Corrección:** Solo editar el formulario existente, nada más.

---

## 8. Integración con el flujo de trabajo

### 8.1 En desarrollo local

Configurar Claude Code con estas directrices en `.claude/settings.json`:

```json
{
  "systemReminders": [
    "Do what has been asked; nothing more, nothing less.",
    "NEVER create files unless absolutely necessary.",
    "ALWAYS prefer editing existing files.",
    "NEVER proactively create documentation files."
  ]
}
```

### 8.2 En revisión de código

Durante code reviews, verificar:

- Archivos nuevos creados → ¿Eran necesarios?
- Documentación generada → ¿Fue solicitada?
- Ediciones vs creaciones → ¿Se priorizó edición?

---

## 9. Conclusiones

- Estas directrices garantizan que Claude Code opere de manera eficiente y predecible
- Reducen ruido en el repositorio al evitar archivos innecesarios
- Mantienen el control del desarrollador sobre la estructura del proyecto
- Aseguran alineación con los principios de minimalismo y precisión

---

## 10. Referencias

1. Claude Code Official Documentation (2025-09-29)
2. System Prompt Anthropic Claude Agent SDK v2.0.0
3. Estándares internos del proyecto TFG

---

**NOTA DE IMPLEMENTACIÓN:** Este estándar debe ser configurado en todos los entornos de desarrollo que utilicen Claude Code y verificado en cada pull request.
