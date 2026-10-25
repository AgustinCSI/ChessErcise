# 00 · Auditoría inicial de ChessErcise

> Registro histórico del 23-10-2026. Actualización del 24-10: ahora se aportaron una propuesta DOCX y mockups PDF; D01 es LAN con dos Android y D02 es Android únicamente. Consultar la [revisión de fuentes](05_revision_propuesta_y_mockups.md), los requisitos y el plan vigentes. La ausencia de propuesta descrita abajo corresponde al inventario inicial, no al estado actual. Por petición del equipo se agregó `/docs/bloques/` al ignore; los reportes internos no se subirán a Git. El informe histórico no autoriza implementar el plan anterior.

Fecha: 23 de octubre de 2026, America/Santiago. Estado: diagnóstico terminado; planificación pendiente de revisión del equipo.

## 1. Resumen y alcance

El repositorio está en la etapa de definición de la idea. **Todavía no existe una aplicación Flutter**: no hay `pubspec.yaml`, archivos Dart, `lib/`, plataformas, navegación, estado ni pruebas. Esta ausencia impide ejecutar o analizar una app, pero no demuestra un defecto de código: el código aún no fue creado.

Se inspeccionaron todos los archivos de trabajo, incluidos los ocultos fuera de `.git`, los cinco archivos versionados, las referencias e historia Git disponibles y el material público de las clases 5–7. No se encontraron apuntes, ejercicios, propuesta tecnológica, rúbrica ni mockups en el repositorio. No se recorrieron los objetos internos de `.git` ni dependencias externas. No se modificó código, configuración, recursos o historial Git.

Convenciones de esta documentación:

- **Verificado:** respaldado por un archivo, salida de comando o fuente consultada.
- **Propuesto:** decisión recomendada que todavía debe aprobarse.
- **Pendiente:** información o validación que no se ha obtenido.

## 2. Árbol existente antes de esta auditoría

```text
ChessErcise/
├── .git/                              # Metadatos; no forma parte de la app
├── .gitignore
├── LICENSE
├── README.md
└── image/
    └── README/
        ├── ChessErcise_logo.png
        └── informatica_white_bg.jpg
```

La carpeta `docs/` se agrega exclusivamente como resultado documental de esta intervención. El árbol anterior no representa la arquitectura futura.

## 3. Archivos y evidencia

| Archivo | Responsabilidad actual | Evidencia y observación |
|---|---|---|
| `README.md` | Nombre, asignatura, integrantes y descripción de la idea | Líneas 8–14: proyecto 2, Agustin Castro y Juan Pablo Molina; ajedrez con amigos y ejercicio al perder piezas |
| `.gitignore` | Exclusión de archivos generados y del entorno | Incluye reglas de un repositorio del SDK Flutter, además de reglas de aplicaciones; revisar antes de inicializar la app |
| `LICENSE` | Texto GNU GPL, versión 3 | Se conserva íntegro; esta auditoría no cambia su elección ni hace una revisión jurídica |
| `image/README/ChessErcise_logo.png` | Imagen de identidad referenciada por el README | Archivo presente, 55.533 bytes; no está declarado como asset de Flutter |
| `image/README/informatica_white_bg.jpg` | Imagen institucional del README | Archivo presente, 17.413 bytes; no está declarado como asset de Flutter |

El texto alternativo de la segunda imagen del README dice `Logo Drinlimit`, aunque su ruta apunta a ChessErcise (`README.md:5`). Es una corrección editorial opcional, no un fallo de la aplicación.

## 4. Funcionalidades existentes y pendientes

**Implementado:** únicamente la presentación documental y gráfica del proyecto en GitHub. No hay funcionalidades de aplicación verificables.

**Pendiente según el README:** jugar ajedrez con amigos y generar desafíos o penalizaciones de ejercicio al perder piezas. No se especifican modalidad local/remota, reglas de penalización, persistencia, pantallas, plataforma o paquetes.

**Pendiente según las clases consultadas:** login/registro/salida con Supabase; datos reales de una API deportiva con `FutureBuilder`; listado y detalle con dato por constructor; `Hero` y una animación implícita; CRUD privado en una tabla con RLS; formulario validado; `ChangeNotifier` compartido con Provider; widgets propios; aportes de todos en GitHub. La clase 5 también solicita propuesta y mockup de al menos cinco pantallas. Fuentes y límites: [análisis académico](01_analisis_unidad_2.md).

