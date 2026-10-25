# 07 · Revisión del avance aportado por el equipo

Fecha: 25 de octubre de 2026. Referencia inspeccionada: `cdaaecd3b90bc77ac36e26ce1b522d21f0e202b2`. Resultado: **base Flutter generada, B02 parcial; funcionalidades de ChessErcise pendientes**.

## 1. Alcance de esta revisión

Se revisaron historia Git, archivos de aplicación/pruebas, dependencias, configuración Android y documentación. Se consultó la cabecera publicada con `git ls-remote --heads origin`: solo se anunció main y su hash coincidió con HEAD local. No fue necesario pull, merge, fetch o cambiar de rama.

Al comenzar, el árbol estaba limpio y main no tenía commits pendientes de publicación según su referencia local. La consulta de la cabecera remota confirmó esa coincidencia en el momento de la revisión. No se infieren avances no publicados en el computador del compañero.

La revisión solo actualiza documentación del plan. No modifica código Dart, dependencias, SDK o configuraciones de compilación; tampoco implementa un bloque por iniciativa propia.

## 2. Qué aportó cada commit reciente

| Commit | Autor y mensaje | Resultado comprobado |
|---|---|---|
| `0b0c221` | Juan Pablo Molina · Flutter create inicial | App en `chess_ercise/`, con lib/main.dart, prueba de contador, pubspec y plataformas generadas. También una copia de la propuesta en la raíz |
| `2ece14d` | Juan Pablo Molina · Added .vscode to ignore list | Regla .vscode en el ignore de raíz |
| `32fe3c7` | AgustinCSI · Documentacion Arquitectura orden | Documentación, propuesta, PDF y regla de carpeta interna |
| `cdaaecd` | AgustinCSI · Merge branch main | Integra la base y la documentación; no añade funcionalidades Dart |

`git diff 0b0c221 HEAD -- chess_ercise/lib chess_ercise/test chess_ercise/pubspec.yaml chess_ercise/analysis_options.yaml` no mostró cambios: esos archivos siguen como en el commit de creación.

## 3. Aplicación existente y cómo funciona

La raíz Git es `ChessErcise/`, pero **la raíz Flutter es `ChessErcise/chess_ercise/`**. Ahí se encuentra pubspec.yaml y ahí deben ejecutarse los comandos Flutter futuros. No repetir flutter create en la raíz del repositorio.

Solo hay dos archivos Dart en lib/test:

| Archivo | Qué contiene | Qué verifica o representa |
|---|---|---|
| `chess_ercise/lib/main.dart` | main, MyApp, MyHomePage y su State; contador de plantilla | Interfaz Flutter genérica, sin funciones de ChessErcise |
| `chess_ercise/test/widget_test.dart` | Counter increments smoke test | Prueba escrita de contador 0→1; todavía no ejecutada en esta revisión |

`main` llama a runApp. MyApp construye MaterialApp con tema y la pantalla genérica. MyHomePage es StatefulWidget; su State guarda `_counter`. `_incrementCounter` suma dentro de setState y la reconstrucción refleja el valor en Text. El botón flotante invoca ese callback. Es el patrón básico de estado de clase 5, pero **no implementa ajedrez, autenticación o navegación de producto**.

La prueba monta MyApp, busca 0, toca el icono + y espera 1. Que el test exista no demuestra que haya pasado en este computador ni que pruebe los requisitos del proyecto.

## 4. Dependencias y bloqueo principal

`chess_ercise/pubspec.yaml` declara únicamente Flutter, cupertino_icons, flutter_test y flutter_lints. No declara Provider, Dio, supabase_flutter, chessground, dartchess o web_socket_channel. Tampoco hay modelos, servicios, providers o pantallas separados.

**Bloqueo de SDK verificado:**

- El proyecto exige Dart `^3.13.5` (al menos 3.13.5, antes de 4.0.0).
- Los metadatos instalados indican Flutter 3.44.8 y Dart 3.12.2.
- Se ejecutó directamente el binario Dart del SDK y confirmó **Dart SDK version: 3.12.2**.

La versión disponible no satisface la restricción del proyecto. Antes de resolver dependencias, analizar o compilar, hay que acordar un SDK común con el compañero y verificar toda la base generada. No se bajó la restricción ni se actualizó Flutter para ocultar la discrepancia. La revisión no inventa la versión exacta de Flutter usada por el compañero: debe obtenerse de su entorno o verificarse con su revisión de SDK.

El proyecto generado usa Gradle 9.3.1 y declara Android Gradle Plugin 9.1.0/Kotlin 2.4.0. Se registran para validar el conjunto después de alinear Flutter; no se afirma un fallo adicional sin compilación.

## 5. Diferencias y pendientes técnicos

