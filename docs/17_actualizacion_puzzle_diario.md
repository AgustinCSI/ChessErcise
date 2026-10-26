# 17 · Actualización del puzzle diario

La caché anterior conservaba la primera respuesta de cada fecha UTC hasta el día siguiente. Esto podía mantener el puzzle anterior si la fuente cambiaba después de la consulta inicial. No se comprobó el contenido del almacenamiento del dispositivo del usuario; se identificó y corrigió esta posibilidad en el código.

Ahora se guarda `consultadoEn` junto al contenido y la caché vence a los quince minutos, tanto en memoria como en disco. Al abrir el desafío, reanudar la aplicación o volver desde el tablero, se revalida si ha vencido. Cambiar la fecha UTC también fuerza una consulta. No hay consultas periódicas mientras el usuario mantiene abierto el tablero.

El botón Actualizar puzzle omite ambas cachés. Permanece deshabilitado durante la carga. Los guardados anteriores sin fecha de consulta se revalidan una vez. Una consulta fallida muestra el error existente y permite reintentar; no etiqueta una respuesta antigua como nueva.

La finalización y la rutina siguen asociadas a cuenta e ID del puzzle. Un ID nuevo comienza sin progreso; recibir otra vez el mismo ID conserva el intento finalizado. Revalidar el mismo puzzle dentro del día también conserva su valoración mostrada. No se borran preferencias ni resultados para simular un puzzle nuevo.

Verificación: `flutter analyze` sin incidencias y 83 pruebas aprobadas. Las regresiones cubren vencimiento durante la misma fecha UTC, vencimiento en disco sin prolongarse al reiniciar, migración de caché anterior, actualización manual, errores/reintentos y progreso independiente para el ID nuevo. Consulta real al endpoint el 26-10-2026: devolvía `m5n0s`; este dato es una observación puntual, no un ID fijo en la aplicación.
