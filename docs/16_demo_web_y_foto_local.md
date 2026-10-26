# Dos navegadores para la presentación y foto en Frente a frente

## Foto de la sesión

En Frente a frente, el nombre de cada jugador se compara con el username del perfil de la sesión, ignorando espacios al principio/final y diferencias de mayúsculas. Si coincide y existe una foto cargada, se muestra esa foto. Si coinciden los dos, se muestra en ambos paneles.

Se reutilizan `PerfilProvider.fotoBytes`, `MemoryImage`, `PanelJugadorLocal` y `PlayerInfo`. No se consultan perfiles ajenos. Si no hay foto o el nombre es distinto, se muestra el icono de persona. La pantalla escucha al provider para actualizarse cuando termina de cargar la foto.

## Demostración con dos navegadores

1. Dejar el PC encendido, con el servidor web ejecutándose y conexión a Internet.
2. En el PC abrir `http://127.0.0.1:55321/`.
3. En la tablet conectada a la misma red del PC abrir `http://192.168.4.249:55321/`. Esa es la IP actual del PC y puede cambiar al cambiar de red. También se pueden usar dos pestañas o ventanas en el mismo PC.
4. Iniciar sesión y completar el perfil si la aplicación lo solicita.
5. En ambos: Multijugador local → Local Wi-Fi. La web indica «Juntos desde el navegador».
6. Una persona elige Crear sala y comparte el código de seis dígitos. La otra elige Unirme a una sala, escribe ese código y pulsa Conectar.
7. El anfitrión juega con blancas y el invitado con negras. Los retos, las opciones aleatorias y el historial usan la misma pantalla y el mismo motor que Android.

Para una nueva demostración se crea una sala nueva. Si se cierra o recarga una pestaña, no se recupera la partida anterior. La conexión termina al salir o al detectar que dejó de responder el rival.

Comando desde `chess_ercise/`:

```powershell
$env:FLUTTER_WINDOWS='false'
$env:FLUTTER_LINUX='false'
$env:FLUTTER_MACOS='false'
flutter run -d web-server --wasm --no-pub --web-hostname 0.0.0.0 --web-port 55321 --dart-define-from-file=supabase.local.json
```

Si la tablet no abre la URL, comprobar que está en la misma red del router y que Windows permite el servidor en esa red. No se ha cambiado la configuración del firewall. El servidor debe mantenerse abierto durante la clase. Se puede presentar en dos pestañas del PC si la red de la clase impide acceder desde otro dispositivo.

## Transporte web y Android

La web utiliza Supabase Realtime Broadcast y requiere Internet; no requiere instalar el APK. La app Android conserva sus sockets y el acceso `IP:puerto/código` de la misma red local. Para la demostración descrita, ambos jugadores usan la versión web. Una sala web no se conecta con una sala del APK.

`LanTransporte` selecciona el transporte por plataforma. `usaCodigo` indica al controller que debe aceptar un código de seis dígitos en lugar de una dirección IP. El anfitrión sigue validando las jugadas; el invitado reproduce los comandos aceptados, incluidas las dos opciones del reto. No se añadieron tablas ni se cambiaron políticas de Supabase.

Los mensajes de la sala web llevan un identificador aleatorio por participante y el destinatario. Se conserva un único rival. Se intercambian latidos cada cinco segundos y se considera perdida la conexión tras 35 segundos sin mensajes del rival. Las salas de esta versión usan canales públicos por código, pensados para la demostración; no hay persistencia ni recuperación de partidas.

## Verificación

80 pruebas locales aprobadas; la prueba de integración de Realtime se omite cuando no se proporciona configuración. También se ejecutó por separado con la configuración local y pasó contra Supabase real: dos clientes intercambiaron movimientos, captura, opciones, aceptación/Listo y salida.

Se verificaron dos pestañas reales de la aplicación: crear sala, unirse mediante código, e4, d5 y exd5; ambos jugadores recibieron la captura y su estado de reto. La prueba desde la tablet queda pendiente. El APK y la web fueron compilados; el análisis no presenta incidencias.

Para repetir solo la integración real:

```powershell
flutter test test/realtime_partida_test.dart --no-pub --dart-define-from-file=supabase.local.json
```

Bloques y capturas internos: `docs/bloques/B14/`.
