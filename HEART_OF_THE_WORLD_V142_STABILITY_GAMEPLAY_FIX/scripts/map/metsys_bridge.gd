extends Node

## HEART OF THE WORLD — Puente seguro con MetSys
## MetSys se usa como capa de mapa/seguimiento; no reemplaza GameState ni MapManager.

var _inicializado: bool = false

func _ready() -> void:
	if Engine.is_editor_hint():
		return
	call_deferred("_inicializar")
	if SaveManager and SaveManager.has_signal("partida_cargada"):
		SaveManager.partida_cargada.connect(_programar_sincronizacion)

func _inicializar() -> void:
	if not is_instance_valid(MetSys):
		return
	MetSys.reset_state()
	MetSys.set_save_data({})
	_inicializado = true
	_sincronizar_desde_gamestate()

func _programar_sincronizacion() -> void:
	call_deferred("_sincronizar_desde_gamestate")

func _sincronizar_desde_gamestate() -> void:
	if not _inicializado or not is_instance_valid(MetSys):
		return
	# Reaplica al mapa de MetSys las habitaciones que GameState ya conocía.
	# GameState sigue siendo la fuente de verdad del guardado.
	for nombre in GameState.habitaciones_descubiertas.keys():
		var id := str(nombre)
		for ruta in MetSys.map_data.assigned_scenes.keys():
			var escena := str(ruta).get_file().get_basename()
			if escena == id:
				for celda in MetSys.map_data.get_cells_assigned_to(str(ruta)):
					if celda in MetSys.map_data.cells:
						MetSys.discover_cell(celda)
				break

func _physics_process(_delta: float) -> void:
	if not _inicializado or not is_instance_valid(MetSys):
		return
	var player := get_tree().get_first_node_in_group("player")
	if not player is Node2D:
		return
	# MetSys necesita la posición del jugador en coordenadas de la sala actual.
	MetSys.set_player_position((player as Node2D).global_position)
