# 08 · Revisión del merge de acceso y puzzle diario

> Actualización posterior: el SDK ya es compatible, el análisis y las 24 pruebas se ejecutaron correctamente, y la aplicación real se abrió con el JSON Supabase del usuario. Ver [ejecución sin emulador](09_ejecucion_local_sin_emulador.md). El bloqueo M01 y la carencia de instrucciones M02 descritos abajo reflejan la inspección previa y ya fueron atendidos para esta ejecución de desarrollo; los pendientes de producto siguen vigentes.

Fecha: 25 de octubre de 2026. Base local anterior: `294e4b1`. Merge aplicado: **`bdda95196838a2ef7544304bfe75728b07838e78`**, pull request #1. Esta revisión sustituye el estado funcional previo descrito en el informe 07.

## 1. Actualización realizada

El usuario autorizó aplicar el merge publicado y revisar sus cambios. El árbol de trabajo estaba limpio; main estaba ocho commits por detrás. Se ejecutó `git pull --ff-only origin main`, que avanzó directamente de 294e4b1 a bdda951, sin conflictos ni un nuevo commit local de merge.

Se incorporaron 33 archivos cambiados, aproximadamente 3.507 líneas añadidas y 157 retiradas. No se hizo reset, stash, cambio de rama, push o reescritura del trabajo del compañero. Después de actualizar, main coincidía con origin/main.

El comando compuesto de inventario terminó con código 1 porque la búsqueda posterior no encontró AGENTS.md. La salida de pull confirmó actualización correcta; ese código no significaba fallo del merge y no se repitió pull innecesariamente.

## 2. Commits incorporados

| Commit | Autor | Cambio |
|---|---|---|
| 536ee10 | Juan Pablo Molina | Providers, configuración, acceso Supabase y menú |
| 18cf1f2 | Juan Pablo Molina | Puzzle diario desde Lichess |
| bc5ee11 | Juan Pablo Molina | Barra de controles del puzzle |
| 8fcca8d | Juan Pablo Molina | Guardado local y resumen |
| 3e5565b | Juan Pablo Molina | Historial de jugadas sobre el tablero |
| d8de6c2 | Juan Pablo Molina | Distribución y espaciado |
| c8567ff | Juan Pablo Molina | Límites y desplazamiento de la barra de jugadas |
| bdda951 | Agustin | Merge de feature/daily_puzzle a main, que incluye el acceso anterior |

No hay que repetir esos commits ni volver a implementar lo que ya aportan. Los ajustes futuros deben partir de sus componentes y explicar únicamente la diferencia nueva.

## 3. Funcionalidades presentes en código

### Arranque y acceso

`main.dart` ahora inicializa bindings, verifica parámetros de configuración e intenta iniciar Supabase antes de ejecutar la app. `app.dart` compone MaterialApp, tema y AuthProvider; si falta configuración muestra una pantalla explicativa, sin simular una sesión.

AuthProvider implementa ingreso, registro, salida, envío exclusivo, mensajes de error y confirmación de correo. LoginScreen usa Form, validadores, confirmación de contraseña, controles deshabilitados al enviar y liberación de controladores. AuthGate escucha sesión; SessionNavigator elimina la pila privada al salir/cambiar usuario y mantiene un provider de puzzle por usuario.

**Límite:** hay integración contra el SDK, pero no se verificaron cuentas reales, retorno del enlace de correo o configuración del proyecto externo en esta revisión.

### API, tablero y resolución del puzzle

LichessPuzzlesService consulta la API diaria con Dio y límites de tiempo. PuzzleDiario convierte el JSON, utiliza FEN cuando existe, reconstruye desde PGN como alternativa y comprueba que la secuencia de solución sea legal.

DailyPuzzleScreen conserva el Future y representa espera/error/reintento; pasa el objeto por constructor a PuzzleScreen. Hay Hero entre tarjeta y detalle y AnimatedContainer en PuzzleStatus. TableroWidget adapta chessground al motor dartchess, orienta al jugador, muestra legales/jaque y deshabilita jugadas durante espera, revisión o final.

