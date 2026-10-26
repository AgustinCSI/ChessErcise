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

| 2026-10-25 | Merge autorizado de acceso y puzzle | Pull --ff-only de 294e4b1 a bdda951, ocho commits, sin conflictos; revision de 33 archivos cambiados | Auth/menu, puzzle, tablero, cache/progreso y resumen en codigo; 24 pruebas escritas no ejecutadas por SDK. Lockfile e INTERNET principal corregidos; rutina/CRUD/LAN/online pendientes | Alinear SDK y configurar ejecucion, validar codigo recibido y continuar lo pendiente; informe 08 |

| 2026-10-25 | Ejecución real sin emulador | Flutter 3.47.8/Dart 3.13.7; dependencias resueltas con flags de escritorio desactivados solo en el proceso; análisis sin incidencias y 24 pruebas aprobadas; main real abierto en Edge/Wasm con JSON local y Auth settings HTTP 200 | Pantalla de ingreso observada; lanzador iniciar_app.cmd y guía 09 añadidos. JSON ignorado; sin sesión de usuario, SQL, cambios globales ni commits | Usuario prueba su ingreso; validar flujos restantes y Android. Reporte interno B02_04_ejecucion_real_edge.md |

| 2026-10-25 | Local en un dispositivo, rama MultijugadorLocal | Usuario reemplaza LAN por juego frente a frente y prioriza local antes de online. Tablero compartido extraído; controller de partida, catálogo inicial y paneles orientados con retos implementados | Capturas, aceptar/Listo y rechazo/shot en código y pruebas; menú habilitado. Cambios previos de puzzle conservados; sin commits ni transporte LAN | Revisar modo local en Android físico con dos personas; después online. Alcance y funciones en documento 10 |

| 2026-10-26 | Revisión visual tras merge de perfil ec26edb | Árbol inicial limpio; inspeccionados componentes existentes de perfil y menú inferior; sesión real abierta, jugadas locales y captura/reto/rechazo/continuación probados | Corregido centrado del juego en ventanas horizontales sin duplicar componentes. Regresión 1024x800 reproducida antes del arreglo; análisis correcto y 51 pruebas aprobadas después | Revisar comodidad entre dos personas en Android; continuar online después del modo local. Reporte interno B10_02_revision_visual_y_merge_perfil.md; sin commits |

| 2026-10-26 | Dos modos locales y revisión de mockups | Usuario solicita Frente a frente y recuperar Local Wi-Fi; revisadas páginas 2/7/10–13 del PDF; paleta compartida, tarjetas de selección, transporte y pantalla Wi-Fi implementados | Tablero, motor, ficha, retos y tira de jugadas reutilizados. Sockets reales en loopback prueban ambos jugadores y desafíos; APK Android compilado; sin modificar Supabase | Probar dos Android en la misma Wi-Fi y revisar comodidad; después continuar online. Documento 11 y reportes internos por parte; sin commits |

| 2026-10-26 | Respuestas al reto y contraste | Aplicada nueva referencia: botones rojo/verde del mismo tamaño, rechazo a la izquierda; texto oscuro y etiquetas reforzados desde el tema compartido | Mismo panel y callbacks para Frente a frente/Wi-Fi; análisis correcto y 62 pruebas aprobadas; captura interna revisada | Revisar el diseño actualizado. Reporte B11_03_respuestas_y_contraste.md; sin commits |

| 2026-10-26 | Respaldo de imágenes del historial | Revisada captura de asset fallido; bundle y HTTP del alfil/rey correctos actualmente; puzzle real abre sin reproducir el fallo intermitente | Tira compartida muestra letra SAN cuando falla una imagen, sin perder historial o selección; 64 pruebas aprobadas, incluida simulación de recursos ausentes | Revisar puzzle/Wi-Fi actualizados; reporte B10_04_respaldo_assets_historial.md. Sin commits |

| 2026-10-26 | Merge de main e integración de barras | Merge ya iniciado desde f9a7f63 sobre MultijugadorLocal 5129bca; único conflicto en el tema, resuelto combinando intro y paleta existente | Introducción conservada; barras claras con borde, contraste y selección visibles. Corregida espera inestable de prueba de intro; análisis correcto y 69 pruebas aprobadas | Terminar commit local autorizado, sin push. Documento 12 y reporte B02_05_merge_intro_tema.md |

| 2026-10-26 | Catálogo de nueve ejercicios y selección aleatoria | Incorporados los nueve nombres solicitados; cada captura guarda dos opciones distintas y permite elegir solo entre ellas | Frente a frente y Wi-Fi reutilizan el mismo catálogo. Host comparte el par mediante protocolo 2; análisis correcto y 75 pruebas aprobadas | Actualizar ambos Android para Wi-Fi; lista y cantidades en documento 13; reporte B11_04_catalogo_aleatorio.md. Sin commits |

