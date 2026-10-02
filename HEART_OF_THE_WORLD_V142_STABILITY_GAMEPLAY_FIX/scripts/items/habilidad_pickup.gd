extends Area2D

@export_enum("double_jump", "dash", "mantis_claw", "crystal_heart", "isma_tear", "shade_cloak", "root_burst") var habilidad: String = "double_jump"
@export var nombre_habilidad: String = "SALTO CELESTIAL"
@export_multiline var descripcion: String = "Permite saltar una segunda vez en el aire."

var recogida: bool = false
var tiempo: float = 0.0

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	queue_redraw()

	if GameState.tiene_habilidad(habilidad):
		queue_free()

func _process(delta: float) -> void:
	tiempo += delta
	queue_redraw()

func _draw() -> void:
	var pulso: float = 1.0 + sin(tiempo * 4.0) * 0.08
	draw_circle(Vector2.ZERO, 32.0 * pulso, Color(0.15, 0.9, 1.0, 0.18))
	draw_circle(Vector2.ZERO, 22.0 * pulso, Color(0.15, 0.8, 1.0, 0.8))
	draw_circle(Vector2.ZERO, 13.0, Color(0.8, 1.0, 1.0, 1.0))
	draw_string(ThemeDB.fallback_font, Vector2(-110, -45), "HABILIDAD", HORIZONTAL_ALIGNMENT_CENTER, 220, 18, Color(0.8, 0.95, 1.0))
	draw_string(ThemeDB.fallback_font, Vector2(-130, 55), nombre_habilidad, HORIZONTAL_ALIGNMENT_CENTER, 260, 22, Color.WHITE)

func _on_body_entered(body: Node2D) -> void:
	if recogida or not body.is_in_group("player"):
		return
	if GameState.tiene_habilidad(habilidad):
		return

	recogida = true
	GameState.obtener_habilidad(habilidad)

	if habilidad == "double_jump" and body.has_method("desbloquear_doble_salto"):
		body.desbloquear_doble_salto()
	elif habilidad == "dash" and body.has_method("desbloquear_dash"):
		body.desbloquear_dash()
	elif habilidad == "root_burst" and body.has_method("desbloquear_impulso_raiz"):
		body.desbloquear_impulso_raiz()

	_crear_mensaje(body)
	queue_free()

func _crear_mensaje(body: Node2D) -> void:
	var mensaje: Label = Label.new()
	mensaje.text = "¡HABILIDAD DESBLOQUEADA!\n" + nombre_habilidad + "\n" + descripcion
	mensaje.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	mensaje.position = Vector2(-280, -180)
	mensaje.size = Vector2(560, 120)
	mensaje.add_theme_font_size_override("font_size", 24)
	mensaje.z_index = 50
	body.add_child(mensaje)
	var tween: Tween = create_tween()
	tween.tween_property(mensaje, "modulate:a", 0.0, 2.4).set_delay(1.2)
	tween.tween_callback(mensaje.queue_free)
