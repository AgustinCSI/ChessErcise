# 16 · Rutina del puzzle diario

Al finalizar el intento, resuelto o por rendición, el resumen calcula `errores × 5 + pistas usadas × 2` repeticiones. Por ejemplo, dos errores y una pista producen doce repeticiones. Se mantiene la regla existente de contar una pista una sola vez por paso; tocar varias veces la bombilla en ese paso no añade penalizaciones. Rendirse no añade una penalización adicional.

La rutina utiliza los nombres e ilustraciones de `RetoLocal.catalogo`. Se propone Sentadillas y se puede elegir cualquiera de los seis ejercicios por repeticiones. Las planchas y el trote se excluyen porque su unidad es segundos. El total corresponde al ejercicio elegido; no se multiplica por el número de ejercicios del catálogo. Con cero repeticiones se muestra que no hay ejercicios pendientes.

Listo confirma manualmente la rutina. El ejercicio elegido y su confirmación se guardan junto al progreso local del puzzle, separados por cuenta y puzzle. Reabrir el resumen conserva la confirmación. El resultado de ajedrez queda sellado: actualizar la rutina no permite cambiar errores, pistas, rendición ni movimientos. Los intentos anteriores siguen siendo legibles y toman Sentadillas como opción inicial.

La interfaz conserva la revisión del tablero y permite salir con una rutina pendiente; al volver se recupera su estado. No requiere dependencias, tablas ni cambios de configuración.

## Código

- `models/progreso_puzzle.dart`: cálculo y datos de la rutina, JSON compatible con guardados anteriores.
- `presentation/providers/puzzles_provider.dart`: actualización de rutina solo para intentos finalizados; reutiliza la cola de guardado y sus avisos de error/reintento.
- `presentation/widgets/puzzle_routine.dart`: ilustración, desglose, selector y confirmación.
- `presentation/screens/puzzles/puzzle_summary_screen.dart`: incluye la rutina en el resumen.
- `test/puzzle_persistence_test.dart`: cálculo, compatibilidad, rendición, protección del resultado, persistencia por cuenta y selección/confirmación en pantalla de teléfono.

## Verificación

`flutter analyze` sin incidencias; `flutter test` con 80 pruebas aprobadas. La prueba de selección y confirmación usa una pantalla de 390 × 844. No se hizo stage, commit ni push.