No se deben convertir estas ausencias en errores ficticios del analizador o de pruebas. La trazabilidad de requisitos está en [02_requisitos_proyecto.md](02_requisitos_proyecto.md).

## 5. Estado Git comprobado

| Elemento | Resultado observado |
|---|---|
| Rama activa | `main` |
| HEAD | `34f3f6da0dafc81d2bd3bc5d763c2ae836ec475b` |
| Referencias locales disponibles | `main`, `origin/main`, `origin/HEAD`; apuntan al mismo commit |
| Remoto configurado | `https://github.com/AgustinCSI/ChessErcise.git` |
| Commits alcanzables en las referencias disponibles | 5, todos del 13 de octubre de 2026 |
| Árbol de trabajo inicial | Limpio: sin modificaciones, archivos sin seguimiento ni archivos ignorados reportados |
| Autores de la historia local | Agustin; Juan Pablo Molina y el alias `jp-mp` |

La historia agrega README, imágenes, licencia e ignore. No contiene una implementación anterior de Flutter en las referencias disponibles. Los nombres de autores respaldan actividad de ambos integrantes, pero no verifican contribuciones funcionales ni identidades de cuentas del curso.

**Límite:** no se hizo `fetch`, `pull` ni consulta del repositorio remoto. La igualdad con `origin/main` se refiere a la referencia remota almacenada localmente; no garantiza que el servidor siga sin novedades. Esta intervención no crea commits ni cambia de rama.

## 6. Hallazgos clasificados

“Crítico” significa impedimento para ejecutar o entregar; “importante”, decisión o riesgo que debe resolverse durante el desarrollo; “opcional”, mejora que no bloquea el MVP.

| ID | Nivel | Hallazgo verificado | Impacto y recomendación |
|---|---|---|---|
| H01 | Crítico para ejecución | No existen `pubspec.yaml`, `lib/main.dart`, plataformas ni pruebas | No se puede correr, analizar o compilar una app. Inicializar Flutter solo después de aprobar el plan, en B02 |
| H02 | Importante | README de dos líneas funcionales, sin propuesta, mockup, reglas ni modalidad | Confirmar alcance en B01; no asumir que “amigos” obliga a multijugador remoto |
| H03 | Importante | Ningún requisito técnico del mínimo académico está implementado | Cubrirlos explícitamente en el plan; una partida local por sí sola no satisface la unidad |
| H04 | Importante | `.gitignore:3` contiene `*.lock` | `git check-ignore` confirma que excluiría `pubspec.lock`; revisar en B02 para conservar la resolución reproducible de la aplicación |
| H05 | Importante | `.gitignore:50,53,54` excluye JAR y scripts del wrapper de Gradle; también contiene patrones bajo `/packages/`, `/dev/` y `/bin/` específicos del SDK | Los patrones concretos pueden impedir versionar archivos del wrapper al generar Android. No hay wrapper roto actualmente: aún no existe Android. Revisar reglas contra los archivos realmente generados en B02 |
| H06 | Importante | No hay evidencia de diagnóstico del entorno ni dispositivo disponible | Hay comandos de SDK en PATH y metadatos de versión, pero no se ha probado Android, Java, emulador o compilación. Verificar en B02 |
| H07 | Opcional | `README.md:5` conserva un texto alternativo ajeno al nombre | Corregir durante la documentación de entrega, sin alterar recursos originales ahora |
| H08 | Opcional | README no explica instalación o ejecución | Completar cuando haya instrucciones ejecutables comprobadas; no documentar comandos como si hoy funcionaran |

## 7. Entorno, dependencias y riesgos

### Hechos del entorno

`Get-Command flutter,dart` resuelve ambos a `C:/Users/PC/AppData/Local/Programs/flutter/bin/`. La lectura de `bin/cache/flutter.version.json` indica Flutter **3.44.8**, canal stable, y Dart **3.12.2**. Esto es evidencia de los metadatos del SDK instalado, **no** el resultado de ejecutar `flutter --version` ni una validación completa de la instalación.

No hay dependencias declaradas, lockfile, manifiestos Android, configuración Supabase, variables de proyecto, assets Flutter, configuración de lints ni CI. No se infiere que Supabase no exista en una cuenta externa: simplemente no está documentado aquí.

### Riesgos de las propuestas, todavía no fallos existentes

