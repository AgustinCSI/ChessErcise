# 04 · Plan de trabajo por partes revisables

Revisión: 24 de octubre de 2026. **Este plan reemplaza la secuencia anterior de once bloques.** No había bloques de desarrollo implementados, por lo que la nueva numeración no renombra trabajo terminado.

## 1. Alcance y orden

Se conservan todos los modos de la propuesta: LAN, online y puzzle. La priorización para el lunes 26 sigue pendiente de confirmación; online no se retira automáticamente. Android es la única plataforma. La forma de programación de clases 5–7 es obligatoria, según [01](01_analisis_unidad_2.md).

Recomendación: preparación Supabase ahora → base Android → compatibilidad de tablero/motor → Auth → CRUD → puzzle/API → LAN/transporte → partida → desafíos → online → entrega. La propuesta de preparar primero LAN+puzzle y dejar online después necesita aprobación expresa.

No se inicia código por aprobar una arquitectura o por cambiar el ignore. Esta intervención concilia documentación y prepara acceso al panel; no ejecuta los bloques de aplicación.

| Bloque | Resultado | Mínimo académico / producto | Estado |
|---|---|---|---|
| B01 | Cerrar alcance y preparar Supabase | Núcleo académico/producto o preparación | Pendiente |
| B02 | Base Flutter Android | Núcleo académico/producto o preparación | Pendiente |
| B03 | Compatibilidad, motor y tablero | Núcleo académico/producto o preparación | Pendiente |
| B04 | Acceso real y menú de modos | Núcleo académico/producto o preparación | Pendiente |
| B05 | Datos privados de ejercicios | Núcleo académico/producto o preparación | Pendiente |
| B06 | Catálogo y formulario de ejercicios | Núcleo académico/producto o preparación | Pendiente |
| B07 | API del puzzle, tarjeta y detalle | Núcleo académico/producto o preparación | Pendiente |
| B08 | Resolver puzzle y confirmar ejercicio | Núcleo académico/producto o preparación | Pendiente |
| B09 | Transporte LAN y sala host/cliente | Núcleo académico/producto o preparación | Pendiente |
| B10 | Partida de ajedrez sincronizada | Núcleo académico/producto o preparación | Pendiente |
| B11 | Elegir castigo y confirmar Listo en LAN | Núcleo académico/producto o preparación | Pendiente |
| B12 | Autorización y acceso Lichess online | Online explícito de la propuesta; prioridad pendiente | Pendiente |
| B13 | Partida online y ejercicios informativos | Online explícito de la propuesta; prioridad pendiente | Pendiente |
| B14 | Verificación y entrega del lunes | Núcleo académico/producto o preparación | Pendiente |

## 2. Método por parte y por commit

Cada bloque tiene partes pequeñas `Bxx.01`, `Bxx.02`, etc. Se entrega **una parte funcional y verificable a la vez**, con su explicación y sugerencia de commit, y se espera la revisión del usuario antes de continuar. No acumular todo el bloque antes de permitirle entenderlo y commitearlo.

El reporte se guarda en `docs/bloques/Bxx/Bxx_01_nombre.md`, copiando la plantilla interna `docs/bloques/_plantilla.md`. Esa carpeta está ignorada y **no se sube a Git**. Los nombres de funciones y rutas reales se registran al implementarlos; las partes de este plan no son código ya creado.

Para cada parte:
1. Recordar objetivo, prerrequisitos y relación con el ejemplo del profesor.
2. Explicar comandos que modificarán el proyecto antes de ejecutarlos.
3. Implementar solo esa parte, leer el resultado y corregir problemas derivados.
4. Explicar cada función principal: archivo/líneas, entradas, salida, callbacks, validación, cambio de estado y relación con otras funciones.
5. Ejecutar verificación pertinente y declarar qué no se comprobó.
6. Entregar lista exacta de archivos versionables, resumen del diff y mensaje de commit sugerido; **el usuario hace stage/commit**.
7. Registrar estado técnico y aprobación por separado. Esperar confirmación antes de la parte siguiente y antes de cambiar de bloque.

No ejecutar `git add`, commit, push, reset o cambios de rama. Muchos commits pequeños son deliberados: cada uno debe representar un cambio comprensible, no una función rota separada de los archivos que necesita para compilar.

## 3. Fichas de los bloques

### B01 · Cerrar alcance y preparar Supabase

