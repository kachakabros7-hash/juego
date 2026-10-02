extends Node2D

## Primer encuentro narrativo: una criatura asustada, no un enemigo obligatorio.
@export var identificador: String = "eco_perdido_bosque_01"
@export var distancia_interaccion: float = 145.0
var jugador: Node2D
var panel: CanvasLayer
var cerca: bool = false

@onready var prompt: Label = get_node_or_null("Prompt") as Label

func _ready() -> void:
	if prompt:
		prompt.text = "E - ACERCARSE"
		prompt.visible = false
	if GameState.encuentro_resuelto(identificador):
		_actualizar_estado_final()

func _process(_delta: float) -> void:
	var p := get_tree().get_first_node_in_group("player") as Node2D
	jugador = p
	cerca = is_instance_valid(jugador) and global_position.distance_to(jugador.global_position) <= distancia_interaccion
	if prompt:
		prompt.visible = GameState.encuentro_resuelto(identificador) or (cerca and not is_instance_valid(panel))

func _unhandled_input(event: InputEvent) -> void:
	if cerca and not GameState.encuentro_resuelto(identificador) and event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_E:
		_mostrar_eleccion()
		get_viewport().set_input_as_handled()

func _mostrar_eleccion() -> void:
	if is_instance_valid(panel):
		return
	panel = CanvasLayer.new()
	panel.name = "EncuentroEcoPerdido"
	panel.layer = 31
	panel.process_mode = Node.PROCESS_MODE_ALWAYS
	get_tree().root.add_child(panel)
	var fondo := ColorRect.new()
	fondo.color = Color(0.01, 0.02, 0.04, 0.82)
	fondo.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	panel.add_child(fondo)
	var centro := CenterContainer.new()
	centro.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	fondo.add_child(centro)
	var caja := PanelContainer.new()
	caja.custom_minimum_size = Vector2(650, 290)
	centro.add_child(caja)
	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 12)
	caja.add_child(col)
	var texto := Label.new()
	texto.text = "ECO PERDIDO\n\nLa criatura tiembla y protege una pequeña luz.\n—No quería herir a nadie… el bosque me está borrando."
	texto.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	texto.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	col.add_child(texto)
	var escuchar := Button.new()
	escuchar.text = "Bajar el arma y escuchar"
	escuchar.pressed.connect(_resolver.bind("perdonada"))
	col.add_child(escuchar)
	var luchar := Button.new()
	luchar.text = "Acabar con la amenaza"
	luchar.pressed.connect(_resolver.bind("derrotada"))
	col.add_child(luchar)
	get_tree().paused = true
	escuchar.grab_focus()

func _resolver(resultado: String) -> void:
	GameState.registrar_encuentro(identificador, resultado)
	if resultado == "perdonada":
		GameState.registrar_memoria("eco_perdido_01")
	else:
		GameState.agregar_monedas(15)
	if has_node("/root/SaveManager"):
		SaveManager.guardar_partida()
	get_tree().paused = false
	if is_instance_valid(panel):
		panel.queue_free()
	panel = null
	_actualizar_estado_final()

func _actualizar_estado_final() -> void:
	if prompt:
		prompt.text = "ECO EN PAZ" if GameState.encuentros_resueltos.get(identificador, "") == "perdonada" else "ECO SILENCIADO"
		prompt.visible = true
