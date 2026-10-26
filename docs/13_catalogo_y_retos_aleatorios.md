# 13 · Catálogo de ejercicios y dos opciones aleatorias

26-10-2026. El usuario amplía el catálogo a nueve ejercicios y pide que solo aparezcan dos opciones aleatorias en cada reto. Aplica a Frente a frente y Local Wi-Fi. El puzzle diario reutiliza después los ejercicios por repeticiones con su propia regla: [rutina del puzzle](16_rutina_puzzle_diario.md).

## Lista disponible

| Ejercicio | Indicación |
|---|---|
| Flexiones de brazos | Repeticiones |
| Flexiones con rodillas apoyadas | Repeticiones |
| Abdominales tradicionales | Repeticiones |
| Plancha frontal | Segundos |
| Plancha lateral | Segundos |
| Sentadillas | Repeticiones |
| Zancadas | Repeticiones |
| Rodillas al pecho | Repeticiones |
| Trote en el lugar | Segundos |

Este catálogo sustituye el inicial de sentadillas/elevaciones de brazos: no se conserva Elevaciones de brazos como un décimo ejercicio. La fuente única es `chess_ercise/lib/models/reto_local.dart`, constante `RetoLocal.catalogo`.

## Cantidades

Se conserva la escala por valor de pieza para los ejercicios de repeticiones. Para los ejercicios por tiempo se usa inicialmente cinco segundos por punto de valor. Son parámetros de juego editables en el modelo; la confirmación sigue siendo manual con Listo, sin temporizador ni verificación física.

| Pieza capturada | Repeticiones | Duración si corresponde |
|---|---:|---:|
| Peón | 1 | 5 segundos |
| Caballo / alfil | 3 | 15 segundos |
| Torre | 5 | 25 segundos |
| Dama | 9 | 45 segundos |

## Sorteo

- Cada captura genera dos ejercicios distintos tomados del catálogo completo.
- Las dos opciones se guardan en el estado de ese reto; reconstruir la pantalla o consultar opciones no vuelve a sortear.
- El capturador solo puede elegir entre esas dos opciones. Una opción válida del catálogo que no haya sido sorteada se rechaza.
- Después de resolver el reto se limpia la selección; la siguiente captura hace un nuevo sorteo. Un ejercicio puede repetirse en capturas diferentes.
- Se conserva aceptar/Listo y rechazar/Tomar shot/Continuar.

## Wi-Fi: sortear una vez y compartir

El anfitrión sortea incluso cuando quien captura es el invitado. El registro aceptado de cada movimiento contiene los IDs de las dos opciones, o una lista vacía si no hubo captura. El invitado reconstruye utilizando esos IDs y no ejecuta un sorteo independiente.

La reconstrucción exige dos IDs distintos del catálogo y con el valor correcto de la pieza antes de aplicar una captura. El anfitrión ignora opciones propuestas en una orden del invitado y conserva la autoridad del sorteo.

El protocolo de sala pasa a **versión 2**: ambos dispositivos deben instalar la aplicación actualizada. Una versión anterior se rechaza para evitar partidas con catálogos o sorteos diferentes. No hay migración de salas abiertas entre versiones.

## Archivos y funciones

| Archivo | Responsabilidad |
|---|---|
| models/reto_local.dart | catalogo, paraPieza y seleccionarParaPieza: nombres, unidades, cantidades y muestra de dos sin duplicados |
| logic/partida_local_controller.dart | Guarda las opciones una vez por captura; valida opciones de reconstrucción y selección; limpia al confirmar/reiniciar |
| logic/partida_lan_controller.dart | Versión 2, aceptación de órdenes y registro canónico con opciones sorteadas por el anfitrión |
| test/retos_aleatorios_test.dart | Catálogo exacto, muestra de dos, cobertura de los nueve, unidades, estabilidad y validación de reconstrucción |
| test/lan_socket_test.dart | Igualdad de opciones entre dispositivos, rechazo de opciones propuestas por el invitado y de protocolo anterior |
| test/partida_local_screen_test.dart y local_modes_wifi_test.dart | Pruebas de UI adaptadas a las opciones reales y al registro de protocolo 2 |

Las rutas son relativas a chess_ercise/lib, salvo las de test. Se reutilizan los paneles, botones, tablero y flujo de retos existentes; no se creó una segunda interfaz de ejercicios ni una tabla en Supabase.

## Verificación

Análisis sin incidencias y 75 pruebas aprobadas. Los sockets se comprobaron con conexiones reales en loopback del computador; la comprobación física entre dos Android sigue pendiente. La fuente aleatoria puede inyectarse para pruebas repetibles, mientras la aplicación normal utiliza un generador por partida.

## Commit manual sugerido

`feat(challenges): sortear dos ejercicios del catalogo y compartirlos por wifi`.

Incluir modelo, controllers, pruebas y esta actualización documental. No se hizo stage, commit ni push. Los reportes por celda siguen en docs/bloques/, ignorados por Git.
