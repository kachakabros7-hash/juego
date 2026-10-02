extends Area2D

@export_file("*.tscn") var siguiente_habitacion: String
@export var spawn_destino: String = "PlayerSpawn"

var puede_cambiar: bool = true


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	if not puede_cambiar:
		return

	if not body.is_in_group("player"):
		return

	if siguiente_habitacion.is_empty():
		push_warning("Exit sin habitación asignada.")
		return

	puede_cambiar = false

	# Guardamos el nombre del punto donde aparecerá Misha.
	GameState.punto_spawn = spawn_destino

	# Cambiamos de habitación.
	get_tree().change_scene_to_file(siguiente_habitacion)
	