## Estado por bloque

| Bloque | Estado técnico | Documento que se creará al trabajar | Aprobación para avanzar |
|---|---|---|---|
| B01 | En progreso documental; falta cierre de decisiones/proyecto externo | `bloques/B01/B01_01_alcance.md` | Pendiente |
| B02 | En progreso: SDK compatible, análisis y 24 pruebas correctos; ejecución real en navegador comprobada; falta Android | `bloques/B02/B02_04_ejecucion_real_edge.md` | Ejecución sin emulador autorizada; resto pendiente |
| B03 | En progreso: motor/tablero de puzzle; falta validacion y contratos generales | `bloques/B03/B03_01_dependencias.md` | Pendiente |
| B04 | En progreso: codigo Auth/menu; falta verificar con Supabase real | `bloques/B04/B04_01_configuracion.md` | Pendiente |
| B05 | Pendiente | `bloques/B05/B05_01_modelo.md` | Pendiente |
| B06 | Pendiente | `bloques/B06/B06_01_lista.md` | Pendiente |
| B07 | En progreso: API/detalle/animaciones en codigo; validar ejecucion | `bloques/B07/B07_01_modelo_api.md` | Pendiente |
| B08 | En progreso: resolucion/cache/resumen; falta ejercicio por fallo y Listo | `bloques/B08/B08_01_posicion.md` | Pendiente |
| B09 | En progreso: base compartida y transporte Wi-Fi recuperado; sockets reales probados | `bloques/B09/B09_04_transporte_wifi.md` | Ambos modos locales autorizados |
| B10 | En progreso: Frente a frente y Wi-Fi con historial compartido; falta revisión física | `bloques/B10/B10_03_historial_wifi.md` | Ambos modos locales autorizados |
| B11 | En progreso: retos/Listo/shot locales y sincronizados; catálogo privado pendiente | `bloques/B11/B11_02_retos_wifi.md` | Ambos modos locales autorizados |
| B12 | Pendiente; sigue después de revisar local | `bloques/B12/B12_01_autorizacion.md` | Siguiente etapa solicitada |
| B13 | Pendiente; depende de acceso online B12 | `bloques/B13/B13_01_stream.md` | Siguiente etapa solicitada |
| B14 | Pendiente | `bloques/B14/B14_01_validacion.md` | Pendiente |

La numeración vigente es la revisión del 24-10 del documento 04; la anterior no correspondía a desarrollo ya realizado. Las rutas representan el primer reporte futuro de cada bloque; habrá uno por parte. No se crean reportes de implementación de partes que no se han trabajado. El reporte interno `bloques/P00_revision_2026_10_24.md` registra solamente esta revisión y el ignore, sin declarar código de aplicación completado.

## Decisiones y verificaciones abiertas

| Pendiente | Referencia | Momento de resolución |
|---|---|---|
| Continuar online después de revisar local, secuencia confirmada por usuario | RF05 y documento 10 | B12–B13 |
| Rechazo de castigo, categoría de valor, cantidades y campos de registro/perfil | D04 y mockups | B01; comprobar B06/B11 |
| Completar proyecto Supabase y verificar identidad; dos cuentas de prueba | D05 y documento 06 | Preparar ahora; Auth B04; SQL autorizado B05 |
| Rúbrica adicional si llega | D06; fecha lunes 26 y sección 1 ya identificadas | Conciliar cuando se aporte |
| Completar validación Android; SDK local 3.13.7 ya compatible, análisis y 24 pruebas pasaron | Informe 09 y B02 | Antes de cerrar B02 |
| Motor/tablero compatibles con SDK, resolución y comportamiento real | Arquitectura | B03 |
| Autorización de SQL concreto y pruebas de aislamiento | Plan B05 | Dentro de B05, antes de ejecutar SQL |
| Comodidad del tablero y controles en un Android físico entre dos personas; LAN sustituida | D01 y documento 10 | B09–B11 |

## Cómo mantener la bitácora

Agregar una fila fechada cuando haya trabajo verificable, bloqueo real, cambio de decisión o aprobación. Registrar el alcance autorizado y el resultado real; enlazar el documento del bloque. Actualizar también el estado en el plan. No convertir pasos propuestos en ejecuciones ni asociar aprobación a silencio o transcurso del tiempo. Los commits y otras escrituras Git requieren permiso explícito, aunque se apruebe un bloque de desarrollo.
