# 12 · Integración de la introducción y separación de barras

26-10-2026. El usuario solicita terminar el merge iniciado y armonizar la interfaz manteniendo la paleta existente.

## Estado recibido

Rama de destino: MultijugadorLocal, base 5129bca. Merge de main, f9a7f63, ya iniciado por el usuario. Los archivos de intro, recursos y arranque estaban preparados en el índice; el único conflicto era AppTheme. Se comprobó origin/main con fetch y coincidía con el destino del merge pendiente.

## Resolución

Se conserva la introducción animada, sus siete PNG, inicialización simultánea de Supabase y coordinación con Auth/Perfil recibidas de main. El tema conserva colorIntro aportado por esa rama y los colores, tablero rosa, contraste y respuestas rojo/verde de MultijugadorLocal. No se eligió un tema completo descartando el otro: se resolvió el conjunto de constantes y se mantuvo la API que usan ambos.

Las barras se diferencian del contenido mediante un fondo rosa más claro, borde rosa de un píxel y texto oscuro. AppBar usa separación inferior; la navegación Inicio/Perfil usa separación superior. La selección inferior mantiene el vino de la marca, icono blanco y etiqueta destacada. Se reutilizan AppTheme y MainScreen, sin otra barra o sistema de navegación.

## Funciones y archivos revisados

| Archivo relativo a chess_ercise | Trabajo |
|---|---|
| lib/presentation/theme/app_theme.dart | Resolución del conflicto; colorIntro, paleta y esquema de tablero conservados. Constantes colorBarra/colorBordeBarra y estilos de AppBar/NavigationBar |
| lib/presentation/screens/home/main_screen.dart | Borde superior visible sobre la barra existente, mediante DecoratedBox y separación de un píxel; conserva IndexedStack e índice de navegación |
| lib/app.dart y lib/main.dart | Incorporados del merge; introducción e inicialización simultáneas, sin sustituir el acceso real |
| lib/presentation/screens/intro/intro_screen.dart y assets/intro_screen/ | Incorporados y conservados; no se regeneraron imágenes |
| AuthGate y ProfileGate | Coordinación de destino listo recibida de main; se conservan sesión y perfil existentes |
| test/intro_test.dart | Se corrigió el helper que espera la carga: comprueba la animación de IntroScreen en lugar de cualquier callback transitorio |

## Verificación

Se reprodujo una inestabilidad de las nuevas pruebas de intro: una animación de perfil podía satisfacer la espera antes de que los PNG estuvieran listos. Se ajustó solo el helper para esperar el AnimationController de la intro, sin saltar pruebas ni alterar su resultado esperado.

Análisis sin incidencias y suite completa de 69 pruebas aprobadas. Se verifican arranque, intro, acceso, perfil, puzzle, recursos del historial, ambos modos locales y protocolo Wi-Fi. El APK debug y la vista web usan el JSON local ignorado; los cambios de esquema o credenciales Supabase no forman parte del merge.

Este merge se termina con un commit local solicitado por el usuario. No incluye publicación ni push. La prueba de dos Android en la misma Wi-Fi continúa pendiente y no queda certificada por la integración visual.
