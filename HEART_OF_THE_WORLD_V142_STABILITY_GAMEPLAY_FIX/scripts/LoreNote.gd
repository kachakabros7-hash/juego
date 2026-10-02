extends Area2D

## HEART OF THE WORLD — Memoria del mundo
## Primer recuerdo: Bosque del Amanecer.

@export var identificador: String = "memoria_01"
@export var titulo: String = "MEMORIA 01"
@export_multiline var texto: String = "Misha despertó en el Bosque del Amanecer, bajo ramas que parecían inclinarse para escuchar.\n\nEn el suelo había un fragmento de luz. Al tocarlo, oyó un latido: Tum. Luego, una voz pequeña, casi una disculpa: «No quería hacerles daño».\n\nMisha no supo quién había hablado. Guardó el recuerdo, y por primera vez el silencio pareció estar esperando una respuesta."

var jugador_cerca := false
var prompt: Label
var tiempo := 0.0
var leyendo := false

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
	if leyendo:
		return
	if jugador_cerca and visible and Input.is_key_pressed(KEY_E):
		leer_memoria()
		get_viewport().set_input_as_handled()
	if is_instance_valid(prompt):
		prompt.visible = visible and jugador_cerca
	queue_redraw()

func actualizar_estado() -> void:
	if GameState.tiene_memoria(identificador):
		visible = false
		if is_instance_valid(prompt):
			prompt.visible = false

func crear_prompt() -> void:
	prompt = Label.new()
	prompt.name = "Prompt"
	prompt.position = Vector2(-90, 58)
	prompt.size = Vector2(180, 30)
	prompt.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	prompt.add_theme_font_size_override("font_size", 16)
	prompt.add_theme_color_override("font_color", Color(0.78, 0.92, 1.0, 1.0))
	prompt.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.9))
	prompt.add_theme_constant_override("shadow_offset_x", 2)
	prompt.add_theme_constant_override("shadow_offset_y", 2)
	prompt.text = "E - LEER"
	prompt.visible = false
	add_child(prompt)

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player") and visible:
		jugador_cerca = true
		prompt.visible = true

func _on_body_exited(body: Node) -> void:
	if body.is_in_group("player"):
		jugador_cerca = false
		prompt.visible = false

func leer_memoria() -> void:
	if leyendo or not visible:
		return
	leyendo = true
	GameState.registrar_memoria(identificador)
	if has_node("/root/SaveManager"):
		SaveManager.guardar_partida()

	var player := get_tree().get_first_node_in_group("player")
	if player != null and player.has_method("mostrar_mensaje"):
		player.mostrar_mensaje(titulo + " · RECUERDO DESCUBIERTO")
		await get_tree().create_timer(1.8).timeout
		mostrar_texto_en_hud(player)
	else:
		await get_tree().create_timer(0.2).timeout
	visible = false
	queue_free()

func mostrar_texto_en_hud(player: Node) -> void:
	if player == null:
		return
	var label := player.get_node_or_null("CanvasLayer/StatusLabel") as Label
	if label:
		label.text = titulo + "\n" + texto
		await get_tree().create_timer(6.0).timeout
	visible = false
	queue_free()

func _draw() -> void:
	if not visible:
		return
	var pulso := 1.0 + sin(tiempo * 2.5) * 0.08
	draw_circle(Vector2.ZERO, 26.0 * pulso, Color(0.35, 0.78, 1.0, 0.10))
	draw_circle(Vector2.ZERO, 14.0 * pulso, Color(0.55, 0.90, 1.0, 0.20))
	draw_circle(Vector2.ZERO, 5.0, Color(0.80, 0.97, 1.0, 0.90))
	draw_arc(Vector2.ZERO, 20.0 * pulso, -2.6, 0.6, 18, Color(0.65, 0.92, 1.0, 0.65), 2.0)