| Campo | Contenido |
|---|---|
| Identificador | B01 |
| Nombre | Cerrar alcance y preparar Supabase |
| Objetivo | Consolidar las aclaraciones y disponer del proyecto gratuito real sin empezar funcionalidades. |
| Requisitos previos | Revisión de los documentos 02–06; aprobación para cerrar definición. |
| Archivos involucrados | Documentos 02–06, bitácora; panel Supabase del proyecto ChessErcise, sin tablas todavía. |
| Conceptos Flutter | Pantallas/flujo de clase 5; relación con Auth de clase 7. |
| Pasos | 1. Adoptar propuesta y PDF existentes. 2. Resolver prioridad online y rechazo. 3. Completar proyecto gratuito con la contraseña introducida por el usuario. 4. Identificar proyecto y acceso; GitHub sin conectar. 5. Cerrar decisiones antes de B02. |
| Pruebas | Recorrer mockups y mínimos; verificar proyecto real en panel; diferenciar organización de proyecto; no afirmar que existe una conexión Flutter. |
| Criterio de aceptación | Alcance del lunes acordado y proyecto identificado. Si falta proyecto o decisión, registrar exactamente lo pendiente; no crear otro por prueba. |
| Estado | Pendiente |

| Parte | Foco y mensaje de commit sugerido para el usuario |
|---|---|
| B01.01 · alcance | `docs: conciliar propuesta y mockups con decisiones del equipo` |
| B01.02 · preparacion_supabase | `docs: registrar preparación del proyecto Supabase` |

### B02 · Base Flutter Android

| Campo | Contenido |
|---|---|
| Identificador | B02 |
| Nombre | Base Flutter Android |
| Objetivo | Crear y ejecutar una base mínima preservando los archivos del repositorio. |
| Requisitos previos | B01 y aprobación de avance; objetivo Android confirmado. |
| Archivos involucrados | pubspec.yaml/lock, android/, analysis_options.yaml, lib/main.dart, lib/app.dart, prueba de arranque y ajuste acotado de .gitignore. |
| Conceptos Flutter | flutter create, runApp, MaterialApp, Scaffold y análisis de clase 5. |
| Pasos | 1. Explicar diagnóstico antes de ejecutarlo. 2. Verificar SDK/dispositivos. 3. Generar solo Android sin sobrescritura forzada. 4. Revisar diff y conservar README/recursos. 5. Revisar lockfile/wrapper ignorados. 6. Ejecutar base. |
| Pruebas | flutter doctor -v, flutter devices, analyze, prueba de arranque y run en Android; registrar cada resultado real. |
| Criterio de aceptación | App base arranca en objetivo, archivos previos conservados y resolución de dependencias reproducible. |
| Estado | Pendiente |

| Parte | Foco y mensaje de commit sugerido para el usuario |
|---|---|
| B02.01 · estructura | `chore(flutter): inicializar proyecto Android` |
| B02.02 · arranque | `feat(app): separar raíz y pantalla inicial` |
| B02.03 · ignore | `chore(git): ajustar archivos versionables de Flutter Android` |

### B03 · Compatibilidad, motor y tablero

| Campo | Contenido |
|---|---|
| Identificador | B03 |
| Nombre | Compatibilidad, motor y tablero |
| Objetivo | Verificar temprano la pareja dartchess/chessground y encapsular sus contratos. |
| Requisitos previos | B02 completo y aprobación de avance. |
| Archivos involucrados | pubspec/lock, logic/ajedrez_service.dart, presentation/widgets/tablero_widget.dart y pruebas de adaptador. |
| Conceptos Flutter | Clases y modelos de clase 5, callbacks y ciclo de vida de clase 6; paquetes de ajedrez complementarios. |
| Pasos | 1. Resolver versiones compatibles sin actualizar SDK por defecto. 2. Crear adaptador de reglas. 3. Integrar widget de tablero y liberar controlador. 4. Verificar legales/promoción/final. 5. Dejar una prueba aislada del conjunto antes de red. |
| Pruebas | Resolución/build Android; captura normal/en passant; enroque y promoción; movimiento inválido sin mutación; mate/ahogado; entrada por toque y orientación. |
| Criterio de aceptación | La integración real compila y el adaptador devuelve eventos correctos. Metadata compatible sola no basta; no reescribir tablero nativo si el paquete funciona. |
| Estado | Pendiente |

