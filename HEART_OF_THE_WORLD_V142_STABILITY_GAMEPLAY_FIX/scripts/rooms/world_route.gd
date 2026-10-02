extends Area2D

@export_file("*.tscn") var escena_destino: String = ""
@export var spawn_destino: String = "SpawnLeft"
@export_enum("Ninguna", "Impulso Espectral", "Garra Trepadora", "Embestida Cristalina", "Salto Celestial", "Bendición del Pantano", "Paso Umbrío", "Impulso de Raíz") var habilidad_requerida: String = "Ninguna"
@export var nombre_ruta: String = "SALIDA"

const HABILIDADES: Dictionary = {
	"Impulso Espectral": "dash",
	"Garra Trepadora": "mantis_claw",
	"Embestida Cristalina": "crystal_heart",
	"Salto Celestial": "double_jump",
	"Bendición del Pantano": "isma_tear",
	"Paso Umbrío": "shade_cloak",
	"Impulso de Raíz": "root_burst"
}

var bloqueado: bool = false
var etiqueta: Label

func _ready() -> void:
	collision_layer = 0
	collision_mask = 1
	body_entered.connect(_on_body_entered)
	queue_redraw()
	if habilidad_requerida != "Ninguna":
		_crear_etiqueta()

func _process(_delta: float) -> void:
	if etiqueta:
		etiqueta.visible = not _desbloqueada()

func _desbloqueada() -> bool:
	if habilidad_requerida == "Ninguna":
		return true
	return GameState.tiene_habilidad(str(HABILIDADES.get(habilidad_requerida, "")))

func _crear_etiqueta() -> void:
	etiqueta = Label.new()
	etiqueta.text = "🔒 " + habilidad_requerida
	etiqueta.position = Vector2(-180, -95)
	etiqueta.size = Vector2(360, 40)
	etiqueta.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	etiqueta.add_theme_font_size_override("font_size", 18)
	etiqueta.add_theme_color_override("font_color", Color(0.9, 0.86, 1.0, 0.95))
	etiqueta.z_index = 30
	add_child(etiqueta)

func _draw() -> void:
	draw_circle(Vector2.ZERO, 42.0, Color(0.35, 0.2, 0.75, 0.16))
	draw_circle(Vector2.ZERO, 30.0, Color(0.55, 0.35, 0.95, 0.22))
	draw_arc(Vector2.ZERO, 34.0, 0.0, TAU, 32, Color(0.72, 0.62, 1.0, 0.75), 3.0)
	draw_string(ThemeDB.fallback_font, Vector2(-100, 7), nombre_ruta, HORIZONTAL_ALIGNMENT_CENTER, 200, 15, Color(0.9, 0.86, 1.0, 0.9))

func _on_body_entered(body: Node2D) -> void:
	if bloqueado or not body.is_in_group("player"):
		return
	if Time.get_ticks_msec() < GameState.portales_bloqueados_hasta:
		return
	if not _desbloqueada():
		var escena_actual: String = get_tree().current_scene.scene_file_path.get_file().get_basename()
		var destino_id: String = escena_destino.get_file().get_basename()
		GameState.registrar_puerta_bloqueada(escena_actual + "->" + destino_id, habilidad_requerida)
		_mostrar_bloqueo(body)
		return
	if escena_destino.is_empty():
		return
	bloqueado = true
	GameState.punto_spawn = spawn_destino
	GameState.posicion_spawn = Vector2.ZERO
	GameState.bloquear_portales(900)
	if SaveManager != null:
		SaveManager.guardar_partida()
	var fade := CanvasLayer.new()
	fade.layer = 200
	fade.process_mode = Node.PROCESS_MODE_ALWAYS
	get_tree().current_scene.add_child(fade)
	var rect := ColorRect.new()
	rect.color = Color(0.01, 0.005, 0.02, 0.0)
	rect.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	fade.add_child(rect)
	var tween := create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property(rect, "color:a", 1.0, 0.18)
	tween.tween_callback(func() -> void:
		get_tree().change_scene_to_file(escena_destino)
	)

func _mostrar_bloqueo(body: Node2D) -> void:
	var msg := Label.new()
	msg.text = "🔒 NECESITAS\n" + habilidad_requerida
	msg.position = Vector2(-230, -190)
	msg.size = Vector2(460, 90)
	msg.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	msg.add_theme_font_size_override("font_size", 24)
	msg.add_theme_color_override("font_color", Color(0.95, 0.9, 1.0, 1.0))
	msg.z_index = 50
	body.add_child(msg)
	var tween := create_tween()
	tween.tween_interval(0.9)
	tween.tween_property(msg, "modulate:a", 0.0, 0.35)
	tween.tween_callback(msg.queue_free)
