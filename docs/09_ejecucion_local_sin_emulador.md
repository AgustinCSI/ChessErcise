# 09 · Ejecución real sin emulador

Fecha: 25 de octubre de 2026. Resultado: aplicación real abierta en Edge con WebAssembly y configuración Supabase del usuario; formulario de ingreso observado visualmente. No se creó un modo demo ni una sesión ficticia.

## Qué cambió respecto de la revisión anterior

El SDK actual ya es Flutter **3.47.8** con Dart **3.13.7**, confirmado mediante `flutter --version --machine` y doctor. La incompatibilidad del SDK descrita en los informes anteriores ya no bloquea este equipo.

Se ejecutaron `flutter analyze --no-pub` y `flutter test --no-pub`: análisis sin incidencias y **24 pruebas aprobadas**. Esto actualiza el estado de ejecución pendiente de los informes 07/08; no certifica una prueba Android ni registro/ingreso con credenciales reales.

Windows no tiene el compilador de Visual Studio C++ y Chrome no fue localizado por Flutter. Edge sí está disponible. Se probó la ejecución de desarrollo con `--wasm` y compiló correctamente; no se instaló C++, activó Developer Mode o abrió un emulador.

## Archivos y arranque

- `iniciar_app.cmd`, en raíz: abre la app en Edge con `main.dart`, WebAssembly y el archivo de configuración local.
- `.vscode/launch.json`, interno: su primera configuración existente, `chess_ercise`, apunta ahora a Edge y carga ese mismo archivo. Las otras configuraciones se conservaron; se guardó copia privada de la anterior.
- `chess_ercise/README.md`: contiene instrucciones reales de ejecución y configuración.
- `chess_ercise/supabase.local.json`: aportado por el usuario, conservado e ignorado. Solo se comprobaron nombres/tipos de campos y naturaleza pública de la clave; no se copió su contenido a documentación.

Se verificó que el servicio Auth del proyecto responde HTTP 200 y permite acceso por correo. Esa consulta no creó usuarios ni inició una sesión. No se alteró la base de datos, las políticas, la facturación o la configuración remota.

## Por qué no bastaba con Run

Había tres asuntos distintos: selección de dispositivo sin compilador Windows, valores Supabase no suministrados al compilar y regeneración de plugins nativos que pedía enlaces simbólicos.

Flutter permite limitar las plataformas por variables del proceso. El lanzador utiliza `FLUTTER_WINDOWS=false`, `FLUTTER_LINUX=false` y `FLUTTER_MACOS=false` dentro de `setlocal`. La configuración de VS Code también las pasa únicamente a ese lanzamiento. Se verificaron estos nombres y su uso en el SDK instalado (`features.dart` y `project.dart`). No se modificó configuración global de Flutter ni se eliminaron plataformas del repositorio.

Un primer intento con `--no-pub` encontró package_config ausente. La regeneración normal de dependencias resolvió paquetes, pero advirtió falta de symlinks nativos. Con las plataformas de escritorio limitadas al proceso, `flutter pub get` terminó correctamente y el arranque real compiló. El manifiesto y lockfile versionados no cambiaron.

## Cómo usarlo

Haz doble clic en `iniciar_app.cmd` o ejecuta `./iniciar_app.cmd` desde la raíz. Mantén abierta su terminal mientras usas la aplicación. En VS Code abierto en ChessErcise, selecciona `chess_ercise` y usa F5.

La orden principal del lanzador, dentro de chess_ercise, es:

```powershell
flutter run -d edge --wasm --target lib/main.dart --dart-define-from-file=supabase.local.json
```

La ejecución comprobada añadió host 127.0.0.1 y puerto 55321 para inspección visual. El lanzador y F5 dejan elegir puerto disponible, para evitar colisiones entre ejecuciones. Se ejecuta el main normal con AuthGate y Supabase, sin saltar el acceso.

La clave se incorpora como configuración del cliente, igual que en la ejecución móvil. El archivo local sigue ignorado y no se mostró su valor. Si se cambian sus parámetros hay que reiniciar; un hot reload no reemplaza valores compilados.

## Qué se verificó y qué queda por probar

| Comprobación | Resultado |
|---|---|
| Flutter/Dart compatibles con manifiesto | Verificado: 3.47.8 / 3.13.7 |
| Análisis estático | Correcto, sin incidencias |
| Suite existente | 24 pruebas aprobadas |
| Configuración local y protección Git | Campos correctos, clave pública y archivo ignorado |
| Servicio Auth real | HTTP 200; correo habilitado |
| Compilación Edge WebAssembly | Correcta |
| Formulario real en navegador | Observado visualmente, sin aviso de configuración faltante |
| Sesión real de usuario | No iniciada por el agente; el usuario introduce sus credenciales |
| Confirmación de registro por correo | No probada; retorno Android actual requiere configuración de proyecto y prueba propia |
| Puzzle en navegador después de acceso | No probado en esta revisión; suite de lógica/UI nativa aprobada |
| APK Android / LAN / online | No probados por abrir esta vista de desarrollo |

Android sigue siendo la plataforma de entrega. Los paquetes de ajedrez declaran soporte nativo: esta prueba de arranque Wasm no se convierte en una promesa de soporte web de producción o JavaScript normal. [Referencia de ejecución Wasm](https://docs.flutter.dev/platform-integration/web/wasm).

La intervención no cambió funciones Dart, dependencias, datos de usuarios o arquitectura. No se hicieron commits, stage ni push. El siguiente trabajo de desarrollo sigue requiriendo la revisión de su parte correspondiente.