1. Implementar todas las reglas del ajedrez a mano excedería razonablemente el foco de widgets/estado/API. Se propone encapsular un motor de reglas. Su selección debe validar plataforma y SDK; [dartchess](https://pub.dev/packages/dartchess) declara expresamente que no admite web.
2. El juego remoto requiere sincronización y resolución de concurrencia que no se verificaron en estas clases. La alternativa local requiere aprobación del equipo; si se exige remoto, hay que replanificar antes del tablero.
3. API y Supabase dependen de conectividad, disponibilidad y configuración. Haber recibido HTTP 200 desde Python no demuestra integración en Flutter ni permisos Android.
4. La política de actualización debe planificarse: el ejemplo de favoritos de clase 7 muestra insertar, leer y borrar; no implementa editar. El CRUD académico requiere las cuatro operaciones.
5. El calendario publicado sitúa la evaluación el 26 o 28 de octubre de 2026, según sección. Desde el día 23 queda poco margen; confirmar sección/plazo y evitar prometer una entrega sin estimar disponibilidad del equipo. [Clase 5, presentación 1](https://udd-web-mobile.vercel.app/aprende/clase-5/presentacion-1).

## 8. Elementos que se conservan

Nombre e idea de ChessErcise, autores, README, licencia, imágenes originales, historial y rama. No se moverán las imágenes del README para reutilizarlas: si se aprueba su uso en la app, se puede agregar una copia como asset y registrar su procedencia. La estructura existente no obliga a una arquitectura Flutter determinada.

## 9. Verificaciones realizadas y no realizadas

| Verificación | Resultado real |
|---|---|
| `git status --short --branch` y `git status --porcelain=v1 --untracked-files=all` | Rama identificada; estado inicial limpio |
| `git status --short --ignored` | Sin archivos ignorados reportados al inicio |
| `git ls-files` y `git ls-tree -r --name-only HEAD` | Cinco archivos versionados |
| `git branch -avv`, `git log --all --date=iso-strict --format='%h %ad %s' --stat`, `git rev-list --all --count` | Referencias, cambios históricos y cinco commits inspeccionados |
| `rg --files --hidden -g '!.git/**'` y listado de carpetas | Inventario completo fuera de metadatos; no hay código o material académico local |
| Búsqueda de `AGENTS.md` en el proyecto y sus ancestros | No se encontraron instrucciones adicionales |
| `git check-ignore -v --no-index pubspec.lock android/gradlew android/gradle/wrapper/gradle-wrapper.jar` | Los tres nombres quedarían ignorados; se trata de rutas hipotéticas, no de archivos existentes |
| Lectura HTTP de clases, asset público del sitio, metadatos pub.dev y endpoint de Lichess | Fuentes consultadas; detalles en documentos 01–03 |
| `flutter doctor`, `flutter --version`, `flutter analyze`, `flutter test`, `flutter run`, builds | **No ejecutados**. No se inicializó Flutter ni se alteraron cachés del SDK |

Se corrigió la codificación de salida a UTF-8 al leer las fuentes: la primera extracción extensa produjo `UnicodeEncodeError` en la consola Windows. Se repitió la lectura sin modificar las fuentes. El acceso inicial mediante la herramienta web no pudo extraer las clases; HTTP directo permitió leer su contenido público. No se reporta una caída del sitio por esa limitación de extracción.

### Control de la entrega documental

Se revisaron los siete Markdown: decodificación UTF-8, enlaces relativos existentes, cierres de bloques de código, secuencia B01–B11 y los diez campos exigidos de cada bloque. La primera comprobación de campos produjo falsos faltantes por la codificación de la entrada de Python desde PowerShell; se corrigió la lectura/comparación y se repitió. Este control verifica estructura documental, no funcionalidad de la app.

El estado final contiene solo siete archivos nuevos bajo `docs/`, sin cambios en los cinco archivos originales ni archivos preparados en el índice. `git diff --check` no reportó problemas en cambios versionados; los nuevos Markdown se comprobaron por separado porque aún no están bajo seguimiento. HEAD conserva el mismo hash. No se hicieron commits, push, cambios de rama, instalaciones ni migraciones.

## 10. Recomendación de avance

Revisar [requisitos](02_requisitos_proyecto.md), [arquitectura](03_arquitectura_propuesta.md) y [bloques](04_plan_de_trabajo.md). Resolver las decisiones D01–D06 allí registradas. Luego autorizar **únicamente B01**. La auditoría no inicializa la aplicación ni inicia un bloque de desarrollo.
