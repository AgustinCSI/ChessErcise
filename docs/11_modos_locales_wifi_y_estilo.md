# 11 · Frente a frente, Local Wi-Fi y estilo de los mockups

Fecha: 26-10-2026. Nueva instrucción del usuario: conservar Frente a frente y recuperar, como **segunda opción**, los enfrentamientos entre dos dispositivos en la misma Wi-Fi. Ambos son modos locales. Online por Lichess permanece como integración posterior.

## Navegación y diseño

Inicio → Multijugador local → dos cuadros: **Frente a frente** y **Local Wi-Fi**. El primero conserva la preparación de nombres y la partida en un dispositivo. El segundo abre un lobby para crear o unirse a una sala.

Se revisaron visualmente las páginas 2, 7 y 10–13 de [los mockups del equipo](ChessErciseMockupsUso.pdf). Se trasladaron al tema común el fondo rosa claro, las tarjetas fucsia, acentos morados y las casillas blancas/rosas. Las tarjetas de modos son el mismo widget en Inicio, selector local y lobby. No se agregaron fuentes, imágenes o paquetes externos. Las ilustraciones y relojes dibujados en los mockups no se presentan como funciones implementadas: los retos usan iconos Material y esta versión no tiene reloj de partida.

## Cómo probar Wi-Fi

1. Instalar la aplicación Android en ambos dispositivos, entrar con las cuentas necesarias para acceder al menú y conectarse a la misma Wi-Fi.
2. Abrir Multijugador local → Local Wi-Fi. Se reutiliza como nombre inicial el PerfilProvider ya cargado; se puede editar el alias de esta partida.
3. Una persona pulsa Crear sala. Juega con blancas y comparte un acceso con formato `192.168.1.5:45000/123456`. Es un ejemplo: la aplicación muestra IP, puerto y código reales de esa sala.
4. La otra pulsa Unirme a una sala, introduce ese acceso y pulsa Conectar. Juega con negras. Si aparecen varias direcciones en el anfitrión, escoger la correspondiente a su Wi-Fi.
5. Jugar por turnos. Una captura pausa el tablero: el capturador elige el reto, el afectado acepta/Listo o rechaza/Tomar shot/Continuar. Cada uno actúa en su propio dispositivo.
6. La tira de jugadas y las flechas permiten revisar posiciones anteriores. Volver a la partida restaura la vista en vivo. Revisar nunca envía un movimiento ni cambia la posición compartida.
7. Salir solicita confirmación y cierra la sala. Una desconexión bloquea nuevas jugadas y requiere crear otra sala; no se promete reconexión o migración de anfitrión.

El APK de desarrollo se genera en `chess_ercise/build/app/outputs/flutter-apk/app-debug.apk`. Para compilar con la configuración propia, usar `flutter build apk --debug --dart-define-from-file=supabase.local.json` dentro de chess_ercise. El JSON y los registros locales continúan ignorados; no incluirlos en Git.

## Navegador y Android

Frente a frente sigue funcionando en la ejecución web de desarrollo con WebAssembly. Allí también se pueden revisar selector y lobby Wi-Fi, pero crear/conectar salas queda deshabilitado con una explicación visible. El transporte usa dart:io en Android/nativo y una implementación no disponible en web, elegida por importación condicional; no se simula una conexión para ocultar esa diferencia.

