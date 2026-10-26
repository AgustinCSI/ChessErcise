# 10 · Multijugador local frente a frente

Actualización del 25-10-2026, rama `MultijugadorLocal`. La instrucción del usuario reemplaza el diseño LAN: dos personas juegan en **un solo celular o tablet**, sin moverlo ni girarlo entre turnos. Primero se implementa y revisa este modo; después se continúa online. Perfil y detalles del puzzle siguen a cargo del compañero.

## Alcance vigente

- El menú abre **Multijugador local · Un dispositivo**. La preparación solicita los nombres de ambos jugadores; no crea otra cuenta.
- Se mantienen las casillas fijas, con blancas abajo y negras arriba. Las piezas negras y su panel miran hacia la persona de enfrente. Los controles están duplicados mediante el mismo widget, no mediante dos implementaciones.
- En horizontal, la composición completa se orienta sobre el eje largo del dispositivo; no cambia en cada turno.
- Solo se mueve el color al que le toca. El motor valida movimientos, jaque, enroque, promoción y captura al paso.
- Al capturar, quien capturó selecciona un reto para quien perdió la pieza. Este último acepta o rechaza desde su propio panel.
- Aceptar muestra el ejercicio y **Listo**, sin sensores ni comprobaciones físicas. Rechazar muestra una animación **Tomar shot** y **Continuar**. La animación es un mensaje de interfaz, sin verificación de consumo.
- El tablero queda bloqueado durante toda la elección, respuesta y confirmación. El turno siguiente se conserva; resolver un reto no mueve ninguna pieza.
- Si una captura produce mate o tablas, primero se resuelve el reto y luego aparece el resultado. Se puede iniciar una nueva partida. Salir solicita confirmación.

## Componentes reutilizados

`TableroInteractivo` extrae la integración de Chessground que ya estaba en `TableroWidget`: conserva un solo ChessboardController, movimientos legales, última jugada, jaque, pista y liberación en dispose. `TableroWidget` conserva su constructor y propiedad puzzle; ahora es un adaptador que escucha PuzzleController y pasa sus datos al tablero común. No se modificaron PuzzleController, sus modelos, persistencia o pantallas.

La nueva pantalla utiliza ese mismo tablero, `PlayerInfo`, el tema existente, botones Material, Navigator, Form, TextEditingController y ChangeNotifier/ListenableBuilder. El estado pertenece a la pantalla; no necesita un Provider global porque no se comparte fuera de esta partida. No se añadieron dependencias.

