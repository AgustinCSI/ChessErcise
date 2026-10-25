# 02 · Requisitos y alcance de ChessErcise

Revisión: 24 de octubre de 2026. Sustituye las suposiciones del 23 de octubre sobre un solo dispositivo, ranking como función principal de API y puzzle como extra. Estado: alcance aclarado por el equipo; prioridad de entrega de online pendiente de confirmar.

Actualización de avance del 25-10-2026: el compañero aportó la base en `chess_ercise/`, que solo contiene el contador Flutter y su prueba. Los requisitos siguientes no cambian; su estado verificado está en [07_revision_avance_2026_10_25.md](07_revision_avance_2026_10_25.md). No confundir creación de la estructura con implementación de los modos de juego.

## 1. Fuentes y autoridad de cada requisito

| Fuente | Información verificada |
|---|---|
| README | Nombre, integrantes e idea general de ajedrez con ejercicio al perder piezas |
| `docs/plantilla-propuesta-flutter.docx` | Propuesta completada, fechada 13 de octubre: sección 1, público, LAN, online, elección/rechazo de castigo, puzzle diario y paquetes |
| `docs/ChessErciseMockupsUso.pdf` | Trece páginas: identidad y pantallas de acceso, registro, menú, puzzle, online, LAN y penalizaciones |
| Aclaraciones del equipo del 24-10-2026 | Host y cliente en la misma Wi-Fi; solo Android; priorizar compatibilidad; confirmación «Listo» sin sensores; presentación el lunes; documentación interna y commits manuales por parte |
| Clases 5–7 | Metodología obligatoria y mínimo académico, según [análisis verificado](01_analisis_unidad_2.md) |

La propuesta y los mockups ahora están disponibles en el repositorio. El diagnóstico del día 23 se conserva como registro histórico de lo que había entonces; ya no debe interpretarse como ausencia actual de esos documentos.

## 2. Problema, público y objetivo

La propuesta busca combinar el hobby del ajedrez con actividad física e interacción social. Describe a Erick, de 23 años, interesado en divertirse mientras hace ejercicio. Su explicación sobre estrés es una motivación declarada por los autores, no un resultado de salud comprobado por esta auditoría.

El objetivo es jugar partidas válidas, asociar pérdidas de piezas a ejercicios elegidos por el oponente y ofrecer un puzzle diario. El modo LAN utiliza dos Android: uno aloja la partida y otro se conecta por la misma red. El modo online utiliza la plataforma Lichess y es una integración distinta.

## 3. Decisiones actualizadas

| ID | Estado | Decisión y efecto |
|---|---|---|
| D01 | Confirmada | Dos dispositivos en LAN Wi-Fi, uno host y otro cliente. Se descarta la propuesta anterior de compartir un teléfono. No confundir LAN con online por Internet |
| D02 | Confirmada | Android únicamente. No crear ni probar iOS o web |
| D03 | Criterio confirmado; validación técnica pendiente | Escoger versiones compatibles y la solución más simple. Revisar chessground + dartchess y web_socket_channel, ya propuestos por el equipo. No confundir documentación compatible con resolución/build comprobados |
| D04 | Confirmación simple confirmada | El jugador declara «Listo» tras hacer ejercicio. La propuesta añade selección por el rival según valor de pieza y aceptar/rechazar; mantener esos requisitos y confirmar el detalle de rechazo. Sin verificación física avanzada |
| D05 | Preparación recomendada ahora | Hay acceso al panel y una organización Free; en la inspección del 24-10 su lista de proyectos estaba vacía. Preparar el proyecto de ChessErcise antes de Auth; tablas durante su bloque. Ver [preparación Supabase](06_preparacion_supabase.md) |
| D06 | Confirmada por el usuario | Presentación el lunes **26 de octubre de 2026**. La propuesta indica sección 1. No hay rúbrica adicional disponible; si llega, conciliar sin inventar criterios |

La pregunta sobre priorizar LAN+puzzle+requisitos académicos frente a mantener también online para el lunes sigue pendiente. **Online y puzzle son requisitos explícitos de la propuesta; no se eliminan ni se declaran opcionales unilateralmente.**

## 4. Funcionalidades y trazabilidad

P0-exp = funcionalidad core explícita del documento; P0-acad = mínimo del curso; prop = adaptación recomendada. La dificultad es relativa al nivel del curso, sin promesa de horas.

