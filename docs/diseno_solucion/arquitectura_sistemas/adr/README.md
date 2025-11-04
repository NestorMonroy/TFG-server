# Architecture Decision Records (ADR)

Registro de decisiones arquitectónicas siguiendo el estándar MADR.

## ADRs Activos

| ID | Título | Estado | Fecha | Descripción |
|----|--------|--------|-------|-------------|
| [0001](0001-ejecucion-codex.md) | Codex CLI | DEPRECADO | - | Sistema original de ejecución (reemplazado por Makefile) |
| [0002](0002-migracion-makefile.md) | Migración a Makefile | ACEPTADO | - | Sistema actual de automatización con GNU Make |
| [0003](0003-servidor-mcp-shell.md) | Servidor MCP en Shell | ACEPTADO | 2025-11-04 | Integración con asistentes de IA vía Model Context Protocol |
| [0004](0004-migracion-mkdocs.md) | Migración a MkDocs | ACEPTADO | 2025-11-04 | Migración de DocFX a MkDocs para generación de documentación |
| [0005](0005-vagrant-laboratorios-vpn.md) | Vagrant para Laboratorios VPN | ACEPTADO | 2025-11-04 | Infraestructura automatizada para laboratorios de VPN y túneles de red |

## Convenciones

- **ACEPTADO**: Decisión aprobada e implementada
- **PROPUESTO**: Decisión en revisión
- **DEPRECADO**: Decisión obsoleta, reemplazada por otra
- **RECHAZADO**: Decisión evaluada pero no implementada

## Formato

Todos los ADRs siguen el formato MADR (Markdown Architectural Decision Records):

1. **Contexto**: Situación y problema que motiva la decisión
2. **Alternativas consideradas**: Opciones evaluadas con pros/contras
3. **Decisión**: Alternativa seleccionada y justificación
4. **Consecuencias**: Impactos positivos, negativos y neutros
