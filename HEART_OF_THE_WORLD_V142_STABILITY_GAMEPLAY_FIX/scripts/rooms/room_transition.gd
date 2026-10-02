extends Area2D

## HEART OF THE WORLD — Transición de sala
## Versión mejorada: más segura, anti-spam y clara.

@export_file("*.tscn") var escena_destino: String = ""
@export var spawn_destino: String = "PlayerSpawn"
@export_enum("Ninguna", "Impulso Espectral", "Garra Trepadora", "Embestida Cristalina", "Salto Celestial", "Bendición del Pantano", "Paso Umbrío", "Impulso de Raíz") var habilidad_requerida: String = "Ninguna"

const HABILIDADES: Dictionary = {
	"Impulso Espectral": "dash",
	"Garra Trepadora": "mantis_claw",
	"Embestida Cristalina": "crystal_heart",
	"Salto Celestial": "double_jump",
	"Bendición del Pantano": "isma_tear",
	"Paso Umbrío": "shade_cloak",
	"Impulso de Raíz": "root_burst"
}

var ocupado: bool = false
var mensaje_activo: bool = false
var barrera: StaticBody2D = null
var texto_bloqueo: Label = null

func _ready() -> void:
	collision_layer = 0
	collision_mask = 1
	if not body_entered.is_connected(_on_body_entered):
		body_entered.connect(_on_body_entered)
	if habilidad_requerida != "Ninguna":
		_crear_barrera()
		actualizar_barrera()


func _process(_delta: float) -> void:
	if habilidad_requerida != "Ninguna":
		actualizar_barrera()


func _habilidad_desbloqueada() -> bool:
	var id: String = str(HABILIDADES.get(habilidad_requerida, ""))
	return not id.is_empty() and GameState.tiene_habilidad(id)


func actualizar_barrera() -> void:
	if barrera == null:
		return
	var abierta: bool = _habilidad_desbloqueada()
	var forma: CollisionShape2D = barrera.get_node_or_null("CollisionShape2D") as CollisionShape2D
	if forma:
		forma.set_deferred("disabled", abierta)
	barrera.visible = not abierta
	if texto_bloqueo:
		texto_bloqueo.visible = not abierta


func _crear_barrera() -> void:
	barrera = StaticBody2D.new()
	barrera.name = "BloqueoHabilidad"
	barrera.collision_layer = 1
	barrera.collision_mask = 1
	add_child(barrera)

	var forma := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = Vector2(105.0, 280.0)
	forma.shape = shape
	barrera.add_child(forma)

	var visual := Polygon2D.new()
	visual.polygon = PackedVector2Array([
		Vector2(-52.0, -140.0), Vector2(52.0, -140.0),
		Vector2(52.0, 140.0), Vector2(-52.0, 140.0)
	])
	visual.color = Color(0.035, 0.018, 0.075, 0.88)
	barrera.add_child(visual)

	var borde := Line2D.new()
	borde.width = 6.0
	borde.closed = true
	borde.default_color = Color(0.55, 0.40, 0.78, 0.78)
	borde.points = PackedVector2Array([
		Vector2(-52.0, -140.0), Vector2(52.0, -140.0),
		Vector2(52.0, 140.0), Vector2(-52.0, 140.0)
	])
	barrera.add_child(borde)

	texto_bloqueo = Label.new()
	texto_bloqueo.text = "🔒 " + habilidad_requerida
	texto_bloqueo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	texto_bloqueo.position = Vector2(-90, -20)
	texto_bloqueo.size = Vector2(180, 40)
	texto_bloqueo.add_theme_font_size_override("font_size", 14)
	texto_bloqueo.add_theme_color_override("font_color", Color(0.9, 0.85, 1.0, 0.95))
	barrera.add_child(texto_bloqueo)


func _on_body_entered(body: Node2D) -> void:
	if ocupado or not body.is_in_group("player"):
		return
	if GameState.portales_bloqueados():
		return

	if habilidad_requerida != "Ninguna" and not _habilidad_desbloqueada():
		var escena_actual := get_tree().current_scene.scene_file_path.get_file().get_basename()
		var destino_id := escena_destino.get_file().get_basename()
		GameState.registrar_puerta_bloqueada(escena_actual + "->" + destino_id, habilidad_requerida)
		_mostrar_bloqueo(body)
		return

	if escena_destino.is_empty():
		push_warning("RoomTransition: destino vacío en %s" % get_path())
		return

	if not ResourceLoader.exists(escena_destino):
		push_error("RoomTransition: escena no existe → %s" % escena_destino)
		_mostrar_error_transicion()
		return

	ocupado = true
	GameState.punto_spawn = spawn_destino
	GameState.posicion_spawn = Vector2.ZERO
	GameState.bloquear_portales(1000)

	if SaveManager:
		SaveManager.guardar_partida()

	_iniciar_transicion()


func _iniciar_transicion() -> void:
	var capa := CanvasLayer.new()
	capa.name = "TransitionLayer"
	capa.layer = 200
	capa.process_mode = Node.PROCESS_MODE_ALWAYS
	get_tree().current_scene.add_child(capa)

	var fondo := ColorRect.new()
	fondo.color = Color(0.008, 0.006, 0.016, 0.0)
	fondo.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	fondo.mouse_filter = Control.MOUSE_FILTER_IGNORE
	capa.add_child(fondo)

	var tween := create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property(fondo, "color:a", 1.0, 0.22)
	tween.tween_callback(func() -> void:
		var resultado: Error = get_tree().change_scene_to_file(escena_destino)
		if resultado != OK:
			capa.queue_free()
			ocupado = false
			GameState.portales_bloqueados_hasta = 0
			push_error("Error al cambiar a: %s | código %d" % [escena_destino, resultado])
			_mostrar_error_transicion()
	)


func _mostrar_error_transicion() -> void:
	var escena := get_tree().current_scene
	if escena == null:
		return
	var aviso := Label.new()
	aviso.text = "NO SE PUDO CARGAR ESTA HABITACIÓN\nREGRESANDO..."
	aviso.position = Vector2(0.0, 440.0)
	aviso.size = Vector2(1920.0, 120.0)
	aviso.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	aviso.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	aviso.add_theme_font_size_override("font_size", 28)
	aviso.add_theme_color_override("font_color", Color(0.92, 0.86, 1.0, 0.98))
	aviso.z_index = 300
	escena.add_child(aviso)
	var t := create_tween()
	t.tween_interval(1.2)
	t.tween_property(aviso, "modulate:a", 0.0, 0.35)
	t.tween_callback(aviso.queue_free)


func _mostrar_bloqueo(body: Node2D) -> void:
	if mensaje_activo:
		return
	mensaje_activo = true

	var mensaje := Label.new()
	mensaje.text = "🔒 NECESITAS\n" + habilidad_requerida
	mensaje.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	mensaje.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	mensaje.position = Vector2(-260.0, -310.0)
	mensaje.size = Vector2(520.0, 110.0)
	mensaje.add_theme_font_size_override("font_size", 28)
	mensaje.add_theme_color_override("font_color", Color(0.94, 0.90, 1.0, 1.0))
	mensaje.z_index = 60
	body.add_child(mensaje)

	var tween := create_tween()
	tween.tween_interval(1.15)
	tween.tween_property(mensaje, "modulate:a", 0.0, 0.5)
	tween.tween_callback(mensaje.queue_free)
	tween.tween_callback(func(): mensaje_activo = false)