| ID | Función | Prioridad/origen | Dificultad | Dependencias | Bloque vigente |
|---|---|---|---|---|---|
| RF01 | Partida LAN host/cliente en misma Wi-Fi | P0-exp, propuesta §6 y D01 | Alta | Dos Android, transporte y motor | B03, B09–B11 |
| RF02 | Captura permite al oponente elegir ejercicio según valor de pieza | P0-exp, propuesta §6; PDF pp. 10/12 | Media/alta | Catálogo, captura, sincronización | B06, B10–B11 |
| RF03 | Aceptar/rechazar castigo en LAN | P0-exp, propuesta §6; PDF p. 13 | Media | Definir rechazo y estados | B11 |
| RF04 | Confirmar «Listo» sin comprobación física | Confirmado por usuario, D04 | Baja en UI; media en sincronización | Desafío pendiente y participante correcto | B08, B11 |
| RF05 | Partida online con cuentas Lichess | P0-exp, propuesta §6; PDF pp. 9/10 | Alta | Autorización Lichess, API Board y dos cuentas | B12–B13 |
| RF06 | Puzzle diario Lichess con ejercicio al fallar | P0-exp, propuesta §6; PDF p. 8 | Media/alta | API pública, PGN/posición y solución | B07–B08 |
| RA01 | Registro, ingreso y salida Supabase | P0-acad | Media | Proyecto real y configuración | B04 |
| RA02 | API deportiva con FutureBuilder | P0-acad | Media | Modelo y servicio de puzzle | B07 |
| RA03 | Lista/tarjeta a detalle con objeto por constructor | P0-acad | Baja | Tarjeta del puzzle diario y pantalla de resolución | B07 |
| RA04 | Hero y animación implícita | P0-acad | Baja/media | Tarjeta/detalle y estado visual | B07; también B06/B11 |
| RA05 | CRUD de datos propios con RLS | P0-acad | Media/alta | Tabla ejercicios y Auth | B05–B06 |
| RA06 | Formulario con Form, TextFormField y validator | P0-acad | Baja/media | Acceso y ejercicios | B04, B06 |
| RA07 | ChangeNotifier compartido con Provider | P0-acad | Media | Ámbito de sesión/pantallas | B04, B06–B13 |
| RA08 | Widgets propios en archivos separados | P0-acad | Baja | Reutilización real | Transversal |
| RA09 | Contribuciones de todos en GitHub | P0-acad | Organización | Commits realizados por integrantes | Por parte; verificación B14 |
| RA10 | Propuesta y mockup ≥5 pantallas | P0-acad | Revisión | Material aportado y enlace Canva de la propuesta | B01 |
| RP01 | Catálogo privado editable de ejercicios | prop para RA05/06 y RF02 | Media | Auth y RLS | B05–B06 |
| RP02 | Vista de estado/resultado y errores comprensibles | prop de cierre y calidad | Media | Resultado del motor y conexión | B08, B10–B11, B13–B14 |

Se retira la recomendación de un ranking como sección adicional: la API del puzzle ya se alinea con el producto y cubre el consumo deportivo. La consulta de ranking del día 23 fue investigación, no una funcionalidad implementada.

## 5. Alcance y prioridad para el lunes

El **alcance completo documentado** incluye LAN, online, puzzle y mínimos académicos. El plan mantiene bloques para todo ello.

La **prioridad recomendada, todavía pendiente de aceptación**, es terminar primero Android + Auth + CRUD/RLS + puzzle + LAN con ejercicios, y abordar después online Lichess. Así se demuestra primero el núcleo distintivo y el mínimo del curso. Postergar online requiere decisión explícita del equipo: no se presenta una entrega parcial como cumplimiento completo de la propuesta.

No se promete que catorce bloques quepan en el tiempo disponible. Los puntos de mayor incertidumbre son prueba LAN en dos teléfonos y autorización/stream de partidas online. Deben verificarse temprano; si fallan, se informa y se ajusta alcance con el usuario, sin sustituir LAN por juego en un teléfono.

## 6. Flujos y pantallas

