# Wi-Fi: historial disponible y retos integrados

Fecha: 26-10-2026. Referencia: `MockupIdeaBatallaLocalWifi.pdf`.

## Cómo funciona

Durante una partida Local Wi-Fi puedes tocar una jugada de la tira o usar las flechas inferiores para consultar posiciones anteriores. La tira es el mismo componente `TiraJugadas` que usa el puzzle diario.

El historial está disponible mientras juega el rival, mientras elige un reto y durante la respuesta o realización del ejercicio. Consultarlo solo cambia la vista de tu dispositivo. No cambia la partida ni envía movimientos al rival.

Si llega una jugada nueva mientras revisas una anterior, la vista conserva el índice elegido. El contador inferior indica `Jugada X de Y`; `Volver a la partida` muestra la posición actual. Para mover piezas debes estar en vivo y tener el turno. Los botones de reto corresponden siempre al reto actual, incluso si estás consultando una posición anterior.

## Presentación

- En vertical: panel del rival, tira de jugadas, tablero y panel propio. Ambos paneles se leen en la orientación normal del dispositivo.
- En horizontal: tablero e historial a la izquierda y los dos paneles a la derecha.
- Los retos aparecen dentro del panel propio; ya no se abre un diálogo que tape el historial.
- El panel del rival informa de su estado sin permitir realizar acciones en su nombre.
- Se reutilizan las ilustraciones transparentes, las tarjetas roja/verde, la tipografía ampliada y los puntos animados del panel de Frente a frente.
- Durante un reto, el tablero en vivo tiene la capa oscura del mockup. Al consultar el historial se retira esa capa para ver las piezas con claridad.
- Las acciones se bloquean si se pierde la conexión o se espera confirmación. Salir y consultar el historial siguen disponibles.

## Componentes y lógica

`PartidaWifiScreen` conserva un índice local `_vista`; recibe las posiciones y el historial del controller existente. `PanelJugadorLocal` añade un modo `soloLectura` para la ficha rival y un mensaje de estado opcional para conexión o confirmación. `TiraJugadas`, `TableroInteractivo`, `PlayerInfo` y el protocolo de red se reutilizan.

## Verificación

77 pruebas aprobadas; análisis sin incidencias. Las pruebas cubren actualización recibida durante revisión, selección de reto por el rival mientras se consulta el historial, aceptación/rechazo integrados, retorno a la posición actual y bloqueo de movimientos históricos. La suite incluye las pruebas existentes de sockets reales en loopback y de tamaños reducidos, tablet, horizontal y texto ampliado.

La revisión visual se hizo con la pantalla real y un transporte simulado, en una vista interna separada del inicio normal de la aplicación. Se verificaron 390 × 844 y 844 × 390. Esto no sustituye la prueba física entre dos Android en la misma red Wi-Fi.

Los bloques por función y las capturas están en `docs/bloques/B13/`. Commit sugerido: `feat(wifi): integrar retos y mantener disponible el historial compartido`.