| Hallazgo | Evidencia | Tratamiento propuesto |
|---|---|---|
| App en subcarpeta frente a plan original en raíz | Existe `chess_ercise/pubspec.yaml`; no existe pubspec en raíz | Continuar sobre la carpeta creada, anteponer ese prefijo a rutas de app y no mover archivos ahora |
| Plataformas extra | Se generaron android, ios, linux, macos, web y windows | Mantener Android como único objetivo; no eliminar carpetas durante esta revisión ni dedicarles desarrollo |
| Lockfile ausente/ignorado | No existe pubspec.lock; el ignore de raíz aplica `*.lock` | Revisar en B02.03 para conservar resolución reproducible tras SDK compatible |
| Wrapper Android no presente ni versionado | gradlew, gradlew.bat y gradle-wrapper.jar ausentes; reglas Android los ignoran | Revisar cómo se regenera y validar build reproducible. No afirmar que esa ausencia por sí sola prueba un fallo: las herramientas Flutter pueden regenerar archivos |
| Dependencias no resueltas en este checkout | No existe .dart_tool/package_config.json | No confundir errores de imports sin resolución con defectos de código; resolver solo tras alinear SDK |
| main.dart aún concentra la plantilla | Solo contador en lib/main.dart | B02.02 debe separar app/pantalla de forma pedagógica, sin empezar todas las funciones |
| INTERNET solo en manifiestos de desarrollo/profile | No aparece en main/AndroidManifest.xml; sí en debug | Añadir/verificar en el bloque de red y probar APK release; no afecta el contador sin red actual |
| Dos propuestas DOCX en ubicaciones distintas | Raíz y docs; comparación de párrafos/tablas | No hay diferencia funcional de requisitos en la extracción; sí formato y texto residual. Conservar ambas sin decidir/eliminar por iniciativa propia; confirmar una fuente canónica al entregar |

Identificador Android, nombre visible, iconos y README de la aplicación siguen siendo los de plantilla. Son tareas de configuración/presentación, no prueba de que una partida esté implementada.

## 6. Estado real frente al plan

| Bloque | Estado comprobado | Qué falta |
|---|---|---|
| B01 | En progreso documental | Cerrar prioridad online/reglas restantes y verificar proyecto Supabase externamente; no se inspeccionó su panel en esta revisión |
| B02 | **En progreso; validación bloqueada por SDK** | Unificar SDK, resolver dependencias, arranque/pruebas Android, separar raíz y revisar ignore |
| B03 | Pendiente | Paquetes de ajedrez, adaptador de reglas y tablero |
| B04 | Pendiente | Acceso real, AuthGate y menú |
| B05–B06 | Pendientes | Tabla/RLS/servicio y UI CRUD de ejercicios |
| B07–B08 | Pendientes | API del puzzle y resolución/ejercicio |
| B09–B11 | Pendientes | Transporte Wi-Fi, partida sincronizada y desafíos/Listo |
| B12–B13 | Pendientes | Autorización y partida Lichess online; prioridad por confirmar |
| B14 | Pendiente | Verificación integral y artefacto Android |

No hay un bloque funcional terminado que permita saltar directamente a integración. Sí existe trabajo aprovechable de inicialización y aportes Git visibles del compañero: no hay que borrarlo ni repetirlo.

## 7. Verificaciones realizadas y no realizadas

| Verificación | Resultado real |
|---|---|
| git status, log y remote | Estado inicial limpio; historia/autores/destinos comprobados |
| `git ls-remote --heads origin` | main remota coincide con HEAD local |
| Inventario de Dart y lectura de pubspec/pruebas/Android | Plantilla inicial, sin funciones de producto |
| Comparación Git de archivos Dart/config desde 0b0c221 | Sin cambios posteriores en los archivos revisados |
| Binario `dart.exe --version` del SDK en PATH | 3.12.2, inferior a restricción del proyecto |
| check-ignore y existencia de lock/wrapper/package_config | Ignorados/ausentes según los casos descritos |
| Lectura/comparación de ambas propuestas | Sin diferencia funcional de requisitos en texto extraído; originales intactos |
| `flutter analyze`, `flutter test`, `flutter run`, build APK | **No ejecutados**: SDK incompatible y dependencias sin resolver. No se reportan como fallidos o exitosos |
| Proyecto Supabase, cuentas/tabla/servicio externos | No inspeccionados hoy; ausencia de integración en código no demuestra ausencia de un proyecto externo |

La lectura inicial de pubspec en la raíz falló porque la app se creó en subcarpeta; se corrigió la ruta, sin generar otra app. Un script de comparación DOCX tuvo un error de sintaxis en el script de auditoría; se corrigió y repitió. Ninguno era un error del código de Flutter del compañero.

## 8. Próximo paso recomendado

Revisar y autorizar **el cierre de B02**, comenzando por B02.01: acordar el SDK común con el compañero y verificar la base existente. Después, B02.02 separa raíz/pantalla, y B02.03 corrige qué archivos se versionan. Cada parte tendrá su explicación y commit manual independiente.

En paralelo a esa decisión, confirmar si el proyecto Supabase ya fue creado y la prioridad de online para el lunes 26. No empezar B03 o instalar sus paquetes para intentar sortear el bloqueo de SDK. No se cambió código funcional, hicieron commits o publicaron cambios en esta revisión.