PuzzleController distingue jugada ilegal de legal incorrecta; esta última aumenta errores sin alterar la posición. Tras una jugada correcta responde el rival con un Timer. También incorpora pistas por paso, revisión de historial sin alterar la posición real y rendición con solución visible sin contar como éxito. El Timer se cancela en dispose.

**Límite:** es un controlador específico de puzzle, no todavía un servicio general de partida/capturas que cierre todo B03 o implemente LAN.

### Guardado local y resumen

PuzzlesProvider precarga, conserva Future/caché por fecha UTC y guarda contenido/progreso por id de usuario mediante SharedPreferences. Serializa escrituras, muestra estado/error de guardado y ofrece reintento. Restaura una respuesta pendiente del rival y conserva un resultado final sin sobrescribirlo con un intento vacío.

PuzzleSummaryScreen muestra resolución/rendición, errores, pistas y revisión del tablero. **La rutina de ejercicios sigue como “Próximamente”**. SharedPreferences es persistencia del dispositivo: no equivale a una tabla Supabase, CRUD o RLS.

## 4. Archivos y responsabilidades principales

| Área | Archivos destacados | Estado |
|---|---|---|
| Raíz/configuración | lib/main.dart, app.dart, config/app_config.dart | Incorporados; ejecución local no validada |
| Acceso | AuthProvider, AuthGate, LoginScreen y SessionNavigator | Implementación presente; prueba real pendiente |
| Datos de puzzle | models/puzzle_diario.dart, progreso_puzzle.dart, data/lichess_puzzles_service.dart | Tipado, conversión y contrato presentes |
| Estado de puzzle | logic/puzzle_controller.dart, presentation/providers/puzzles_provider.dart | Resolución y persistencia local presentes |
| Vistas | DailyPuzzleScreen, PuzzleScreen y PuzzleSummaryScreen | Flujo en código; dispositivo/build no comprobados |
| Widgets | TableroWidget, PuzzleToolbar, PuzzleMoves, PuzzleStatus y PuzzleSaveStatus | Separados y reutilizables en el flujo de puzzle |
| Android | Manifiesto principal | INTERNET y retorno chessercise://login-callback/ incorporados |
| Dependencias | pubspec.yaml/lock | Provider, Supabase, tablero/motor, Dio y SharedPreferences declarados; lockfile ya versionado |

## 5. Hallazgos y pendientes, con evidencia

| ID | Nivel | Evidencia y consecuencia | Próximo tratamiento |
|---|---|---|---|
| M01 | Crítico para ejecutar aquí | pubspec exige Dart ^3.13.5 y lockfile >=3.13.5; binario local confirmó 3.12.2 | Alinear SDK en B02 antes de resolver/analizar/probar. No se actualizó ni cambió la restricción |
| M02 | Importante: reproducibilidad | chess_ercise/README.md quedó con solo un encabezado, pero app.dart remite a ese archivo para configurar Supabase | Documentar parámetros SUPABASE_URL/SUPABASE_PUBLISHABLE_KEY, ejecución y retorno de correo; hoy esa instrucción no existe en el README de app |
| M03 | Importante: requisito pendiente | puzzle_summary_screen.dart muestra “Próximamente aparecerá aquí la rutina asociada a este intento”; fallar solo aumenta contador | Completar ejercicio por fallo y confirmación Listo en B08 |
| M04 | Importante: mínimo académico pendiente | No hay EjerciciosService, tabla SQL, políticas RLS o formulario CRUD de ejercicios | B05–B06 siguen pendientes; caché local no sustituye ese requisito |
| M05 | Alcance pendiente | HomeScreen mantiene LAN y online con onPressed null y etiqueta Próximamente | B09–B13 no están implementados |
| M06 | Mejora de presentación | PlayerInfo usa “Tu nombre” por defecto y PuzzleScreen lo construye sin nombre real | Vincular identidad cuando corresponda; no afirmar que el perfil del mockup está completo |
| M07 | Documentación/aprendizaje | Se añadió SharedPreferences y lógica de caché/progreso que el plan inicial no detallaba | Conservar y explicar como complemento; no atribuirlo automáticamente a las clases verificadas |

M03–M05 son carencias de alcance, no errores de algoritmo inventados. La revisión estática no identificó evidencia suficiente para afirmar otro fallo concreto de ejecución sin correr la aplicación.