Chessground ya ofrece la orientación de piezas enfrentadas; se usa esa opción en lugar de crear imágenes o un tablero propio. [API PieceOrientationBehavior](https://pub.dev/documentation/chessground/latest/chessground/PieceOrientationBehavior.html). Las reglas provienen de dartchess, ya instalado. [API Position](https://pub.dev/documentation/dartchess/latest/dartchess/Position-class.html).

## Estado y funciones

| Archivo, relativo a chess_ercise | Función | Entrada, salida y efecto |
|---|---|---|
| lib/models/reto_local.dart | valorDe, nombreDe, paraPieza | Reciben Role; devuelven valor, nombre y opciones del catálogo inicial |
| lib/logic/partida_local_controller.dart | jugar | Recibe Move; ignora jugadas ilegales o fuera de fase; aplica el motor y detecta captura antes de actualizar la posición |
| mismo controller | elegirReto | Recibe lado e id; solo acepta al capturador y una opción del catálogo |
| mismo controller | responder | Recibe lado y acepta; solo el retado pasa a ejercicio o shot |
| mismo controller | listo | Solo el retado confirma ejercicio/shot; limpia reto y reanuda o finaliza |
| mismo controller | reiniciar | Restablece posición, fase, captura, reto y registro de repeticiones |
| lib/presentation/widgets/tablero_interactivo.dart | _datos y ciclo de vida | Convierte Position a GameData; inicializa, actualiza y libera el controlador visual |
| lib/presentation/widgets/tablero_widget.dart | build | Adapta los datos existentes del puzzle al tablero común |
| lib/presentation/widgets/panel_jugador_local.dart | _activo, _acciones, build | Resuelve qué panel puede actuar, muestra sus botones y anima el rechazo |
| lib/presentation/screens/local/local_setup_screen.dart | _validar, _iniciar, dispose | Valida nombres, navega con datos por constructor y libera campos |
| lib/presentation/screens/local/partida_local_screen.dart | _panel, _salir, build, dispose | Orienta cada zona, confirma salida, escucha estado y libera el controller que creó |
| lib/presentation/screens/home/home_screen.dart | botón local | Navega al formulario; mantiene online pendiente |

Secuencia de fases: `jugando → eligiendoReto → respondiendo → ejercicio/shot → jugando/finalizada`. No se usa un booleano independiente por cada pantalla: la fase evita combinaciones contradictorias. Los métodos del controller verifican lado y fase aunque alguien invoque un callback incorrecto.

## Decisiones iniciales y límites

El catálogo inicial ofrece sentadillas y elevaciones de brazos. Peón=1, caballo/alfil=3, torre=5 y dama=9; ese valor define las repeticiones. Es una decisión provisional de esta implementación, editable en un solo modelo. No se presenta como catálogo privado de Supabase ni reemplaza el CRUD académico B05/B06.

La partida vive en memoria y se pierde al salir o recargar. La entrada actual está en el menú con sesión; dentro de la partida no hay red, segunda cuenta ni sincronización. No se añadió entrada de invitado desde el login.

No hay relojes, rendición, oferta de tablas ni guardado de partidas. En esta versión, tres repeticiones y 100 medias jugadas sin captura/peón cierran automáticamente en tablas, sin reclamación de jugador; es una simplificación local explícita, no una implementación completa del procedimiento de competición. Mate, ahogado y material insuficiente los resuelve el motor.

## Verificación y revisión

Las pruebas nuevas ejercitan la lógica y los controles reales: capturas de ambos colores, actores incorrectos, bloqueo por fase, captura al paso, enroque, promoción, mate con captura, repetición, reinicio, nombres, salida cancelable, aceptar/Listo, rechazo/Continuar, orientación fija y toques de ambas personas sobre las casillas. Se comprueban móvil, tablet y horizontal con texto ampliado.

Resultado: `flutter analyze --no-pub` sin incidencias y `flutter test --no-pub` con 38 pruebas aprobadas (24 anteriores y 14 nuevas). Se compiló el main con WebAssembly y Supabase local. Se revisaron también cuatro capturas de widgets de las fases inicial, elección, respuesta y rechazo; son evidencia de renderizado, no una sesión de usuario ni una prueba en Android físico.

Queda pendiente probar en un Android físico con dos personas, así como revisar comodidad y tamaño del tablero frente a la referencia. La prueba en navegador o widgets no acredita ergonomía en mesa ni una entrega Android.

## Partes para commits manuales

No se crearon commits ni se añadieron archivos al índice. Cada fila forma una parte revisable; las rutas son relativas a chess_ercise/.

| Orden | Archivos | Mensaje sugerido |
|---|---|---|
| 1 · B09.01 | widgets/tablero_interactivo.dart y widgets/tablero_widget.dart, dentro de lib/presentation/ | refactor(chess): compartir tablero entre puzzle y partida local |
| 2 · B09.02 | lib/models/reto_local.dart, lib/logic/partida_local_controller.dart, test/partida_local_controller_test.dart | feat(local): gestionar turnos capturas y retos en un dispositivo |
| 3 · B10/B11 | lib/presentation/screens/local/, lib/presentation/widgets/panel_jugador_local.dart, lib/presentation/screens/home/home_screen.dart, test/partida_local_screen_test.dart | feat(local): jugar frente a frente y responder retos desde cada lado |
| 4 · documentación | Este documento, README, requisitos, arquitectura, plan y bitácora revisados | docs(local): reemplazar LAN por partida en un dispositivo |

Los reportes detallados están en la carpeta interna docs/bloques/, ignorada por Git. Revisar por separado los cambios previos de ejecución/documentación y el puzzle del compañero; no incluirlos accidentalmente en un commit del modo local.
