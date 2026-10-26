# ChessErcise · Flutter Android

## Multijugador local en un dispositivo

Después de ingresar, abre **Multijugador local · Un dispositivo**, escribe los nombres y pulsa **Comenzar partida**. Coloca el celular o tablet entre ambos: blancas en un extremo y negras en el otro. Sus piezas y controles miran hacia su lado; el tablero no gira al cambiar de turno.

Al capturar, el capturador elige un reto del catálogo local inicial. El rival acepta y marca **Listo**, o rechaza y ve **Tomar shot** antes de continuar. El tablero espera durante ese flujo. No requiere Wi-Fi entre jugadores ni una segunda cuenta; la entrada actual al menú usa la sesión existente. La partida no se guarda al salir.

Este modo reemplaza el diseño LAN. Primero se revisa local y después se implementa online. [Detalles, límites y plan de commits](../docs/10_multijugador_local_un_dispositivo.md).

## Abrir sin emulador

Desde la raíz del repositorio, haz doble clic en **iniciar_app.cmd**, o ejecútalo desde PowerShell:

```powershell
.\iniciar_app.cmd
```

Se abre la aplicación real en Microsoft Edge usando WebAssembly y la configuración local de Supabase. Mantén abierta la terminal que la ejecuta. No requiere Android Emulator ni el compilador C++ de Windows.

El lanzador limita las plataformas de escritorio solo dentro de su proceso. Así evita que la preparación de plugins de Windows pida activar Developer Mode o instalar herramientas C++; no cambia ajustes globales ni elimina carpetas de plataforma.

En VS Code abierto en la raíz `ChessErcise`, la configuración local **chess_ercise** de Run usa Edge, `--wasm` y el JSON local. Presiona F5 para iniciar o Shift+F5 para detener esa ejecución. La configuración de `.vscode/` es interna; el lanzador anterior permite repetirlo en otros computadores.

También puedes ejecutarla directamente desde la carpeta de la aplicación:

```powershell
cd chess_ercise
$env:FLUTTER_WINDOWS = 'false'
$env:FLUTTER_LINUX = 'false'
$env:FLUTTER_MACOS = 'false'
flutter run -d edge --wasm --target lib/main.dart --dart-define-from-file=supabase.local.json
```

La opción `--wasm` es necesaria para esta vista de desarrollo: el motor y el tablero utilizan operaciones de 64 bits y no se debe sustituir por una compilación JavaScript normal. Android sigue siendo la plataforma de entrega; esta ejecución en navegador permite trabajar sin emulador y debe comprobarse antes de asumir compatibilidad web de producción.

## Configuración real de Supabase

Crea `chess_ercise/supabase.local.json` con un objeto como este, reemplazando los marcadores por los datos de tu proyecto:

```json
{
  "SUPABASE_URL": "https://TU-PROYECTO.supabase.co",
  "SUPABASE_PUBLISHABLE_KEY": "sb_publishable_TU_CLAVE_PUBLICA"
}
```

El archivo está ignorado por Git. La clave debe ser la pública/publishable del cliente; no uses la contraseña de la base ni una clave administrativa. El lanzador carga este archivo al compilar: si cambias sus valores, detén y vuelve a iniciar la ejecución.

El acceso no está simulado: los botones del formulario usan Supabase Auth. Sin valores válidos, la app muestra el aviso de configuración. La prueba de registro y confirmación por correo requiere además configurar el retorno del proyecto: el código actual utiliza `chessercise://login-callback/` para el flujo Android. La apertura en Edge no acredita por sí sola ese retorno móvil ni una sesión de usuario iniciada.

## Comprobaciones

Dentro de `chess_ercise/`:

```powershell
flutter analyze
flutter test
```

El manifiesto pide Dart `^3.13.5`. En la verificación del 25-10-2026, Flutter 3.47.8 con Dart 3.13.7 ejecutó el análisis sin incidencias y las 24 pruebas existentes pasaron. No hace falta rebajar el SDK del proyecto.