La configuración usa String.fromEnvironment. No hay supabase.local.json en este checkout y no se inspeccionaron otros mecanismos de parámetros del usuario. Por eso no se afirma que la cuenta/proyecto Supabase externo no exista; solo que el arranque real sigue sin validar aquí.

## 6. Qué problemas anteriores sí se atendieron

- Separación main/app: incorporada, ya no hay contador genérico.
- Lockfile: existe y está versionado. La excepción `!pubspec.lock` en el ignore de aplicación resuelve su exclusión anterior.
- INTERNET en manifiesto principal: incorporado, ya no está solo en debug/profile.
- Provider, modelos, servicios, pantalla/detalle y widgets: presentes para acceso/puzzle.

Esto evita mantener como pendientes tareas ya realizadas. No acredita por sí solo compilación o integración real.

## 7. Pruebas escritas y límites de validación

| Archivo | Casos declarados | Cobertura que intentan comprobar |
|---|---|---|
| test/widget_test.dart | 3 | Pantalla sin configuración, AuthProvider con cliente falso y validación de formulario |
| test/daily_puzzle_screen_test.dart | 1 | Espera/error/reintento y navegación con objeto, usando servicio controlado |
| test/puzzle_test.dart | 13 | Conversión FEN/PGN, jugadas/solución, cancelación del Timer, historial/rendición/pistas y tamaños de UI |
| test/puzzle_persistence_test.dart | 7 | Caché/precarga, progreso por usuario, recreación de provider, resultado final y error de datos guardados |
| Total | **24** | Son declaraciones de prueba leídas, **no resultados de ejecución** |

No se ejecutaron flutter pub get/analyze/test/run/build: el SDK local sigue sin satisfacer el requisito. Tampoco hay package_config local. No se modificaron dependencias ni el entorno para forzar un resultado. No se comprobó la app en dos Android, Supabase real o API desde Flutter.

Se comprobó: actualización Git sin conflictos; presencia de fuentes/lockfile; excepción de ignore; lectura de los cuatro archivos de test; versión del binario Dart; rutas del manifiesto y ausencia de componentes CRUD/LAN. La revisión de código no equivale a validación visual de la UI real.

## 8. Estado actualizado del plan

| Bloque | Estado | Trabajo restante |
|---|---|---|
| B01 | En progreso | Cierre de alcance y proyecto Supabase externo verificable |
| B02 | En progreso | Alinear SDK, resolver dependencias, analizar/probar/arrancar en Android y documentar configuración |
| B03 | En progreso | Motor/tablero usados para puzzle; falta validar y definir contratos generales de partida/captura |
| B04 | En progreso | Código de acceso/menú integrado; falta prueba real de registro, confirmación, ingreso, salida y navegación |
| B05–B06 | Pendientes | Tabla/RLS/servicio y UI de ejercicios |
| B07 | En progreso | API, FutureBuilder, constructor, Hero e implícita implementados; validar ejecución real |
| B08 | En progreso | Puzzle/historial/guardado/resumen implementados; falta ejercicio por fallo/Listo y validación |
| B09–B13 | Pendientes | Multijugador LAN/online y mecánica de desafíos de partida |
| B14 | Pendiente | Matriz integral, artefacto Android probado y documentación reproducible |

No marcar bloques completos hasta verificar sus criterios. Tampoco rehacer los componentes solo porque el compañero avanzó en un orden distinto del plan.

## 9. Próximo orden recomendado

1. Cerrar SDK y configuración de ejecución en B02, sin duplicar la app ni rebajar restricciones a ciegas.
2. Ejecutar analyze, las 24 pruebas y un arranque Android; probar Auth contra el proyecto correcto y puzzle contra Lichess.
3. Revisar resultados y corregir solo defectos reproducidos, por partes documentadas y commits manuales.
4. Completar B05–B06 y la rutina pendiente de B08 para cubrir ejercicio + CRUD/RLS.
5. Continuar LAN y online según prioridades que confirme el equipo; no presentarlos como ya hechos.

La actualización autorizada se aplicó. La revisión posterior solo modifica documentación de avance; no altera la implementación incorporada ni publica nuevos commits.