| Parte | Foco y mensaje de commit sugerido para el usuario |
|---|---|
| B03.01 · dependencias | `chore(chess): integrar versiones compatibles del tablero y motor` |
| B03.02 · reglas | `feat(chess): encapsular reglas y capturas` |
| B03.03 · tablero | `feat(board): representar posición con chessground` |

### B04 · Acceso real y menú de modos

| Campo | Contenido |
|---|---|
| Identificador | B04 |
| Nombre | Acceso real y menú de modos |
| Objetivo | Implementar registro/ingreso/salida con Supabase y navegación fiel al diseño. |
| Requisitos previos | B03 completo, proyecto Supabase creado, aprobación de avance. |
| Archivos involucrados | config/app_config.dart, main/app, providers/auth_provider.dart, screens/auth/ y home/, pubspec/lock y pruebas pertinentes. |
| Conceptos Flutter | Form/validator, controladores/dispose, setState del ojo y Provider de clase 6; AuthGate clase 7. |
| Pasos | 1. Agregar provider y supabase_flutter con explicación. 2. Inicializar proyecto correcto. 3. Crear formulario/s y confirmación de correo. 4. Conectar acciones Auth reales. 5. Crear menú y ámbito privado. 6. Limpiar rutas al salir. |
| Pruebas | Inválidos y doble envío; fallos de red; registro/confirmación/ingreso/salida reales; restauración y Atrás sin mostrar sesión anterior. |
| Criterio de aceptación | Las tres acciones Auth funcionan con el proyecto real y la UI se recupera de errores. No modificar confirmación de correo por comodidad sin acordarlo. |
| Estado | Pendiente |

| Parte | Foco y mensaje de commit sugerido para el usuario |
|---|---|
| B04.01 · configuracion | `feat(auth): inicializar Supabase en ChessErcise` |
| B04.02 · formulario | `feat(auth): validar acceso y registro` |
| B04.03 · sesion | `feat(auth): compartir sesión y proteger navegación` |

### B05 · Datos privados de ejercicios

| Campo | Contenido |
|---|---|
| Identificador | B05 |
| Nombre | Datos privados de ejercicios |
| Objetivo | Preparar tabla y servicio CRUD con RLS completo. |
| Requisitos previos | B04 completo y aprobación de avance; acordar categoría de valor. |
| Archivos involucrados | models/ejercicio.dart, data/ejercicios_service.dart, supabase/ejercicios.sql, pruebas de conversión/aislamiento. |
| Conceptos Flutter | Modelo/servicio/SQL RLS de clase 7; UPDATE como extensión explicada. |
| Pasos | 1. Definir campos y reglas. 2. Preparar SQL revisable de tabla, permisos y cuatro políticas. 3. Obtener autorización específica antes de ejecutarlo. 4. Ejecutar en el proyecto identificado. 5. Implementar servicio y probar A/B. |
| Pruebas | Crear/leer/editar/borrar propias filas; denegar ajenas y sin sesión; INSERT/UPDATE no asignan o transfieren dueño; restricciones de campos en servidor. |
| Criterio de aceptación | Servicio y cuatro operaciones reales comprobados; SQL solo escrito no completa el bloque. |
| Estado | Pendiente |

| Parte | Foco y mensaje de commit sugerido para el usuario |
|---|---|
| B05.01 · modelo | `feat(exercises): modelar ejercicios y valor de pieza` |
| B05.02 · esquema | `feat(db): definir ejercicios con permisos y RLS` |
| B05.03 · servicio | `feat(exercises): implementar servicio CRUD privado` |

### B06 · Catálogo y formulario de ejercicios

| Campo | Contenido |
|---|---|
| Identificador | B06 |
| Nombre | Catálogo y formulario de ejercicios |
| Objetivo | Administrar ejercicios elegibles para los desafíos y cubrir formulario CRUD académico. |
| Requisitos previos | B05 completo y aprobación de avance. |
| Archivos involucrados | providers/ejercicios_provider.dart, screens/ejercicios/ y widgets propios; pruebas de formulario. |
| Conceptos Flutter | Form, TextFormField/validator y estados clase 6; datos privados/Provider clase 7. |
| Pasos | 1. Listar con carga/vacío/error. 2. Reutilizar formulario en crear/editar. 3. Validar instrucciones, categoría y repeticiones. 4. Borrar con confirmación de UI. 5. Actualizar tras éxito remoto y limpiar al cambiar cuenta. |
| Pruebas | Crear/editar/borrar y recargar; cancelar no guarda; inválidos no envían; error conserva datos; cuenta B no conserva lista/respuestas de A. |
| Criterio de aceptación | CRUD visible y persistente; catálogo vacío comprensible; no se fingen filas remotas. |
| Estado | Pendiente |

