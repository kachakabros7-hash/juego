MISHA: ADVENTURE - CATEGORIAS DE SCRIPTS

scripts/core/
- GameState.gd: estado global, vida, monedas, habilidades, checkpoints y progreso.

scripts/player/
- player.gd: movimiento, salto, dash, ataque, vida y respawn del jugador.

scripts/enemies/
- enemy_basic.gd: comportamiento base de enemigos.

scripts/map/
- map_manager.gd: abre/cierra y administra el mapa.
- map_display.gd: dibujo, zoom, desplazamiento y leyenda del mapa.

scripts/ui/
- main_menu.gd: menú principal.
- pause_manager.gd: pausa y menú de pausa.

scripts/rooms/
- room_transition.gd: transiciones entre habitaciones.
- room_exit.gd: script de salida antiguo/auxiliar.
- room_info.gd: información de habitación.
- checkpoint.gd: puntos de control.
- secret_zone.gd: zonas secretas.

scripts/items/
- cristal.gd: cristales coleccionables.
- habilidad_pickup.gd: recogida de habilidades.
- pocion.gd: pociones de curación.
- recompensa.gd: monedas/recompensas de enemigos.
- recompensa_especial.gd: cofres y fragmentos de vida.

scripts/shop/
- tienda.gd: tienda del Santuario y mejoras.

NOTA: se actualizaron las rutas res:// en escenas, proyecto y scripts para que Godot encuentre los archivos en sus nuevas carpetas.
