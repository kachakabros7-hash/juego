extends CanvasLayer

## HEART OF THE WORLD — Dialogue UI
## E / ESPACIO avanza. ESC también cierra al terminar.

var nombre: String = ""
var lineas: Array[String] = []
var indice: int = 0
var callback_inicio: Callable = Callable()
var callback_final: Callable = Callable()
var escribiendo: bool = false
var texto_visible: String = ""
var caracter: int = 0
var velocidad_texto: float = 0.018
var tiempo: float = 0.0

@onready var panel: Panel = $Panel
@onready var nombre_label: Label = $Panel/NombreNPC
@onready var texto_label: Label = $Panel/TextoDialogo
@onready var indicador: Label = $Panel/IndicadorContinuar

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	panel.visible = true
	indicador.text = "E / ESPACIO"

func iniciar(nombre_npc: String, nuevas_lineas: Array[String], al_iniciar: Callable = Callable(), al_terminar: Callable = Callable()) -> void:
	nombre = nombre_npc
	lineas = nuevas_lineas
	indice = 0
	callback_inicio = al_iniciar
	callback_final = al_terminar
	get_tree().paused = true
	if is_instance_valid(nombre_label):
		nombre_label.text = nombre
	mostrar_linea()

func _process(delta: float) -> void:
	if escribiendo:
		tiempo += delta
		while tiempo >= velocidad_texto and caracter < texto_visible.length():
			tiempo -= velocidad_texto
			caracter += 1
			texto_label.text = texto_visible.substr(0, caracter)
		if caracter >= texto_visible.length():
			escribiendo = false
			indicador.visible = true

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_E or event.keycode == KEY_SPACE:
			avanzar()
			get_viewport().set_input_as_handled()
		elif event.keycode == KEY_ESCAPE and not escribiendo:
			cerrar()
			get_viewport().set_input_as_handled()

func mostrar_linea() -> void:
	if indice >= lineas.size():
		cerrar()
		return
	texto_visible = lineas[indice]
	caracter = 0
	tiempo = 0.0
	escribiendo = true
	indicador.visible = false
	texto_label.text = ""

func avanzar() -> void:
	if escribiendo:
		caracter = texto_visible.length()
		texto_label.text = texto_visible
		escribiendo = false
		indicador.visible = true
		return
	indice += 1
	if indice >= lineas.size():
		cerrar()
	else:
		mostrar_linea()

func cerrar() -> void:
	if callback_inicio.is_valid():
		var cb := callback_inicio
		callback_inicio = Callable()
		cb.call()
	if callback_final.is_valid():
		var cb_final := callback_final
		callback_final = Callable()
		cb_final.call()
	get_tree().paused = false
	queue_free()