| Parte | Foco y mensaje de commit sugerido para el usuario |
|---|---|
| B06.01 · lista | `feat(exercises): listar catálogo privado con estados` |
| B06.02 · formulario | `feat(exercises): crear y editar con validación` |
| B06.03 · eliminacion | `feat(exercises): eliminar y refrescar catálogo` |

### B07 · API del puzzle, tarjeta y detalle

| Campo | Contenido |
|---|---|
| Identificador | B07 |
| Nombre | API del puzzle, tarjeta y detalle |
| Objetivo | Cubrir API deportiva y navegación/animaciones con una función explícita del producto. |
| Requisitos previos | B06 completo y aprobación de avance. |
| Archivos involucrados | models/puzzle_diario.dart, data/lichess_puzzles_service.dart, providers/puzzles_provider.dart, screens/puzzles/; Dio en pubspec/lock. |
| Conceptos Flutter | Dio/modelo/FutureBuilder de clase 7; constructor/Hero/animación implícita de clase 6. |
| Pasos | 1. Consultar endpoint diario real. 2. Convertir JSON tipado. 3. Conservar Future fuera de build. 4. Mostrar tarjeta y estados. 5. Abrir detalle pasando el objeto. 6. Incorporar Hero e implícita visibles. |
| Pruebas | Respuesta real y formato inesperado; carga/error/vacío/reintento; reconstrucción no duplica solicitudes; detalle recibe objeto y animaciones correctas. |
| Criterio de aceptación | API real visible mediante FutureBuilder y navegación/animaciones académicas cubiertas. Resolver puzzle pertenece a B08. |
| Estado | Pendiente |

| Parte | Foco y mensaje de commit sugerido para el usuario |
|---|---|
| B07.01 · modelo_api | `feat(puzzles): consumir puzzle diario de Lichess` |
| B07.02 · estados | `feat(puzzles): mostrar carga error y datos` |
| B07.03 · detalle | `feat(puzzles): navegar al detalle con Hero` |

### B08 · Resolver puzzle y confirmar ejercicio

| Campo | Contenido |
|---|---|
| Identificador | B08 |
| Nombre | Resolver puzzle y confirmar ejercicio |
| Objetivo | Convertir PGN/inicio/solución en una experiencia jugable y penalización por fallo. |
| Requisitos previos | B07 y B03 completos, aprobación de avance; regla de ejercicio al fallar acordada. |
| Archivos involucrados | logic/puzzle_service.dart, estado de puzzle/provider, pantalla de resolución y panel Listo; pruebas con puzzle conocido. |
| Conceptos Flutter | Estado, callbacks y composición del curso; secuencia UCI/PGN como complemento. |
| Pasos | 1. Reconstruir posición y turno exactos. 2. Probar secuencia conocida. 3. Comparar jugada del usuario con solución y representar respuesta. 4. Mostrar acierto/fallo/final. 5. Asociar ejercicio al fallo y permitir Listo. 6. Reiniciar sin conservar eventos anteriores. |
| Pruebas | Posición/primer turno correctos; legal pero incorrecta detectada; secuencia acertada; fallo único; Listo no duplica; reinicio; no filtrar solución al usuario. |
| Criterio de aceptación | Puzzle diario se puede resolver y fallar de forma verificable; ejercicio se confirma manualmente sin sensores. |
| Estado | Pendiente |

| Parte | Foco y mensaje de commit sugerido para el usuario |
|---|---|
| B08.01 · posicion | `feat(puzzles): reconstruir posición inicial del reto` |
| B08.02 · solucion | `feat(puzzles): validar secuencia y resultado` |
| B08.03 · ejercicio | `feat(puzzles): resolver penalización con Listo` |

### B09 · Transporte LAN y sala host/cliente

