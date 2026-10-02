extends Node

## HEART OF THE WORLD — Sistemas de juego del jugador
## HUD de misión + inventario de pociones + uso con P.

var player: CharacterBody2D
var mission_label: Label
var potion_label: Label
var fragment_label: Label
var toast_label: Label
var toast_timer: float = 0.0

func _ready() -> void:
	player = get_parent() as CharacterBody2D
	crear_hud()
	if has_node("/root/MissionManager"):
		MissionManager.mision_cambiada.connect(_on_mision_cambiada)
		MissionManager.objetivo_actualizado.connect(_on_objetivo_actualizado)
	actualizar_hud()

func _process(delta: float) -> void:
	if toast_timer > 0.0:
		toast_timer -= delta
		if toast_timer <= 0.0 and is_instance_valid(toast_label):
			toast_label.visible = false
	if Input.is_action_just_pressed("usar_pocion"):
		usar_pocion()
	actualizar_hud()

func crear_hud() -> void:
	var canvas := player.get_node_or_null("CanvasLayer") as CanvasLayer
	if canvas == null:
		return
	mission_label = Label.new()
	mission_label.name = "MissionLabel"
	mission_label.position = Vector2(40, 270)
	mission_label.size = Vector2(760, 72)
	mission_label.add_theme_font_size_override("font_size", 18)
	mission_label.add_theme_color_override("font_color", Color(0.72, 0.9, 0.78, 0.98))
	mission_label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.85))
	mission_label.add_theme_constant_override("shadow_offset_x", 2)
	mission_label.add_theme_constant_override("shadow_offset_y", 2)
	canvas.add_child(mission_label)

	potion_label = Label.new()
	potion_label.name = "PotionLabel"
	potion_label.position = Vector2(40, 310)
	potion_label.size = Vector2(500, 38)
	potion_label.add_theme_font_size_override("font_size", 20)
	potion_label.add_theme_color_override("font_color", Color(0.7, 0.88, 1.0, 0.98))
	potion_label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.85))
	potion_label.add_theme_constant_override("shadow_offset_x", 2)
	potion_label.add_theme_constant_override("shadow_offset_y", 2)
	canvas.add_child(potion_label)

	fragment_label = Label.new()
	fragment_label.name = "HeartFragmentLabel"
	fragment_label.position = Vector2(40, 345)
	fragment_label.size = Vector2(500, 38)
	fragment_label.add_theme_font_size_override("font_size", 18)
	fragment_label.add_theme_color_override("font_color", Color(0.64, 0.88, 1.0, 0.98))
	fragment_label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.85))
	fragment_label.add_theme_constant_override("shadow_offset_x", 2)
	fragment_label.add_theme_constant_override("shadow_offset_y", 2)
	canvas.add_child(fragment_label)

	toast_label = Label.new()
	toast_label.name = "ToastLabel"
	toast_label.position = Vector2(40, 395)
	toast_label.size = Vector2(900, 50)
	toast_label.add_theme_font_size_override("font_size", 18)
	toast_label.add_theme_color_override("font_color", Color(1, 0.88, 0.6, 1))
	toast_label.visible = false
	canvas.add_child(toast_label)

func usar_pocion() -> void:
	if player == null or not is_instance_valid(player):
		return
	if not player.has_method("curar_vida"):
		return
	if player.esta_muerto:
		return
	if player.hp_actual >= player.hp_maxima:
		mostrar_mensaje("VIDA COMPLETA")
		return
	if GameState.usar_pocion():
		player.curar_vida(30)
		mostrar_mensaje("Poción usada · +30 VIDA")
	else:
		mostrar_mensaje("NO TIENES POCIONES")

func actualizar_hud() -> void:
	if is_instance_valid(potion_label):
		potion_label.text = "POCIONES: %d/%d  [P]" % [GameState.pociones, GameState.pociones_maximas]
	if is_instance_valid(fragment_label):
		fragment_label.text = "CORAZÓN: %d / 12 FRAGMENTOS" % GameState.cantidad_fragmentos_corazon()
	if is_instance_valid(mission_label) and has_node("/root/MissionManager"):
		if MissionManager.estado_actual == MissionManager.NO_INICIADA:
			mission_label.text = "MISIÓN: ECOS DEL BOSQUE · Habla con Luma para comenzar"
		else:
			mission_label.text = "MISIÓN: %s · %d/%d · %s" % [MissionManager.nombre_mision(), MissionManager.progreso, MissionManager.objetivo, MissionManager.estado_texto()]

func mostrar_mensaje(texto: String) -> void:
	if not is_instance_valid(toast_label):
		return
	toast_label.text = texto
	toast_label.visible = true
	toast_timer = 1.6

func _on_mision_cambiada(_id: String, _estado: int, _progreso: int, _objetivo: int) -> void:
	actualizar_hud()
	if MissionManager.estado_actual == MissionManager.ACTIVA:
		mostrar_mensaje("MISIÓN ACTIVA: ECOS DEL BOSQUE")
	elif MissionManager.estado_actual == MissionManager.COMPLETADA:
		mostrar_mensaje("MISIÓN COMPLETADA · REGRESA CON LUMA")

func _on_objetivo_actualizado(_progreso: int, _objetivo: int) -> void:
	actualizar_hud()
