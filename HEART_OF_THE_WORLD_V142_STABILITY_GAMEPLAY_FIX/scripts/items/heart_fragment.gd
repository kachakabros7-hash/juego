extends Area2D

## HEART OF THE WORLD — Fragmento del Corazón
## Primer fragmento: Bosque del Amanecer.
## Se desbloquea después de completar Ecos del Bosque y recibir la recompensa de Luma.

@export var identificador: String = "corazon_fragmento_01"
@export var nombre_fragmento: String = "FRAGMENTO DEL CORAZÓN"

var jugador_cerca: bool = false
var recogido: bool = false
var prompt: Label
var tiempo: float = 0.0

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	monitoring = true
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	crear_prompt()
	actualizar_estado()
	queue_redraw()

func _process(delta: float) -> void:
	tiempo += delta
	actualizar_estado()
	queue_redraw()

	if jugador_cerca and Input.is_key_pressed(KEY_E) and not recogido:
		recoger()
		get_viewport().set_input_as_handled()

func actualizar_estado() -> void:
	if recogido:
		visible = false
		return

	# El fragmento aparece cuando la primera misión fue terminada y Luma entregó la recompensa.
	var desbloqueado := false
	if has_node("/root/MissionManager"):
		desbloqueado = MissionManager.estado_actual == MissionManager.COMPLETADA and not MissionManager.recompensa_pendiente

	if GameState.tiene_fragmento_corazon(identificador):
		recogido = true
		visible = false
		return

	visible = desbloqueado
	if is_instance_valid(prompt):
		prompt.visible = visible and jugador_cerca

func crear_prompt() -> void:
	prompt = Label.new()
	prompt.name = "Prompt"
	prompt.position = Vector2(-90, 72)
	prompt.size = Vector2(180, 32)
	prompt.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	prompt.add_theme_font_size_override("font_size", 16)
	prompt.add_theme_color_override("font_color", Color(0.82, 0.95, 1.0, 1.0))
	prompt.add_theme_color_override("font_shadow_color", Color(0.02, 0.04, 0.08, 0.95))
	prompt.add_theme_constant_override("shadow_offset_x", 2)
	prompt.add_theme_constant_override("shadow_offset_y", 2)
	prompt.text = "E - RECOGER"
	prompt.visible = false
	add_child(prompt)

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		jugador_cerca = true
		if is_instance_valid(prompt):
			prompt.visible = visible

func _on_body_exited(body: Node) -> void:
	if body.is_in_group("player"):
		jugador_cerca = false
		if is_instance_valid(prompt):
			prompt.visible = false

func recoger() -> void:
	if recogido or not visible:
		return

	recogido = true
	GameState.registrar_fragmento_corazon(identificador)
	visible = false
	if is_instance_valid(prompt):
		prompt.visible = false

	# Guardado inmediato para no perder un fragmento importante.
	if has_node("/root/SaveManager"):
		SaveManager.guardar_partida()

	var player := get_tree().get_first_node_in_group("player")
	if player != null and player.has_method("mostrar_mensaje"):
		player.mostrar_mensaje("FRAGMENTO DEL CORAZÓN OBTENIDO")
	elif player != null:
		var label := player.get_node_or_null("CanvasLayer/StatusLabel") as Label
		if label:
			label.text = "FRAGMENTO DEL CORAZÓN OBTENIDO"

	queue_free()

func _draw() -> void:
	if not visible:
		return
	var pulso := 1.0 + sin(tiempo * 3.0) * 0.08
	var brillo := 0.20 + (sin(tiempo * 3.0) + 1.0) * 0.08
	draw_circle(Vector2.ZERO, 46.0 * pulso, Color(0.32, 0.72, 1.0, brillo))
	draw_circle(Vector2.ZERO, 25.0 * pulso, Color(0.55, 0.90, 1.0, 0.28))
	var puntos := PackedVector2Array([
		Vector2(0, -22), Vector2(18, -6), Vector2(11, 20), Vector2(0, 29),
		Vector2(-11, 20), Vector2(-18, -6)
	])
	draw_colored_polygon(puntos, Color(0.68, 0.94, 1.0, 0.95))
	draw_polyline(PackedVector2Array([Vector2(0,-22), Vector2(18,-6), Vector2(11,20), Vector2(0,29), Vector2(-11,20), Vector2(-18,-6), Vector2(0,-22)]), Color(0.9, 1.0, 1.0, 0.9), 2.0)
