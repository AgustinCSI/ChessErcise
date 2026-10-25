# 05 · Revisión de propuesta y mockups

Fecha: 24 de octubre de 2026. Resultado: actualizar requisitos, arquitectura y plan con las fuentes nuevas y las aclaraciones del equipo. No se implementó código Flutter.

## 1. Documentos revisados y preservados

| Fuente | Revisión realizada | Integridad SHA-256 |
|---|---|---|
| [Propuesta completada](plantilla-propuesta-flutter.docx) | Lectura de párrafos y tablas; contiene identificación, problema, público, cinco funciones, stack, enlace de diseño, cronograma y riesgos | `437115b9c471f8294637b10b0c228712dd699474ea2134065849f378aa6a738c` |
| [Mockups](ChessErciseMockupsUso.pdf) | Texto de las trece páginas y revisión visual de páginas renderizadas, reunidas en una hoja de contacto | `3e36b624fe1d903c498dd253b30b1b9de22038553fe9343b76ed6871fe080249` |

Los originales no se editaron. Las imágenes de revisión se guardan dentro de `docs/bloques/_revision_mockups/`, carpeta interna ignorada por Git. No son nuevos diseños ni reemplazan el PDF.

La propuesta incluye enlace Canva `https://canva.link/meft4rbg1t2f5hp`. Se identificó el enlace, pero esta revisión utilizó el PDF local y no certifica sus permisos públicos o una aprobación del docente. No se exige rehacer el diseño en Excalidraw para reemplazar un material que el equipo ya produjo; confirmar formato requerido si llega rúbrica.

## 2. Qué aporta la propuesta

El documento identifica sección 1 y una persona de 23 años interesada en combinar ajedrez y ejercicio. Declara las siguientes funcionalidades core:

1. Host y cliente conectados a la misma Wi-Fi.
2. Online mediante Lichess, con cuentas de esa plataforma.
3. Elección de ejercicio por el oponente cuando se pierde una pieza, según su valor.
4. Aceptar/rechazar en LAN, incluyendo una alternativa de trago en el texto aportado.
5. Puzzle diario y penalización de ejercicio al fallar.

También propone expresamente `chessground`, `dartchess` y `web_socket_channel`. Por ello ya no corresponde tratar online/puzzle como ideas inventadas por la auditoría, ni insistir en un tablero construido desde cero sin evaluar el paquete propuesto.

La hipótesis de regulación del estrés se atribuye al documento, sin validación científica en esta auditoría. No se convertirán esas frases en beneficios de salud garantizados.

## 3. Lectura visual del PDF

| Página | Contenido observado | Consecuencia para el desarrollo |
|---|---|---|
| 1 | Logo, piezas, ejercicio y lema | Mantener identidad del equipo; no generar una marca nueva |
| 2 | Presentación de identidad y paleta rosa/morado | Usar como orientación visual; contrastes se comprueban en Android real |
| 3 | Arranque con logo rosa | Pantalla de carga/entrada; el dispositivo dibujado no determina plataforma |
| 4 | Paso de correo y Continuar | Confirmar flujo en dos pasos; aplicar Form/validator como en clase |
| 5 | Contraseña y saludo de retorno | Autenticación real; no revelar si existe una cuenta solo por simular saludo |
| 6 | Registro, usuario, contraseña/confirmación, género y nacimiento | Confirmar campos necesarios antes de almacenar datos adicionales |
| 7 | Menú Online / Local / Puzzle, Juegos y Perfil | Estos tres modos son la estructura principal del producto |
| 8 | Puzzle, tablero rosa y navegación | Reconstruir posición real de API; el texto “mate” debe adaptarse al objetivo real del puzzle |
| 9 | Partida online, jugadores, relojes, rendirse y tablas | Estado online/reloj pertenece a Lichess; asignar controles a bloques concretos |
| 10 | Selección de penalización online | Overlay informativo: no afirmar que detiene el reloj del servidor |
| 11 | Partida LAN | Debe existir en dos Android, no en un teléfono compartido |
| 12 | Rival elige entre ejercicios en LAN | La elección es del capturador; no asignación automática que ignore al rival |
| 13 | Aceptar/rechazar castigo | Después de realizar el ejercicio, añadir confirmación simple “Listo” según la aclaración del usuario |

