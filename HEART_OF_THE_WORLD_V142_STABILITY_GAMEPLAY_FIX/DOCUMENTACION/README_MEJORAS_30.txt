MISHA: HOLLOW REALM - VERSION 30

Mejoras aplicadas:
- Restaurado y reforzado el sistema de transiciones entre habitaciones.
- Añadida transición visual de entrada/salida.
- Corregida la cámara del jugador para seguir a Misha correctamente.
- Reforzado el orden visual del personaje para evitar que desaparezca detrás del escenario.
- Añadida capa visual del personaje con sombra y efectos suaves para dash, capa sombría y embestida cristalina.
- Renovada la capa de ambientación de habitaciones con detalles diferentes por región.
- Eliminadas dependencias problemáticas de Color.with_alpha().
- Reducidas inferencias Variant en sistemas de estado y guardado.
- Guardado actualizado a versión 2 y endurecido contra datos inválidos.
- Eliminada una asignación duplicada del dash en el jugador.
- Conservadas las 60 habitaciones y la progresión existente.
- Conservadas las habilidades, enemigos, recompensas, checkpoints, mapa, tienda y guardado.

VALIDACION ESTATICA:
- 60 escenas de habitaciones detectadas.
- 60 habitaciones con PlayerSpawn.
- 60 habitaciones con RoomPolish.
- Destinos de escenas verificados contra archivos existentes.
- Player.tscn mantiene AnimatedSprite2D, colisiones, AreaAtaque, HUD y Camera2D.

IMPORTANTE:
Godot 4.7.1 no esta instalado en el entorno de construccion, por lo que la validacion realizada es estatica. El proyecto debe abrirse en Godot 4.7.x para la prueba de ejecucion.
