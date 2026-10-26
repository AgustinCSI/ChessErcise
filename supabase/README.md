# Perfil de ChessErcise

En el panel del proyecto ChessErcise abre **SQL Editor → New query**, pega el
contenido de `profiles.sql`, revisa y ejecuta una vez. Este archivo **todavía no
ha sido ejecutado por Codex**. Crea la tabla `profiles`, el índice de username
único sin distinguir mayúsculas y políticas para leer/crear/editar solo el propio
perfil. No solicita service_role ni contraseña de base de datos en Flutter.
Si ya existe una tabla profiles, revisa su esquema antes de ejecutar: el script
no la elimina ni reemplaza y fallará sin aplicar cambios por estar en transacción.

Datos: username (3–20 letras ASCII, números o guion bajo), fecha de nacimiento
(1900–hoy) y género con opción «Prefiero no decirlo». Sin nombre real, avatar
remoto ni nueva contraseña. El género y fecha son privados junto con el resto de
la fila; la app no consulta perfiles de otros jugadores.

La cuenta Auth existe antes del perfil. Al entrar o restaurar sesión, ProfileGate
consulta la fila por `auth.uid()`. Si no existe o está incompleta muestra setup;
si la lectura falla bloquea con reintento/salida. Guardar exige respuesta real del
servidor antes de habilitar el menú. Al reanudar la app se vuelve a comprobar.
El perfil puede editarse en la pestaña Perfil. No hay flag local de completado.

Prueba manual con dos cuentas A/B: A crea perfil y cierra/reabre (no debe pedirlo
otra vez); B empieza en setup. B no puede leer/editar A; el índice impide nombres
como Jugador/jugador simultáneamente. Sin sesión no hay acceso a la tabla. Prueba
cerrar durante setup, reintentar sin red y error de username ocupado. No declares
RLS comprobado en servidor hasta realizar estas pruebas con el proyecto real.

Las dos pestañas (Inicio y Perfil) viven dentro de la sesión; salir destruye la
pila privada. El gate es un requisito de navegación de esta app; las futuras
tablas de juego necesitarán sus propias políticas RLS, no basta ocultar botones.

## Foto de perfil (actualización)

Si ya ejecutaste profiles.sql, **no lo repitas**. En SQL Editor crea otra consulta
con `avatars.sql` y ejecútala una vez. Este segundo script añade `avatar_path` a
profiles y crea el bucket **privado** `avatars`, límite2MB y MIME JPG/PNG/WebP.
No crees manualmente otro bucket público: la app descarga la imagen con la sesión
actual. Las políticas permiten SELECT/INSERT/DELETE solo dentro de la carpeta
cuyo nombre es el UUID del usuario. No se usa UPDATE: cada foto tiene nombre nuevo.
Si ya existe un bucket avatars, revisa su configuración antes; la transacción
fallará sin reemplazarlo ni modificar otros recursos.

Un bucket es el contenedor de archivos de Supabase Storage; profiles es la tabla
SQL de datos. La fila guarda únicamente `<userId>/<archivo>`, no la imagen ni
una URL pública. La foto es opcional y no cambia el requisito de inicialización.

Perfil abre como lectura. El lápiz del avatar abre Editar perfil; «Cambiar foto»
abre galería/selector de archivo. Se previsualiza localmente y **solo se sube al
pulsar Guardar**. Volver sin guardar descarta la selección. La subida usa nombre
nuevo, y si falla guardar la fila se intenta eliminar el archivo nuevo. Después
de éxito se intenta eliminar la foto anterior. Storage y tabla no comparten una
transacción; si falla la limpieza puede quedar un archivo sin referencia.

Android usa image_picker; en Linux usa el selector de archivos del sistema. No
se añadió cámara ni permisos amplios de almacenamiento. Reinicia por completo
la app tras instalar la nueva dependencia. Selección y subida todavía necesitan
prueba manual en los dispositivos reales.

Verifica con A/B: cada uno puede subir/leer su avatar y no el del otro; la app
mantiene su foto anterior si falla el guardado. Comprueba cancelar selector,
cancelar edición, archivo no imagen, >2MB, cambio de foto, reinicio de app y
que la foto aparece bajo el tablero. No consideres Storage/RLS verificados hasta
completar estas pruebas en el proyecto remoto.