| Campo | Contenido |
|---|---|
| Identificador | B09 |
| Nombre | Transporte LAN y sala host/cliente |
| Objetivo | Conectar dos Android de la misma Wi-Fi antes de enviar jugadas. |
| Requisitos previos | B08 completo por orden de trabajo, aprobación de avance y dos Android/red disponibles. |
| Archivos involucrados | data/lan_host_service.dart, lan_client_service.dart, models/mensaje_lan.dart, screens/lan/, permisos Android necesarios y pubspec/lock. |
| Conceptos Flutter | Future/Stream/listen/dispose de clases 5/6; servidor WebSocket complementario. |
| Pasos | 1. Explicar host frente a cliente. 2. Abrir servidor del SDK. 3. Mostrar dirección/puerto y conectar invitado con web_socket_channel. 4. Definir versión de protocolo y participantes. 5. Intercambiar mensaje/estado simple. 6. Cerrar recursos y mostrar desconexión. |
| Pruebas | Dos Android reales; IP/puerto incorrectos, host ausente, invitado extra, mensaje inválido y cierre de app; comprobar permisos del target y aislamiento Wi-Fi. |
| Criterio de aceptación | Envío bidireccional real verificado en la red. No declarar LAN lista por una prueba local en PC o por instalar el paquete. |
| Estado | Pendiente |

| Parte | Foco y mensaje de commit sugerido para el usuario |
|---|---|
| B09.01 · host | `feat(lan): abrir sala WebSocket en Android host` |
| B09.02 · cliente | `feat(lan): conectar invitado por IP y puerto` |
| B09.03 · cierre | `feat(lan): gestionar errores y liberar conexiones` |

### B10 · Partida de ajedrez sincronizada

| Campo | Contenido |
|---|---|
| Identificador | B10 |
| Nombre | Partida de ajedrez sincronizada |
| Objetivo | Jugar en dos dispositivos con el host como autoridad única. |
| Requisitos previos | B09 completo, B03 disponible y aprobación de avance. |
| Archivos involucrados | providers/partida_lan_provider.dart, configuración/estado de sala, screens/partida/, adaptadores LAN y pruebas de comandos. |
| Conceptos Flutter | Provider compartido, modelo, callbacks y composición; protocolo con revisión como complemento. |
| Pasos | 1. Asignar colores/participantes. 2. Cliente envía intenciones con id/revisión. 3. Host valida acciones locales y remotas por la misma ruta. 4. Confirmar posición/turno a ambos. 5. Aplicar promoción/especiales/final. 6. Bloquear acciones ante pérdida de conexión. |
| Pruebas | Misma posición tras cada jugada; color/turno indebidos rechazados; mensaje repetido/atrasado no duplica; en passant/promoción; desconexión detiene confirmaciones. |
| Criterio de aceptación | Partida válida en dos Android, sin que el cliente imponga FEN final ni UI duplique reglas. Reloj/rendición/tablas/historial visual se asignan explícitamente según alcance acordado. |
| Estado | Pendiente |

| Parte | Foco y mensaje de commit sugerido para el usuario |
|---|---|
| B10.01 · protocolo | `feat(lan): validar comandos y revisiones de partida` |
| B10.02 · sincronizacion | `feat(lan): sincronizar jugadas confirmadas` |
| B10.03 · final | `feat(game): representar turnos y finales en ambos jugadores` |

### B11 · Elegir castigo y confirmar Listo en LAN

| Campo | Contenido |
|---|---|
| Identificador | B11 |
| Nombre | Elegir castigo y confirmar Listo en LAN |
| Objetivo | Implementar el núcleo distintivo según propuesta y mockups. |
| Requisitos previos | B10 completo, catálogo B06 y decisiones de rechazo/valor cerradas; aprobación de avance. |
| Archivos involucrados | models/captura.dart y desafio.dart, logic/desafios_service.dart, PartidaLanProvider, selección/aceptación/Listo/resultado en pantallas. |
| Conceptos Flutter | Modelos, estado y widgets del curso; fases/idempotencia de eventos como complemento. |
| Pasos | 1. Detectar captura confirmada una sola vez. 2. Habilitar elección solo al rival que capturó con ejercicios elegibles. 3. Comunicar elección al afectado. 4. Registrar aceptar/rechazar según decisión. 5. Aceptado: realizar→Listo; host valida y reanuda/finaliza. 6. Mostrar resumen consistente. |
| Pruebas | Elige jugador correcto; afectado correcto incluido en passant; elección/repetición inválidas rechazadas; una captura/un desafío; Listo solo del afectado y una vez; mate con última captura; sincronización de ambas pantallas. |
| Criterio de aceptación | Flujo selección→aceptación→Listo→continuación/final completo en LAN, sin comprobación física avanzada. Rechazo no se inventa ni se elimina sin acuerdo. |
| Estado | Pendiente |