El marco de iPhone de los mockups se considera presentación gráfica; D02 establece Android únicamente. No se crean recursos iOS ni se persigue fidelidad al marco físico del teléfono.

Faltan diseños detallados de crear/unirse a sala, espera/conexión y administración de ejercicios. Se proponen esas vistas mínimas por necesidades reales de LAN y CRUD académico, sin cambiar la identidad ni los modos del equipo.

## 4. Correcciones respecto de las suposiciones iniciales

| Antes, como propuesta del agente | Ahora, según documentos/usuario |
|---|---|
| Dos amigos compartiendo un teléfono | Dos Android, host/cliente en LAN |
| Ranking como función de API | Puzzle diario como función ya declarada; se retira la sección de ranking sugerida |
| Online/puzzle posteriores sin requisito local explícito | Ambos son core en el documento; cualquier postergación debe acordarse |
| Ejercicio fijado automáticamente por pieza | El oponente elige de opciones compatibles con el valor; definir agrupación exacta |
| Crear un mockup nuevo para B01 | Aprovechar PDF y propuesta existentes; revisar correspondencia, no duplicar trabajo |
| Confirmar fecha y plataforma | Android confirmado; presentación lunes 26 de octubre de 2026 |
| Reportes de bloques junto al resto en Git | Reportes internos, excluidos con `/docs/bloques/` |

## 5. Selección técnica de menor complejidad

La combinación candidata respeta el stack propuesto: chessground presenta el tablero; dartchess calcula reglas; web_socket_channel transmite mensajes. Las pantallas, formularios y providers se escriben con el método del docente. El [paquete de tablero](https://pub.dev/packages/chessground) declara que no contiene reglas, por lo que no reemplaza dartchess.

Para alojar LAN se necesita servidor además del canal cliente. Se recomienda el SDK Dart (`HttpServer` y `WebSocketTransformer`), sin introducir un servidor separado o una nueva biblioteca de descubrimiento inicialmente. Se propone IP/puerto manual; si se desea buscar salas automáticamente, confirmarlo antes de agregar otro paquete. [Dart HttpServer](https://api.dart.dev/dart-io/HttpServer/bind.html), [upgrade WebSocket](https://api.dart.dev/dart-io/WebSocketTransformer/upgrade.html).

La consulta pública del 24-10 a `https://lichess.org/api/puzzle/daily` respondió **HTTP 200**, con objetos `game` y `puzzle`, PGN, initialPly y solución. La respuesta observada también incluía `puzzle.fen` y `lastMove`; el [esquema oficial PuzzleAndGame](https://raw.githubusercontent.com/lichess-org/api/master/doc/specs/schemas/PuzzleAndGame.yaml) los declara opcionales. Pueden simplificar la reconstrucción si se valida su significado con un caso conocido; no asumir que siempre llegarán. Tener 200 en Python no certifica resolución jugable ni integración Android.

El [stream Board de Lichess](https://raw.githubusercontent.com/lichess-org/api/master/doc/specs/tags/board/api-board-game-stream-gameId.yaml) es NDJSON y exige permiso de jugador; no se conecta usando el WebSocket de sala LAN. La autorización online añade trabajo real que debe tener prioridad acordada para el lunes.

## 6. Qué se cambió en esta intervención

- `.gitignore`: regla específica `/docs/bloques/`; no se alteraron todavía los ignores de lockfile o Gradle fuera del pedido actual.
- Documentos 02–04: requisitos conciliados, arquitectura LAN/online/puzzle y plan de catorce bloques con partes pequeñas.
- Documento 06: decisión y procedimiento de preparación Supabase, con estado observado real.
- Plantilla interna: explicación por función/fragmento y ficha por parte/commit.
- Auditoría, análisis académico y bitácora: referencias temporales y metodología actualizadas sin inventar contenido de clases o ejecuciones.

No se hizo stage, commit, push, cambio de rama, creación de app, instalación de paquetes o ejecución SQL. No se conectó ningún repositorio en Supabase. Queda pendiente confirmar prioridad online y los detalles de rechazo/perfil, además de completar el proyecto de base de datos.
