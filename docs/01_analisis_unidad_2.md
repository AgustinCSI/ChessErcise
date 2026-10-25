# 01 · Análisis verificado de la Unidad 2

> Criterio del equipo confirmado el 24-10-2026: la forma de programación del profesor es la base obligatoria de implementación. Las APIs de ajedrez, el host LAN y los paquetes propuestos se enseñarán como complementos aislados, sin reemplazar formularios, navegación, modelos, servicios y manejo de estado del curso. El plan vigente es la revisión de catorce bloques del documento 04.

Consulta: 23 de octubre de 2026. Fuentes primarias: [clase 5](https://udd-web-mobile.vercel.app/aprende/clase-5), [clase 6](https://udd-web-mobile.vercel.app/aprende/clase-6) y [clase 7](https://udd-web-mobile.vercel.app/aprende/clase-7).

## 1. Método y límites de verificación

La herramienta de lectura web no pudo extraer las tres páginas. HTTP directo respondió 200, pero el HTML era el contenedor de una aplicación cliente, sin las lecciones. Se leyó el archivo JavaScript público referenciado por ese HTML, que incluye los índices, presentaciones, explicaciones, ejemplos Dart y ejercicios. No se ejecutó ese JavaScript ni se accedió al panel privado del docente.

Fuente recuperada: [asset público index-F4pUcS23.js](https://udd-web-mobile.vercel.app/assets/index-F4pUcS23.js), SHA-256 `4ee4702ef85116ecb46e98f66ac98417219db54bab2d2ee3e78c3e6358ce807b`. El nombre del asset puede cambiar con nuevas publicaciones; los enlaces de clase/presentación son las referencias preferidas.

Se verificaron el texto y código de las presentaciones y los enunciados de ejercicios. **No** se reprodujeron todos los videos, ejecutaron playgrounds, enviaron ejercicios al docente ni descargó la plantilla `.docx`. Sus descripciones/enlaces se identificaron, pero no se atribuyen detalles a videos no vistos. No existe material académico adicional dentro del repositorio local.

## 2. Clase 5 · Introducción a Flutter

### Qué se enseñó y cómo se implementó

| Material | Conceptos y construcción comprobados | Aplicación en ChessErcise |
|---|---|---|
| [Presentación 1: introducción](https://udd-web-mobile.vercel.app/aprende/clase-5/presentacion-1) | Composición de widgets, contraste conceptual con Ionic, hot reload y separación entre presentación, estado/lógica y datos | Separar las pantallas de las reglas de partida y del acceso a servicios |
| [Presentación 2: Dart](https://udd-web-mobile.vercel.app/aprende/clase-5/presentacion-2) | Ejemplos de un refugio: variables y tipos, null safety, funciones/parámetros, listas/maps, `where`/`map`, clases, constructores con nombre, getters/setters, abstractas, mixins y asincronía | Modelar ejercicio, jugador y captura; convertir JSON una sola vez; manejar respuestas y fallos asíncronos |
| [Presentación 3: entorno](https://udd-web-mobile.vercel.app/aprende/clase-5/presentacion-3) | Android Studio/SDK/emuladores, Flutter en Windows/Mac, diagnóstico y problemas de herramientas; material de video enlazado | Comprobar el entorno real antes de prometer compilación Android |
| [Presentación 4: contador](https://udd-web-mobile.vercel.app/aprende/clase-5/presentacion-4) | Crear proyecto; extraer `CounterScreen` de `main.dart`; contador con `StatefulWidget` y `setState`; plural; restar/reiniciar; extraer `CustomButton` | Avanzar por cambios pequeños y extraer widgets cuando aparezca repetición |
| [Presentación 5: comandos](https://udd-web-mobile.vercel.app/aprende/clase-5/presentacion-5) | Creación, ejecución, dispositivos, paquetes, diagnóstico, formato, análisis, pruebas y builds | Documentar cada comando con propósito y resultado real |

El contador usa `MaterialApp`, `ThemeData`, `Scaffold`, `AppBar`, `Center`, `Column`, `Text`, `FloatingActionButton`, `Icon` y `SizedBox`. La pantalla conserva el número en su `State`; los callbacks cambian ese dato y avisan con `setState`. El decremento tiene un guard para evitar negativos. Al detectar tres botones semejantes, la forma visual pasa a un widget con icono y callback por constructor, en archivo propio. La lógica del contador permanece en la pantalla. Esta secuencia, y no solo la lista de widgets, orienta el desarrollo.

Dart se trabaja con ejemplos ejecutables y predicción de salida; primero fundamentos, luego colecciones, objetos y asincronía. Se muestran `Future`, `async`/`await`, `try`/`catch`/`finally`, `Stream`, `listen`, `async*` y `yield`. Que un concepto aparezca no significa que debamos usarlo si no resuelve una necesidad.

Ejercicios identificados: [14 de Dart](https://udd-web-mobile.vercel.app/aprende/clase-5/ejercicios/dart), desde fichas/null safety hasta objetos y asincronía; [7 de Flutter](https://udd-web-mobile.vercel.app/aprende/clase-5/ejercicios/flutter), desde pantalla/columna hasta contador, widget propio y adopción. No se ejecutaron.

### Requisitos académicos que afectan el alcance

La presentación 1 solicita una app deportiva en equipos de hasta tres, con API real. Su mínimo incluye:

1. Registrarse, ingresar y salir con Supabase.
2. Mostrar una API deportiva mediante `FutureBuilder`.
3. Abrir detalles pasando el objeto por constructor.
4. Incorporar `Hero` y una animación implícita.
5. Crear, consultar, editar y eliminar datos propios con RLS.
6. Usar `Form`, `TextFormField` y validadores.
7. Compartir estado mediante al menos un `ChangeNotifier` con Provider.
8. Extraer widgets propios a archivos independientes.
9. Mostrar contribuciones de todos en GitHub.

La actividad agrega propuesta de proyecto y mockup de al menos cinco pantallas en Figma, Miro o Excalidraw. No hay evidencia de esos entregables en este repositorio. Ajedrez figura entre las ideas; Lichess figura entre las APIs sugeridas. Esto respalda su pertinencia temática, sin convertir la idea concreta de puzzles sugerida por el docente en una obligación para ChessErcise. [Fuente: presentación 1](https://udd-web-mobile.vercel.app/aprende/clase-5/presentacion-1).

### Qué no se verificó como enseñado aquí

Implementación de reglas de ajedrez, sincronización de partidas y persistencia completa de una partida. La clase introduce capas, pero no impone Clean Architecture, repositorios abstractos ni un árbol único de carpetas.

## 3. Clase 6 · Login, estado, navegación y animaciones

### Login: progresión de ocho pasos

En [presentación 1](https://udd-web-mobile.vercel.app/aprende/clase-6/presentacion-1), se parte de dos archivos: arranque y pantalla. Primero se dibujan campos/botón; luego `Form` con `GlobalKey<FormState>` y `TextFormField.validator`; después se agrega visibilidad de contraseña con `setState`. El envío asíncrono simula espera, deshabilita el botón y muestra progreso; antes de actuar sobre la pantalla se verifica `mounted`. Los `TextEditingController` se liberan en `dispose`.

La Home se incorpora con `Navigator.pushReplacement` y `MaterialPageRoute`. Finalmente se extrae la sesión a `AuthProvider extends ChangeNotifier`, provisto sobre `MaterialApp` mediante `MultiProvider`: la Home escucha con `context.watch` y los callbacks llaman métodos con `context.read`. El ojo de la contraseña sigue siendo estado local. **Este login inicial es simulado; validar un formulario no autentica contra un servidor.** La autenticación real llega en clase 7.

Para el proyecto: conservar esa distinción entre estado visual local y estado compartido; no crear un provider por cada campo ni tratar una bandera local como sesión real. La mención comparativa de Riverpod no es la metodología elegida por el curso. [Fuente: presentación 1](https://udd-web-mobile.vercel.app/aprende/clase-6/presentacion-1).

### Galería: seis pasos de navegación y animación

La [presentación 2](https://udd-web-mobile.vercel.app/aprende/clase-6/presentacion-2) parte de datos `Mascota` locales en `data/`, una grilla `GridView.builder` y sus tarjetas. Se añade detalle que recibe `Mascota`; `Navigator.push` apila la ruta y `pop` permite regresar. Dos `Hero` comparten un identificador estable. Después, `AnimatedOpacity` muestra contenido y `AnimatedScale` cambia tamaño al actualizar valores; la tarjeta incorpora presión mediante `GestureDetector`. Se cierra con una función de ruta usando `PageRouteBuilder` y `FadeTransition`.

Para ChessErcise: reutilizar listado/detalle para jugadores de la API y ejercicios; usar Hero en un elemento identificable y `AnimatedContainer` o `AnimatedScale` como animación implícita. La transición personalizada es opcional, pues la navegación Material ya permite cubrir el mínimo.

### Ciclo de vida y ejercicios

La [presentación 3](https://udd-web-mobile.vercel.app/aprende/clase-6/presentacion-3) instrumenta un contador que registra creación, inicialización, dependencias, actualizaciones, reconstrucción y eliminación. Se prueba cambiando estado, título, tema y retirando el widget. Enseña a inicializar recursos fuera de `build` y liberarlos en `dispose`; `setState` desencadena reconstrucción, pero no es una fase autónoma del ciclo.

Los ejercicios de [login](https://udd-web-mobile.vercel.app/aprende/clase-6/ejercicios/login) agregan confirmación de contraseña, validación más precisa y comportamiento de controles/salida; los de [galería](https://udd-web-mobile.vercel.app/aprende/clase-6/ejercicios/galeria) amplían datos y animaciones. Se verificaron sus enunciados, sin ejecutarlos. El [índice de videos](https://udd-web-mobile.vercel.app/aprende/clase-6/presentacion-4) anuncia 14 videos; leer descripciones no equivale a haberlos reproducido.

### Qué no se verificó como desarrollado

Autenticación real en el ejemplo inicial, motor de ajedrez o juego en red. No se necesita añadir BLoC, navegación declarativa o inyección con un contenedor externo para repetir lo trabajado aquí.

## 4. Clase 7 · API y Supabase

### API de Naruto: siete pasos

La [presentación 1](https://udd-web-mobile.vercel.app/aprende/clase-7/presentacion-1) crea el proyecto con `dio` y `provider`. Primero pide nombres en `initState` y actualiza la vista con `setState`; ese paso inicial no resuelve todos los fallos de red. Después define `Ninja` y un constructor factory para convertir el JSON, incluyendo campos que pueden faltar o variar de forma. La petición se extrae a `data/naruto_service.dart`.

La siguiente versión usa un `Future` conservado y `FutureBuilder` para espera, error y datos. Más tarde se incorpora grilla, tarjeta propia con imagen, detalle por constructor y Hero. Finalmente `NinjaProvider` conserva el Future y la búsqueda: filtrar localmente no vuelve a solicitar la API por cada tecla o reconstrucción. La pantalla consume objetos, sin repartir claves JSON por los widgets.

Esto se puede trasladar a Lichess: servicio HTTP → modelo tipado → Future estable → lista y detalle. Agregar vacío, reintento y tolerancia a campos opcionales será parte de la implementación específica; no se supondrá que todo error ya queda resuelto por copiar el ejemplo. [Fuente: presentación 1](https://udd-web-mobile.vercel.app/aprende/clase-7/presentacion-1).

### Supabase: continuación en cinco pasos

La [presentación 2](https://udd-web-mobile.vercel.app/aprende/clase-7/presentacion-2) agrega `supabase_flutter`, inicialización antes de `runApp`, proyecto externo y clave pública. El `AuthProvider` realiza ingreso/registro/salida; un `AuthGate` usa `StreamBuilder` sobre cambios de autenticación y decide entre login y contenido, sin navegación manual al entrar.

Luego se define `favoritos` en SQL, con dueño `user_id` y RLS; un servicio hace consultas y un provider conserva ids favoritos, escucha cambios de sesión y cancela su suscripción. El ejemplo implementa alternancia optimista con reversión ante fallo, y una pantalla que cruza ids privados con datos públicos ya cargados. El playground de Supabase está simulado: esto no certifica una conexión real del estudiante.

Para ChessErcise: tabla propuesta de ejercicios propios, con servicios separados y limpieza de datos al cambiar usuario. Se prefiere confirmar operaciones CRUD antes de actualizar la lista visible, para empezar con menos complejidad. El SQL de favoritos revisado incluye `SELECT`, `INSERT` y `DELETE`; **no incluye política `UPDATE` ni formulario de edición**. No se presenta ese ejemplo como un CRUD completo. [Fuente: presentación 2](https://udd-web-mobile.vercel.app/aprende/clase-7/presentacion-2).

El [ejercicio de ninjas](https://udd-web-mobile.vercel.app/aprende/clase-7/ejercicios/ninjas) agrega contador visible, vacío de búsqueda, orden alfabético, total de jutsus y búsqueda por aldea. El [índice audiovisual](https://udd-web-mobile.vercel.app/aprende/clase-7/presentacion-3) anuncia 13 videos. No se ejecutaron ejercicios ni se verificaron todos los videos.

### Qué falta o es complementario

No se encontró en este material implementación de partida remota, conciliación de movimientos concurrentes, recuperación de partidas, selección de un motor de reglas ni una estrategia integral de pruebas de ajedrez. La edición CRUD y su política RLS deben enseñarse como una extensión concreta del ejemplo, aunque editar sí figure en el mínimo académico.

## 5. Criterios derivados para la arquitectura

| Decisión | Relación con las clases |
|---|---|
| `main.dart` breve; pantallas separadas; widgets con entradas y callbacks | Contador y refactor de clase 5 |
| `models/`, `data/`, `presentation/screens/` y `presentation/providers/` | Evolución real de los ejemplos de clases 6–7 |
| `setState` local y Provider compartido | Login de clase 6; búsqueda/favoritos de clase 7 |
| Navigator y constructor; AuthGate para acceso | Galería de clase 6 y autenticación de clase 7 |
| Dio, JSON tipado y Future conservado | App de Naruto de clase 7 |
| Supabase Auth y tabla por usuario con RLS | Continuación de Naruto; cubrir edición por separado |
| Desarrollo gradual con ejecución y explicación por paso | Metodología recurrente de contador, login, galería y API |

Los commits por paso del docente son una referencia de aprendizaje. **No autorizan commits automáticos aquí**: la solicitud del equipo exige autorización expresa para operaciones Git de escritura.

## 6. Contenido complementario propuesto y motivo

| Contenido | Por qué hace falta | Cuándo explicarlo |
|---|---|---|
| Motor de reglas de ajedrez detrás de un servicio pequeño | Evitar reimplementar legalidad y finales dentro de widgets | B03; condicionado a plataforma y aprobación de dependencia |
| Captura como evento con identificador y dueño | Traducir una pérdida de pieza a un desafío exactamente una vez | B11 |
| Edición CRUD y RLS de actualización | Completar un requisito que favoritos no demuestra íntegramente | B05–B06; [referencia Supabase](https://supabase.com/docs/guides/database/postgres/row-level-security) |
| Pruebas unitarias y de widgets aplicadas a casos del proyecto | Verificar reglas, atribución de desafíos y formularios; la referencia de comandos no desarrolla esta estrategia | B02–B14, según el cambio |
| Configuración de Supabase por parámetros de compilación | Hacer reproducible la configuración sin repartir valores por widgets | B04; explicar que una clave pública de cliente no sustituye RLS |

No se propone añadir patrones avanzados por defecto. Las decisiones de modalidad, plataforma y producto siguen pendientes del equipo y están enumeradas en [02_requisitos_proyecto.md](02_requisitos_proyecto.md).
