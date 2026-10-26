# Diseño de retos frente a frente

Fecha: 26-10-2026.

Referencia visual: las cinco páginas de `MockupIdeaBatallaFrenteFrente.pdf`. El flujo conserva un panel para cada jugador en su orientación, el tablero central y la paleta rosa de la aplicación.

## Estados de la partida

| Estado | Presentación |
| --- | --- |
| Jugando | Tablero normal y panel activo resaltado. |
| Eligiendo reto | Dos tarjetas en una fila, cada una con la ilustración transparente del ejercicio, su nombre y cantidad. El rival ve un mensaje de espera y tres puntos. |
| Respondiendo | Rechazar a la izquierda en rojo; aceptar a la derecha en verde con la ilustración del ejercicio elegido. La orientación corresponde al jugador que responde. |
| Ejercicio | Tarjeta verde con la imagen y cantidad; confirmación manual con Listo. |
| Rechazo | Tarjeta roja con el icono de copa y la animación existente; botón Continuar. |

Durante los cuatro estados de reto, una capa negra con opacidad del 58 % atenúa únicamente el tablero. Los paneles siguen visibles y conservan su contraste. Al terminar el reto, la capa desaparece y vuelve el turno de ajedrez.

## Reutilización

- `RetoLocal.imagen` relaciona cada ID de ejercicio con uno de los nueve PNG originales de `assets/IconosDeportes/`. La cantidad de la pieza no cambia la ilustración.
- `pubspec.yaml` incluye esa carpeta en el paquete de Flutter.
- `PanelJugadorLocal` reutiliza una función de tarjeta para seleccionar, responder y mostrar el ejercicio en curso. `Image.asset` mantiene la transparencia del PNG y ajusta la figura sin recortarla.
- Se conserva `PlayerInfo`, el tema compartido, las acciones del controller y `TableroInteractivo`.
- Local Wi-Fi reutiliza el mismo panel y recibe sus tarjetas ilustradas. La capa sobre el tablero se aplica específicamente a Frente a frente; el rediseño completo de la pantalla Wi-Fi no forma parte de este cambio.

La carpeta proporcionada contiene nueve ilustraciones de ejercicios. Para el shot se usa el icono de copa de Material que ya empleaba la aplicación. Los nombres y las cantidades siempre proceden del reto seleccionado; los ejercicios por tiempo conservan segundos.

## Validación

75 pruebas aprobadas y `flutter analyze --no-pub` sin incidencias. La prueba del flujo de pantalla comprueba dos ilustraciones correspondientes a las opciones sorteadas y la aparición/desaparición de la capa del tablero. Se mantienen las pruebas de varios tamaños y texto ampliado.

Revisión de la aplicación real en navegador a 390 × 844: selección, respuesta desde ambos extremos, ejercicio aceptado, Listo y rechazo. Web Wasm y APK debug compilados. El detalle por función y las capturas están en `docs/bloques/B12/`, carpeta interna ignorada por Git.

Commit sugerido: `feat(local): aplicar tarjetas ilustradas y transparencia al flujo de retos`.

## Ajuste de legibilidad y espera

Los nombres y mensajes de la partida usan tamaño 18, peso medio y color casi negro; las tarjetas de ejercicios usan tamaño 15. La ficha `PlayerInfo` recibe el estilo opcional del panel y continúa siendo compartida.

Los tres puntos de espera describen una onda suave de 3 píxeles en ciclos de 1200 ms. La animación se limita al indicador, se libera al salir de la espera y respeta la preferencia del sistema de reducir animaciones. Las pruebas del flujo verifican movimiento y eliminación del indicador; las 75 pruebas siguen aprobadas.
