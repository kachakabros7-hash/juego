extends Area2D

## HEART OF THE WORLD — Checkpoint

@export var identificador: String = "checkpoint"
@export var mensaje: String = "PUNTO DE CONTROL ACTIVADO"

var activado: bool = false
var fase: float = 0.0

func _ready() -> void:
	if not body_entered.is_connected(_on_body_entered):
		body_entered.connect(_on_body_entered)

	var escena_actual: String = ""
	if get_tree().current_scene != null:
		escena_actual = get_tree().current_scene.scene_file_path

	var misma_escena: bool = GameState.checkpoint_escena == escena_actual
	var misma_posicion: bool = GameState.checkpoint_posicion.distance_to(global_position) < 8.0
	if misma_escena and misma_posicion:
		activado = true
	queue_redraw()

func _process(delta: float) -> void:
	fase += delta
	queue_redraw()

func _draw() -> void:
	var pulso: float = 1.0 + sin(fase * 2.8) * 0.10
	var alpha_brillo: float = 0.22 if activado else 0.11
	var alpha_centro: float = 0.55 if activado else 0.42
	draw_circle(Vector2.ZERO, 42.0 * pulso, Color(0.18, 0.75, 1.0, alpha_brillo))
	draw_circle(Vector2.ZERO, 31.0, Color(0.18, 0.75, 1.0, alpha_centro))
	draw_circle(Vector2.ZERO, 20.0, Color(0.35, 0.9, 1.0, 0.92))
	draw_circle(Vector2.ZERO, 8.0, Color.WHITE)
	draw_line(Vector2(0, 20), Vector2(0, 48), Color(0.35, 0.9, 1.0, 0.65), 4.0)

func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return

	var escena: String = ""
	if get_tree().current_scene != null:
		escena = get_tree().current_scene.scene_file_path

	var mismo_checkpoint: bool = GameState.checkpoint_escena == escena
	var misma_posicion: bool = GameState.checkpoint_posicion.distance_to(global_position) < 8.0
	var ya_era_este: bool = mismo_checkpoint and misma_posicion

	GameState.activar_checkpoint(escena, global_position)
	GameState.vida_actual = GameState.vida_maxima

	if body.has_method("curar_desde_tienda"):
		body.curar_desde_tienda()
	elif body.has_method("curar_vida"):
		body.curar_vida(9999)

	if is_instance_valid(SaveManager):
		SaveManager.guardar_partida()

	if not ya_era_este or not activado:
		activado = true
		_mostrar_mensaje()
		queue_redraw()

func _mostrar_mensaje() -> void:
	var label: Label = Label.new()
	label.text = mensaje
	label.position = Vector2(-210, -86)
	label.size = Vector2(420, 48)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 20)
	label.add_theme_color_override("font_color", Color(0.78, 0.94, 1.0, 1.0))
	label.z_index = 20
	add_child(label)

	var tween: Tween = create_tween()
	tween.tween_interval(1.25)
	tween.tween_property(label, "modulate:a", 0.0, 0.45)
	tween.tween_callback(label.queue_free)