El target del SDK Flutter comprobado es 36. Se conserva INTERNET, ya presente, sin activar permisos futuros o cambiar ajustes del computador. Debe revisarse el permiso de red local si se actualiza a target 37: [documentación Android](https://developer.android.com/privacy-and-security/local-network-permission). No se modificaron el manifiesto, firewall o configuración de la red durante este trabajo.

## Qué se reutilizó

| Componente existente | Uso compartido |
|---|---|
| AppTheme | Paleta y esquema de tablero únicos para puzzle, Frente a frente y Wi-Fi |
| TableroInteractivo | Misma integración Chessground, validación visual y ciclo de vida del controlador |
| PlayerInfo | Fichas del rival y jugador en Wi-Fi, sin crear otro componente de perfil |
| PuzzleMoves | Conserva su API; adapta el puzzle a TiraJugadas, extraída de su implementación original |
| TiraJugadas | Mismo historial SAN, iconos de piezas, selección y desplazamiento automático para puzzle y Wi-Fi |
| PartidaLocalController | Una sola implementación de ajedrez libre, capturas, fases y retos; Wi-Fi no duplica estas reglas |
| PanelJugadorLocal | Mismas opciones, aceptación, Listo y animación shot; en Wi-Fi recibe callbacks de red y se muestra como diálogo |
| PerfilProvider | Alias inicial del lobby, sin consultar de nuevo Supabase ni crear perfiles invitados |

## Funciones y protocolo

El anfitrión es la autoridad. El invitado envía intenciones con revisión esperada; el anfitrión verifica color, turno, fase y legalidad mediante el controller existente. Una orden válida incrementa la revisión. Una atrasada, repetida o ilegal recibe el estado aceptado sin aplicarse.

Se envía el registro de comandos aceptados, con versión 1. El invitado reconstruye la partida usando el mismo controller y motor, incluido el historial. La revisión cuenta acciones del protocolo; el índice de historial cuenta solamente jugadas de ajedrez. No son el mismo número.

| Archivo relativo a chess_ercise/lib | Funciones principales |
|---|---|
| data/lan_transporte.dart | Contrato abrir, conectar, enviar, cerrar y fábrica condicional |
| data/lan_transporte_io.dart | HttpServer, upgrade WebSocket, una plaza de invitado, lectura, ping, límite de mensaje y liberación |
| data/lan_transporte_stub.dart | Explica la indisponibilidad del transporte en web |
| logic/partida_lan_controller.dart | abrir/unirse preparan sala y saludo; _orden envía o valida; _aplicar reutiliza reglas; _recibir valida revisión y reconstruye; _fallar/cerrar/dispose detienen y liberan |
| logic/partida_local_controller.dart | historial, posicionEn y jugadaEn exponen revisión de posiciones sin mutar el juego |
| presentation/widgets/tira_jugadas.dart | Selección, notación y seguimiento de la jugada visible, extraídos del puzzle |
| presentation/widgets/puzzle_moves.dart | Adaptador que conserva las llamadas anteriores del puzzle |
| presentation/widgets/panel_jugador_local.dart | Callbacks opcionales de red; conserva acciones locales por defecto |
| presentation/widgets/tarjeta_modo.dart | Tarjeta compartida de navegación con título, explicación e icono |
| presentation/screens/local/local_modes_screen.dart | Las dos opciones de multijugador local |
| presentation/screens/local/wifi_lobby_screen.dart | Validación, creación/entrada, alias del perfil y propiedad del controller de sala |
| presentation/screens/local/partida_wifi_screen.dart | Vista por color, historial local, diálogo de retos y confirmación de salida |

Se usa el servidor y WebSocket del SDK, sin instalar otra biblioteca de transporte: [HttpServer.bind](https://api.dart.dev/dart-io/HttpServer/bind.html), [WebSocketTransformer.upgrade](https://api.dart.dev/dart-io/WebSocketTransformer/upgrade.html).

## Límites y validación

Una sala admite anfitrión y un invitado, IP IPv4 privada manual, código temporal y hasta 1000 acciones. No hay búsqueda automática, cifrado TLS, reconexión, relojes, rendición/oferta de tablas ni persistencia de partidas. Usar una red local de confianza; el código no sustituye autenticación fuerte. Se transmiten alias y comandos de partida, no credenciales ni datos privados del perfil. El acceso al menú mantiene el flujo Auth/Perfil existente; no se declara la aplicación completa utilizable sin Internet.

Pruebas nuevas: sockets reales en loopback para saludo, turnos, capturas, ambos caminos de reto, historial, desconexión, revisión atrasada/duplicada, código incorrecto y tercer jugador. Pruebas de widgets para las dos tarjetas, revisión sin alterar la partida, modal compartido y cuatro tamaños con texto ampliado. Estas pruebas no certifican dos teléfonos en una red real: esa comprobación sigue pendiente, incluyendo aislamiento de clientes y condiciones del router.

Resultado final del 26-10: análisis sin incidencias y **62 pruebas aprobadas**, incluidas las anteriores del perfil/puzzle. APK debug compilado con supabase.local.json; main real compilado con WebAssembly y revisados menú, selector y lobby en la sesión existente del navegador. Se inspeccionaron también renderizados de widgets de la partida Wi-Fi y su modal; esos renderizados usan datos de prueba y no se presentan como una sesión de red Android.

## Partes para commits manuales

1. **Estilo compartido:** AppTheme, TableroInteractivo y TarjetaModo. `style(app): aplicar paleta rosa y morada de los mockups`.
2. **Historial reutilizado:** TiraJugadas, adaptador PuzzleMoves y getters de historial en PartidaLocalController. `refactor(chess): compartir tira de jugadas entre puzzle y wifi`.
3. **Transporte y sincronización:** tres archivos lan_transporte, PartidaLanController y lan_socket_test. `feat(lan): conectar anfitrion e invitado y validar comandos`.
4. **Selector e interfaz Wi-Fi:** HomeScreen, LocalModesScreen, WifiLobbyScreen, PartidaWifiScreen, callbacks de PanelJugadorLocal y local_modes_wifi_test. `feat(local): elegir frente a frente o wifi con historial y retos`.
5. **Documentación vigente:** documento 11, README, requisitos, arquitectura, plan y bitácora. `docs(local): documentar ambos modos y pruebas de red`.

No se hizo stage, commit, push ni modificaciones externas de Supabase. Los reportes por función y celda están en docs/bloques/, ignorados por Git. El ajuste de centrado de la revisión anterior permanece pendiente en el árbol; revisarlo por separado al preparar los commits.