| Parte | Foco y mensaje de commit sugerido para el usuario |
|---|---|
| B11.01 · captura | `feat(challenges): crear desafío desde captura confirmada` |
| B11.02 · eleccion | `feat(challenges): permitir elección al oponente` |
| B11.03 · listo | `feat(challenges): sincronizar confirmación y reanudación` |

### B12 · Autorización y acceso Lichess online

| Campo | Contenido |
|---|---|
| Identificador | B12 |
| Nombre | Autorización y acceso Lichess online |
| Objetivo | Conectar cuentas Lichess y obtener una partida online real. |
| Requisitos previos | B11 completo, aprobación de avance, decisión explícita de prioridad online, dos cuentas Lichess y política de integración verificada. |
| Archivos involucrados | servicio de autorización/acceso Lichess, screens/online/, configuración Android de retorno si corresponde y dependencias justificadas. |
| Conceptos Flutter | HTTP/Future/Stream y separación de datos del curso; autorización Lichess como complemento. |
| Pasos | 1. Verificar flujo Android de autorización y permisos mínimos. 2. Preparar integración concreta revisable. 3. Autorizar con cuentas de jugadores en Lichess. 4. Crear/aceptar desafío según API. 5. Obtener id de partida y gestionar cancelación/rechazo. 6. Separar sesión Lichess de Supabase. |
| Pruebas | Con dos cuentas reales: autorización, retorno y asociación de partida; rechazo/cancelación/expiración; no exponer token ni contraseña en Git/reportes. |
| Criterio de aceptación | Partida online real accesible con identidades correctas. No sustituirlo por abrir una web ni usar token compartido y declararlo integrado. |
| Estado | Pendiente |

| Parte | Foco y mensaje de commit sugerido para el usuario |
|---|---|
| B12.01 · autorizacion | `feat(online): autorizar cuenta Lichess en Android` |
| B12.02 · desafio | `feat(online): crear y aceptar partida Lichess` |

### B13 · Partida online y ejercicios informativos

| Campo | Contenido |
|---|---|
| Identificador | B13 |
| Nombre | Partida online y ejercicios informativos |
| Objetivo | Jugar mediante Board API conservando a Lichess como autoridad. |
| Requisitos previos | B12 completo y aprobación de avance. |
| Archivos involucrados | data/lichess_online_service.dart, providers/partida_online_provider.dart, tablero/pantalla online y estado/errores. |
| Conceptos Flutter | Stream, asincronía, modelos y Provider; NDJSON/UCI como complemento. |
| Pasos | 1. Leer stream NDJSON y estado inicial. 2. Procesar eventos/heartbeat sin rehacer jugadas. 3. Enviar movimiento UCI y esperar confirmación. 4. Mostrar relojes/final según servidor. 5. Mostrar ejercicios como recomendación sin afirmar que se pausa Lichess. 6. Liberar stream y gestionar reconexión limitada. |
| Pruebas | Movimientos en dos cuentas confirmados por servidor; ilegales/errores; stream cerrado; final y relojes reales; overlay de ejercicio no cambia el tiempo del servidor. |
| Criterio de aceptación | Online funcional con estado coherente, distinto de LAN. Si se acordó postergarlo, registrar esa aprobación y no afirmar cumplimiento de RF05. |
| Estado | Pendiente |

| Parte | Foco y mensaje de commit sugerido para el usuario |
|---|---|
| B13.01 · stream | `feat(online): representar estado de partida por NDJSON` |
| B13.02 · movimientos | `feat(online): enviar y confirmar jugadas en Lichess` |
| B13.03 · ejercicios | `feat(online): mostrar ejercicios sin alterar reloj remoto` |

### B14 · Verificación y entrega del lunes

