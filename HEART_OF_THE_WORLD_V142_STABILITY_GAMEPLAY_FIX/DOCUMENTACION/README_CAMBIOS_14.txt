MISHA: ADVENTURE — CAMBIOS 14

- Menú de pausa: botón SALIR AL MENÚ.
- Confirmación antes de abandonar la partida.
- Al salir desde pausa se limpia GameState para empezar una nueva partida correctamente.
- El mapa se cierra al volver al menú.
- Se eliminó una referencia duplicada de checkpoint.gd en Templo Antiguo.
- Se limpió una llamada redundante de anclaje del MapDisplay.
- Se reforzaron tipos explícitos en map_display.gd para evitar errores de inferencia de GDScript.
- Mejora de muerte: si existe checkpoint, ahora respawnea incluso si está en otra habitación; sin checkpoint, reinicia la sala actual con vida completa.

Validación realizada: estructura de archivos y ZIP. No se ejecutó Godot en este entorno, por lo que no se declara una prueba de ejecución.
