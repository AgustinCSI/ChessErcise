# 06 · Preparación de Supabase para ChessErcise

Fecha: 24 de octubre de 2026. **Recomendación: preparar el proyecto y su acceso ahora; integrar Auth temprano y crear tablas por bloque.** No posponer toda la conexión hasta el final.

Actualización del 25-10 tras bdda951: ya hay supabase_flutter, inicialización, AuthProvider, formulario y AuthGate en `chess_ercise/`. Con Flutter 3.47.8/Dart 3.13.7 se abrió el ingreso real usando el archivo supabase.local.json del usuario; Auth settings respondió HTTP 200. No se inició sesión ni se crearon cuentas. El estado externo del panel descrito abajo corresponde a la inspección del día 24; queda como registro histórico. [Evidencia de ejecución](09_ejecucion_local_sin_emulador.md).

## 1. Preparar ahora no significa implementar todo ahora

| Momento | Trabajo | Razón |
|---|---|---|
| Ahora, preparación | Confirmar cuenta, organización gratuita, proyecto ChessErcise y acceso al panel | Evitar descubrir una dependencia de cuenta/acceso durante la entrega |
| B04, tras base Android y prueba del tablero | Inicialización del SDK, registro/ingreso/salida reales | Seguir la progresión formulario→estado→Auth del curso |
| B05 | Tabla ejercicios, restricciones, permisos y RLS de cuatro operaciones | Diseñar/ejecutar solo el esquema que el CRUD necesita |
| B06 | Interfaz de administración y formularios | Conectar UI a un servicio y tabla ya comprobados |

La cuenta Supabase no sustituye la cuenta Lichess. El servidor de partida LAN vive en el Android host, no en Supabase. La [guía oficial Flutter](https://supabase.com/docs/guides/getting-started/quickstarts/flutter) requiere un proyecto y luego inicialización con su URL/clave pública; no exige conectar un repositorio GitHub para usarlo.

## 2. Estado observado en el navegador

En la inspección del 24-10-2026:

- La sesión del panel estaba abierta y accesible en el navegador del usuario.
- Existía la organización **CheerErcise**, identificada como **FREE**.
- La lista no mostraba proyectos de base de datos y ofrecía **Create a project**.
- Se abrió el formulario **New project** de esa organización y se completó únicamente el nombre **ChessErcise**.
- El campo de GitHub aparecía como opcional y no se seleccionó repositorio.
- No se pulsó Create new project, no se introdujo/generó contraseña y no se ejecutó SQL.
- El formulario mostraba un aviso de incidente que podía afectar creación en la región Americas. Es una observación puntual del formulario, no una afirmación de indisponibilidad general; si persiste, revisar su enlace de estado antes de atribuirlo al código.

**Organización y proyecto son cosas diferentes.** La organización Free por sí sola aún no da una URL de proyecto/base de datos a la app. Hasta observar el proyecto creado, no registrar D05 como listo ni inventar su referencia.

## 3. Siguiente acción en el panel

El formulario quedó preparado en el navegador. El usuario debe introducir la contraseña nueva de base de datos en el panel y completar la creación gratuita de **ChessErcise** dentro de **CheerErcise**. No es necesario enviar esa contraseña al chat. Si ya se creó durante el trabajo, verificar el proyecto resultante antes de volver a crear otro.

El flujo de control del navegador exige que las credenciales nuevas las introduzca el usuario; el agente no debe generar, introducir ni enviar esa contraseña por su cuenta. Esto no impide seguir después con la configuración ordinaria del proyecto desde la misma sesión web.

Conservar plan Free y evitar opciones de pago. Elegir una región disponible adecuada a los dispositivos del equipo; no cambiar la organización ni comprar recursos para resolver un aviso transitorio. El formulario ofrece Data API, exposición de tablas y RLS automático: antes de almacenar datos, acordar permisos y políticas; no asumir que un check sustituye las pruebas del esquema.

Al terminar se debe poder verificar:

1. Nombre del proyecto y organización correctos.
2. Estado del proyecto disponible, no solo una cuenta o formulario.
3. Acceso a Authentication, Database y SQL Editor del mismo proyecto.
4. URL de proyecto y clave pública/publishable accesibles para la integración B04, sin publicarlas innecesariamente en reportes.

## 4. Acceso del agente y límite de repositorio

Se comprobó acceso al panel mediante el navegador abierto. También se encontró un conector Supabase disponible y se propuso su instalación/conexión; **no se verificó que esté conectado**. El acceso web ya permite continuar y el conector es opcional; no se considera un bloqueo si el usuario prefiere el navegador.

Reglas de alcance:

- Operar exclusivamente sobre el proyecto ChessErcise una vez identificado en esta organización.
- No crear otro proyecto por tanteo, no acceder a proyectos de terceros ni cambiar facturación.
- No conectar GitHub en esta preparación: es opcional y la app puede usar el SDK sin ello.
- Si después se solicita esa integración, el único repositorio autorizado es **AgustinCSI/ChessErcise**, el remoto local verificado. No autorizar acceso a todos los repositorios para facilitar el trabajo.
- No introducir cambios en otras aplicaciones o repositorios del computador.

## 5. Qué configuraremos después

### Autenticación, B04

Revisar proveedor de correo, confirmación y mensajes reales. No desactivar confirmación o controles de acceso por ahorrar pasos sin acordarlo. Probar registro, confirmación si corresponde, ingreso, recuperación de estado y salida. Mantener contraseñas/tokens dentro de sus mecanismos; no crear una tabla propia de contraseñas.

### Datos, B05

Preparar primero SQL concreto revisable de ejercicios y sus cuatro políticas. Luego solicitar la autorización de ejecución requerida por la instrucción original. Una autorización general para navegar/configurar no sustituye la revisión del esquema que todavía no existe.

Probar con cuentas A/B y sin sesión: cada usuario administra solo sus filas y no puede cambiar el dueño mediante UPDATE. La app puede compartir copias de ejercicios con su oponente dentro de la sala LAN, sin abrir la tabla privada a todos.

### Configuración Flutter

Usar un mecanismo simple y explicado, siguiendo clase 7; parámetros de compilación si se acuerdan. La clave pública de cliente es distinta de una clave administrativa. No solicitar service-role para la app ni guardar credenciales de base en el repositorio o la carpeta interna. Documentar forma de configurar y ejecutar en el README público cuando se compruebe.

## 6. Verificaciones todavía pendientes

| Comprobación | Estado |
|---|---|
| Cuenta/sesión y organización Free visibles | Verificado en navegador |
| Formulario correcto con nombre ChessErcise | Preparado; no enviado por el agente |
| Proyecto PostgreSQL creado y disponible | No verificado; requiere completar creación |
| Conector Supabase conectado | No verificado; opcional si se usa navegador |
| SDK Supabase inicializado en Flutter | Main real ejecutado en navegador con JSON local; pantalla de ingreso visible y Auth settings HTTP 200; sin sesión de usuario probada |
| Registro/ingreso/salida reales | No ejecutados |
| Tablas, RLS y CRUD | No creados ni ejecutados |
| Vinculación GitHub | No realizada; innecesaria para comenzar |

Esta separación evita declarar Supabase configurado solo por abrir su página o por disponer de la organización gratuita.
