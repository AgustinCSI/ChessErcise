# Bitácora de ChessErcise

Fecha inicial: 23 de octubre de 2026, America/Santiago.

## Registro cronológico

| Fecha | Etapa | Actividad y evidencia | Resultado | Próximo paso autorizado |
|---|---|---|---|---|
| 2026-10-23 | Diagnóstico inicial, previo a B01 | Inventario de los cinco archivos versionados; estado/historia Git; README e ignore; clases 5–7 recuperadas desde su contenido público; metadatos SDK/paquetes; lectura puntual de API Lichess | Auditoría y planificación documentadas; árbol inicial limpio; ninguna app Flutter existente; sin comandos de ejecución/build/pruebas de app | Revisión de la planificación por el equipo. Ningún bloque de implementación autorizado todavía |
| 2026-10-23 | Entrega documental | Creados documentos 00–04, esta bitácora y plantilla de bloques; verificación de integridad y enlaces locales descrita en auditoría | Documentación preparada para revisión; los resultados de aplicación siguen pendientes | Esperar decisiones y aprobación para iniciar B01 |
| 2026-10-24 | Revisión solicitada por el equipo | Leídos propuesta DOCX y trece páginas del PDF, con revisión visual; D01 LAN, D02 Android, D04 Listo y D06 lunes 26 confirmados | Sustituidas suposiciones de un dispositivo/ranking; requisitos y arquitectura conciliados; plan dividido en catorce bloques con partes por commit | Confirmar prioridad online y cerrar detalles de rechazo/categorías/perfil; no iniciar funcionalidades automáticamente |
| 2026-10-24 | Documentación interna y acceso | Regla `/docs/bloques/` agregada; sin archivos de esa carpeta previamente versionados; panel Supabase accesible | Organización CheerErcise Free sin proyectos visibles; formulario preparado como ChessErcise sin enviarlo ni seleccionar GitHub. Conector propuesto, conexión no verificada | Usuario completa credencial/creación en el panel; luego verificar el proyecto concreto y continuar configuración del bloque correspondiente |
| 2026-10-24 | Control final de revisión | Diez Markdown, ocho públicos: enlaces/cierres/campos/estados correctos; ignore confirmado; hashes de fuentes conservados; índice y HEAD sin cambios | Revisión documental completada, aplicación aún no iniciada; formulario Supabase sigue en New Project | Completar proyecto y responder prioridad online; después revisar la parte a autorizar |
| 2026-10-25 | Avance del equipo y conciliación del plan | Revisados commits 0b0c221/2ece14d y merge cdaaecd; main publicada coincide con local; app en chess_ercise/ con contador y test de plantilla | B02 en progreso: estructura aportada, no funciones de producto. Dart requerido ^3.13.5 frente a binario instalado 3.12.2; validación bloqueada. No se corrió pub get/analyze/test/build | Revisar informe 07 y autorizar cierre de B02 empezando por SDK común; conservar trabajo del compañero y ejecutar futuros comandos en chess_ercise/ |

## Estado por bloque

| Bloque | Estado técnico | Documento que se creará al trabajar | Aprobación para avanzar |
|---|---|---|---|
| B01 | En progreso documental; falta cierre de decisiones/proyecto externo | `bloques/B01/B01_01_alcance.md` | Pendiente |
| B02 | En progreso: estructura aportada; validación bloqueada por SDK | `bloques/B02/B02_01_estructura.md` | Pendiente |
| B03 | Pendiente | `bloques/B03/B03_01_dependencias.md` | Pendiente |
| B04 | Pendiente | `bloques/B04/B04_01_configuracion.md` | Pendiente |
| B05 | Pendiente | `bloques/B05/B05_01_modelo.md` | Pendiente |
| B06 | Pendiente | `bloques/B06/B06_01_lista.md` | Pendiente |
| B07 | Pendiente | `bloques/B07/B07_01_modelo_api.md` | Pendiente |
| B08 | Pendiente | `bloques/B08/B08_01_posicion.md` | Pendiente |
| B09 | Pendiente | `bloques/B09/B09_01_host.md` | Pendiente |
| B10 | Pendiente | `bloques/B10/B10_01_protocolo.md` | Pendiente |
| B11 | Pendiente | `bloques/B11/B11_01_captura.md` | Pendiente |
| B12 | Pendiente; prioridad online por confirmar | `bloques/B12/B12_01_autorizacion.md` | Pendiente |
| B13 | Pendiente; prioridad online por confirmar | `bloques/B13/B13_01_stream.md` | Pendiente |
| B14 | Pendiente | `bloques/B14/B14_01_validacion.md` | Pendiente |

La numeración vigente es la revisión del 24-10 del documento 04; la anterior no correspondía a desarrollo ya realizado. Las rutas representan el primer reporte futuro de cada bloque; habrá uno por parte. No se crean reportes de implementación de partes que no se han trabajado. El reporte interno `bloques/P00_revision_2026_10_24.md` registra solamente esta revisión y el ignore, sin declarar código de aplicación completado.

## Decisiones y verificaciones abiertas

| Pendiente | Referencia | Momento de resolución |
|---|---|---|
| Prioridad online para el lunes: no retirarlo sin decisión | Requisitos RF05 y pregunta al equipo | B01 |
| Rechazo de castigo, categoría de valor, cantidades y campos de registro/perfil | D04 y mockups | B01; comprobar B06/B11 |
| Completar proyecto Supabase y verificar identidad; dos cuentas de prueba | D05 y documento 06 | Preparar ahora; Auth B04; SQL autorizado B05 |
| Rúbrica adicional si llega | D06; fecha lunes 26 y sección 1 ya identificadas | Conciliar cuando se aporte |
| Unificar Dart ^3.13.5 del proyecto con entorno local 3.12.2; validar base/ignore | Informe 07 y B02 | Antes de resolver dependencias o cerrar B02 |
| Motor/tablero compatibles con SDK, resolución y comportamiento real | Arquitectura | B03 |
| Autorización de SQL concreto y pruebas de aislamiento | Plan B05 | Dentro de B05, antes de ejecutar SQL |
| Red local y dos Android para pruebas | D01 y arquitectura | B09–B11 |

## Cómo mantener la bitácora

Agregar una fila fechada cuando haya trabajo verificable, bloqueo real, cambio de decisión o aprobación. Registrar el alcance autorizado y el resultado real; enlazar el documento del bloque. Actualizar también el estado en el plan. No convertir pasos propuestos en ejecuciones ni asociar aprobación a silencio o transcurso del tiempo. Los commits y otras escrituras Git requieren permiso explícito, aunque se apruebe un bloque de desarrollo.