| Campo | Contenido |
|---|---|
| Identificador | B14 |
| Nombre | Verificación y entrega del lunes |
| Objetivo | Entregar solo comportamiento comprobado y código que ambos puedan explicar. |
| Requisitos previos | Bloques del alcance de entrega acordado completos y aprobación de avance. Si se mantiene alcance completo, incluye B12/B13. |
| Archivos involucrados | Pruebas pertinentes, correcciones acotadas, README público, bitácora y artefacto APK; reportes privados por parte. |
| Conceptos Flutter | Comandos analyze/test/build de clase 5 e integración de clases 6/7. |
| Pasos | 1. Revisar matriz de requisitos. 2. Ejecutar formato comprobado/análisis/pruebas. 3. Recorrer Auth/CRUD/API/puzzle/LAN/online según alcance. 4. Generar e instalar APK. 5. Completar ejecución reproducible y aportes del equipo. 6. Ensayar explicación por función. |
| Pruebas | Usuarios A/B/sin sesión, error de red, dos Android Wi-Fi, captura y Listo; online real si incluido; analyze/test/build e instalación; contribuciones Git de lectura. |
| Criterio de aceptación | Artefacto probado, requisitos verificables y pendientes explícitos; documentación pública suficiente aunque bloques sea privado; sin fabricar commits o resultados. |
| Estado | Pendiente |

| Parte | Foco y mensaje de commit sugerido para el usuario |
|---|---|
| B14.01 · validacion | `test: verificar flujos del alcance de entrega` |
| B14.02 · entrega | `docs: documentar ejecución y evidencia de ChessErcise` |

## 4. Matriz de verificación de entrega

| Requisito | Evidencia concreta | Bloques |
|---|---|---|
| Android y diseño | APK en objetivo, interfaz alineada con PDF; marco iPhone no obliga a iOS | B01–B04, B14 |
| Auth | Registro/ingreso/salida reales y protección al volver atrás | B04 |
| CRUD privado | Cuatro operaciones persistidas y denegaciones A/B/sin sesión en servidor | B05–B06 |
| API, constructor y animaciones | Puzzle real con FutureBuilder; tarjeta→detalle con objeto, Hero e implícita | B07 |
| Puzzle jugable | Posición/turno/solución correctos y ejercicio al fallar confirmado con Listo | B08 |
| LAN | Dos Android en misma Wi-Fi, host/cliente y partida sincronizada | B09–B10 |
| Desafíos | El rival elige, el afectado confirma, una captura no se duplica | B11 |
| Online | Cuentas y partida Lichess, stream/jugadas/relojes reales; si se posterga, aprobación expresa | B12–B13 |
| Aprendizaje y Git | Explicación por función/parte, mensajes sugeridos y aportes reales de ambos | Transversal, B14 |

Todo resultado de aplicación sigue **no ejecutado**. Consultar documentación y APIs con Python o leer mockups no completa sus bloques funcionales.

## 5. Comandos futuros y límites

Ejemplos **no ejecutados ahora**:
- `flutter doctor -v` y `flutter devices`: identificar entorno y objetivos; no modifican la lógica de app, pero pueden inicializar cachés del SDK.
- `flutter create --project-name chessercise --platforms android .`: base Android en raíz; revisar preservación de archivos y diff; no forzar sobrescritura.
- `flutter pub add <paquete>`: modifica pubspec/lock y resuelve dependencias; hacerlo solo en la parte que lo necesita, con versiones verificadas.
- `flutter analyze`: diagnósticos estáticos; no certifica red o comportamiento en uso.
- `flutter test`: ejecutar pruebas pertinentes; no cambiar expectativas para ocultar fallos.
- `dart format --output=none --set-exit-if-changed lib test`: comprobar formato sin escribir; interpretar error como necesidad de formato, no como fallo de aplicación.
- `flutter run -d <id>` y `flutter build apk --release`: ejecutar/compilar con configuración real; build exitoso no sustituye instalación y uso en dos Android.

Cada comando realmente usado lleva en el reporte: comando exacto y carpeta, propósito, efecto técnico, razón, salida esperada, resultado real y errores comunes/solución. No guardar contraseñas o tokens en esos reportes, aunque sean internos.

Preparar SQL concreto antes de pedir autorización para ejecutarlo. Crear proyecto e integrar SDK son pasos distintos; preparar Supabase ahora no autoriza tablas arbitrarias ni conectar otros repositorios. La credencial nueva de base se introduce por el usuario en el panel.

## 6. Pendientes que condicionan el inicio

Ver [requisitos](02_requisitos_proyecto.md), [revisión de fuentes](05_revision_propuesta_y_mockups.md) y [preparación Supabase](06_preparacion_supabase.md). La siguiente intervención de desarrollo debe identificar bloque **y parte** autorizados. Hasta entonces, no crear lib/, android/ o pubspec ni instalar paquetes.
