extends Area2D

## HEART OF THE WORLD — Tienda
## Versión mejorada: feedback más claro y segura.

@export var costo_vida: int = 25
@export var costo_dano: int = 50
@export var costo_dash: int = 40
@export var costo_curacion: int = 15

var jugador: Node2D = null
var panel: Panel
var monedas_label: Label
var mensaje_label: Label
var boton_vida: Button
var boton_dano: Button
var boton_dash: Button
var boton_curar: Button

func _ready() -> void:
	if not body_entered.is_connected(_on_body_entered):
		body_entered.connect(_on_body_entered)
	if not body_exited.is_connected(_on_body_exited):
		body_exited.connect(_on_body_exited)
	_crear_interfaz()
	panel.visible = false
	queue_redraw()


func _process(_delta: float) -> void:
	if panel and panel.visible:
		_actualizar_interfaz()
		if Input.is_action_just_pressed("pausa") or Input.is_key_pressed(KEY_ESCAPE):
			_cerrar()


func _draw() -> void:
	draw_circle(Vector2.ZERO, 52.0, Color(0.12, 0.08, 0.04, 0.95))
	draw_circle(Vector2.ZERO, 40.0, Color(0.85, 0.55, 0.12, 1.0))
	draw_circle(Vector2(0, -8), 17.0, Color(0.95, 0.78, 0.35, 1.0))
	draw_string(ThemeDB.fallback_font, Vector2(-90, 78), "COMERCIANTE", HORIZONTAL_ALIGNMENT_CENTER, 180, 18, Color.WHITE)


func _crear_interfaz() -> void:
	panel = Panel.new()
	panel.name = "TiendaPanel"
	panel.position = Vector2(560, 180)
	panel.size = Vector2(800, 700)
	panel.mouse_filter = Control.MOUSE_FILTER_STOP
	get_parent().call_deferred("add_child", panel)

	var titulo := Label.new()
	titulo.text = "TIENDA"
	titulo.position = Vector2(0, 25)
	titulo.size = Vector2(800, 60)
	titulo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	titulo.add_theme_font_size_override("font_size", 44)
	panel.add_child(titulo)

	monedas_label = Label.new()
	monedas_label.position = Vector2(30, 90)
	monedas_label.size = Vector2(740, 40)
	monedas_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	monedas_label.add_theme_font_size_override("font_size", 24)
	panel.add_child(monedas_label)

	boton_vida = _crear_boton("❤️  VIDA +25    —    %d MONEDAS" % costo_vida, Vector2(100, 155))
	boton_vida.pressed.connect(_comprar_vida)
	boton_dano = _crear_boton("⚔️  DAÑO +    —    %d MONEDAS" % costo_dano, Vector2(100, 245))
	boton_dano.pressed.connect(_comprar_dano)
	boton_dash = _crear_boton("💨  DASH +100    —    %d MONEDAS" % costo_dash, Vector2(100, 335))
	boton_dash.pressed.connect(_comprar_dash)
	boton_curar = _crear_boton("🧪  CURAR TODO    —    %d MONEDAS" % costo_curacion, Vector2(100, 425))
	boton_curar.pressed.connect(_comprar_curacion)

	mensaje_label = Label.new()
	mensaje_label.position = Vector2(40, 515)
	mensaje_label.size = Vector2(720, 55)
	mensaje_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	mensaje_label.add_theme_font_size_override("font_size", 20)
	panel.add_child(mensaje_label)

	var cerrar := Button.new()
	cerrar.text = "CERRAR  [ESC]"
	cerrar.position = Vector2(275, 590)
	cerrar.size = Vector2(250, 60)
	cerrar.add_theme_font_size_override("font_size", 24)
	cerrar.pressed.connect(_cerrar)
	panel.add_child(cerrar)


func _crear_boton(texto: String, pos: Vector2) -> Button:
	var b := Button.new()
	b.text = texto
	b.position = pos
	b.size = Vector2(600, 70)
	b.add_theme_font_size_override("font_size", 23)
	panel.add_child(b)
	return b


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		jugador = body
		panel.visible = true
		mensaje_label.text = "Elige una mejora. [ESC] o CERRAR para volver."
		_actualizar_interfaz()


func _on_body_exited(body: Node2D) -> void:
	if body == jugador:
		pass  # Se cierra solo con el botón o ESC


func _actualizar_interfaz() -> void:
	if monedas_label == null:
		return
	monedas_label.text = "MONEDAS: %d" % GameState.monedas
	if boton_vida:
		boton_vida.disabled = GameState.monedas < costo_vida
	if boton_dano:
		boton_dano.disabled = GameState.monedas < costo_dano
	if boton_dash:
		boton_dash.disabled = GameState.monedas < costo_dash
	if boton_curar:
		boton_curar.disabled = GameState.monedas < costo_curacion or jugador == null or not is_instance_valid(jugador)


func _comprar_vida() -> void:
	if not GameState.comprar_mejora("vida", costo_vida):
		_mostrar("No tienes suficientes monedas.")
		return
	if is_instance_valid(jugador) and jugador.has_method("aplicar_mejora_tienda"):
		jugador.aplicar_mejora_tienda("vida")
	_mostrar("¡Vida máxima aumentada!")
	_actualizar_interfaz()


func _comprar_dano() -> void:
	if not GameState.comprar_mejora("dano", costo_dano):
		_mostrar("No tienes suficientes monedas.")
		return
	if is_instance_valid(jugador) and jugador.has_method("aplicar_mejora_tienda"):
		jugador.aplicar_mejora_tienda("dano")
	_mostrar("¡Daño aumentado!")
	_actualizar_interfaz()


func _comprar_dash() -> void:
	if not GameState.comprar_mejora("dash", costo_dash):
		_mostrar("No tienes suficientes monedas.")
		return
	if is_instance_valid(jugador) and jugador.has_method("aplicar_mejora_tienda"):
		jugador.aplicar_mejora_tienda("dash")
	_mostrar("¡Dash mejorado!")
	_actualizar_interfaz()


func _comprar_curacion() -> void:
	if GameState.monedas < costo_curacion:
		_mostrar("No tienes suficientes monedas.")
		return
	GameState.monedas -= costo_curacion
	if is_instance_valid(jugador) and jugador.has_method("curar_desde_tienda"):
		jugador.curar_desde_tienda()
		_mostrar("¡Vida restaurada!")
	_actualizar_interfaz()


func _mostrar(texto: String) -> void:
	if mensaje_label:
		mensaje_label.text = texto


func _cerrar() -> void:
	if panel:
		panel.visible = false