| Flujo/pantalla | Fuente | Tratamiento |
|---|---|---|
| Identidad y arranque rosa | PDF pp. 1–3 | Conservar dirección visual; el marco de iPhone del mockup no implica soporte iOS |
| Correo, contraseña y registro | PDF pp. 4–6 | Seguir formulario validado del profesor; confirmar si se mantienen dos pasos de acceso |
| Menú con Online / Local / Puzzle y acceso a perfil | PDF p. 7 | Conservar destinos; perfil completo no equivale a un requisito implementado |
| Crear/unirse a sala LAN | D01 y propuesta; no dibujado en detalle | Añadir pantalla mínima host/cliente, IP/puerto y estado de conexión |
| Tablero y selección de penalización | PDF pp. 9–12 | Adaptar chessground dentro de pantalla Flutter; distinguir quién puede elegir |
| Aceptar/rechazar y después «Listo» | PDF p. 13 y D04 | Confirmación manual; resultado de rechazo pendiente de concretar |
| Puzzle diario | PDF p. 8 | Cargar API; tarjeta/detalle propuesta para cubrir navegación académica; resolver sobre tablero |
| Mis ejercicios y formulario | Mínimo académico y RP01 | Vista complementaria necesaria para CRUD, sin reemplazar los modos del mockup |

Relojes, rendición, oferta de tablas y navegación de jugadas aparecen en el diseño. Deben asignarse a entregables concretos antes de implementarlos; no se consideran automáticamente extras ni terminados por dibujarlos. Género y fecha de nacimiento aparecen en registro: confirmar su necesidad antes de agregar almacenamiento o validaciones. Nombre de usuario se puede representar inicialmente en metadatos Auth; no se presupone una segunda tabla.

La propuesta contiene alternativa de «tomar un trago» al rechazar en LAN. Se registra fielmente como requisito aportado, sin recomendaciones de consumo. Debe acordarse si se conserva ese texto/acción o solo se registra rechazo. La instrucción «Listo» no resuelve por sí sola esa elección.

## 7. Datos y separación de sistemas

| Dato | Origen y dueño |
|---|---|
| Sesión ChessErcise | Supabase Auth; cada Android usa su acceso a la app. No guardar contraseñas en tablas propias |
| Ejercicio | Tabla privada: id, user_id, título, instrucciones, categoría de valor de pieza, repeticiones positivas y creación |
| Configuración de sala | Host: participantes/colores, ejercicios elegibles copiados, versión del protocolo y estado inicial |
| Solicitud LAN | Cliente: id de comando, id de partida, revisión esperada y acción; no impone la posición final |
| Estado LAN confirmado | Host: revisión creciente, posición, turno, fase y desafío; ambos dispositivos lo representan |
| Captura/desafío | Id único de jugada aceptada, color que perdió, rival que elige, ejercicio elegido y estado de resolución |
| Puzzle diario | API Lichess: datos de puzzle/juego, PGN, punto de inicio y solución. Transformación explicada en B07–B08 |
| Autorización online | Lichess, distinta de Supabase. No pedir ni guardar contraseña Lichess dentro de la app |
| Partida online | Estado confirmado por Lichess; no por el servidor LAN |

El host puede compartir con el invitado la copia de los ejercicios de esa sala, como parte del modo LAN. Esto no habilita leer la tabla privada de otro usuario por Supabase. No se propone persistir partidas ni agregar estadísticas en esta primera versión sin necesidad concreta.

## 8. Tecnologías y método obligatorio

El método del profesor es la referencia de implementación: widgets compuestos, pantallas por archivo, modelos, servicios concretos, setState local, Provider compartido, Navigator y datos por constructor, Dio/FutureBuilder, Supabase Auth/RLS. Evitar migrar a otro estilo de manejo de estado o a patrones avanzados por preferencia del agente.

Paquetes propuestos por el equipo: chessground para UI del tablero, dartchess para reglas y web_socket_channel para comunicación. El host WebSocket requiere además funciones del SDK Dart; el paquete no descubre teléfonos ni sincroniza ajedrez automáticamente. Son complementos que se explicarán progresivamente, conectándolos con Future/Stream y ciclo de vida ya vistos.

Cada parte documentará sus funciones, entradas, salidas, cambios de estado y fragmentos relevantes, más una propuesta de commit manual. Los reportes de `docs/bloques/` quedan **internos e ignorados por Git**; el código, pruebas y documentación pública siguen siendo versionables. No hacer commits ni stage por el usuario.

## 9. Próximas decisiones concretas

1. Completar el proyecto Supabase en la organización verificada; no hace falta conectar ningún repositorio.
2. Confirmar si online se entrega el lunes o se posterga expresamente.
3. Acordar rechazo del desafío, asociación valor→ejercicios y campos de perfil/registro.
4. Aceptar el reordenamiento de bloques antes de iniciar código Flutter.
5. Probar compatibilidad real de los tres paquetes y LAN en dos Android al comenzar sus bloques.

La arquitectura general fue aceptada por el usuario. Esta revisión adapta sus componentes, sin considerar aprobada toda implementación futura o ejecución SQL.
