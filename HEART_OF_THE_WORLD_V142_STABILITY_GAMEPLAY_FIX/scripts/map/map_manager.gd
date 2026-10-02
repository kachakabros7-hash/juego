extends CanvasLayer

## HEART OF THE WORLD — Map Manager (versión final pulida)

var mapa_abierto: bool = false
var overlay: Control
var display: Control
var minimapa: Control
var room_actual: String = ""
var _ultimo_numero_zonas: int = -1
var _ultimo_numero_habitaciones: int = -1

const ROOM_NAMES: Dictionary = {
	"bosque_entrada": "Bosque del Amanecer",
	"bosque_profundidad": "Raíces Profundas",
	"cavernas": "Cavernas Olvidadas",
	"bosque_sendero": "Minas Abandonadas",
	"bosque_santuario": "Ciudad Subterránea",
	"lago_oscuro": "Jardines Marchitos",
	"templo_antiguo": "Lago de las Sombras",
	"ciudad_perdida": "Templo Hundido",
	"pantano_sombrio": "Abismo",
	"torre_abismo": "Ciudad Antigua",
	"cueva_secreta": "Santuario",
	"jefe_guardian": "Corazón del Mundo"
}

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	layer = 90
	_crear_interfaz()


func _unhandled_input(event: InputEvent) -> void:
	if not event is InputEventKey or not event.pressed or event.echo:
		return
	var key := event as InputEventKey
	# ESC cierra el mapa grande antes que la pausa
	if mapa_abierto and (key.keycode == KEY_ESCAPE or key.physical_keycode == KEY_ESCAPE):
		_cerrar_mapa_interno()
		get_viewport().set_input_as_handled()
		return
	if key.is_action_pressed("mapa") or key.keycode == KEY_M:
		if mapa_abierto:
			_cerrar_mapa_interno()
		elif not get_tree().paused:
			_abrir_mapa()
		get_viewport().set_input_as_handled()


func _process(_delta: float) -> void:
	_actualizar_habitacion()


func _actualizar_habitacion() -> void:
	var escena: Node = get_tree().current_scene
	if escena == null:
		return

	var path: String = escena.scene_file_path
	if path.is_empty() or path.ends_with("main_menu.tscn"):
		_ocultar_minimapa()
		return

	var id: String = path.get_file().get_basename()
	var es_mini: bool = path.contains("/scenes/rooms/zonas/")
	if not ROOM_NAMES.has(id) and not es_mini:
		return

	var cambio_habitacion: bool = id != room_actual
	if cambio_habitacion:
		room_actual = id
		GameState.registrar_habitacion(id)
		var zona_id: String = id
		if es_mini:
			for posible in ROOM_NAMES.keys():
				if id.begins_with(str(posible) + "_") or id == str(posible):
					zona_id = str(posible)
					break
		if ROOM_NAMES.has(zona_id):
			GameState.registrar_zona(zona_id)
			GameState.aplicar_balance_zona(zona_id)
		if SaveManager:
			SaveManager.guardar_partida()

	var numero_zonas: int = GameState.zonas_descubiertas.size()
	var numero_habitaciones: int = GameState.habitaciones_descubiertas.size()
	var necesita: bool = cambio_habitacion \
			or numero_zonas != _ultimo_numero_zonas \
			or numero_habitaciones != _ultimo_numero_habitaciones

	if necesita:
		_ultimo_numero_zonas = numero_zonas
		_ultimo_numero_habitaciones = numero_habitaciones
		_refrescar_displays()

	if not mapa_abierto:
		_mostrar_minimapa()


func _refrescar_displays() -> void:
	if display and display.has_method("configurar") and mapa_abierto:
		display.configurar(
			room_actual,
			GameState.zonas_descubiertas,
			GameState.habitaciones_descubiertas,
			GameState.puertas_recordadas
		)
	if minimapa and minimapa.has_method("configurar_minimapa"):
		minimapa.configurar_minimapa(
			room_actual,
			GameState.zonas_descubiertas,
			GameState.habitaciones_descubiertas,
			GameState.puertas_recordadas
		)


func _crear_interfaz() -> void:
	overlay = Control.new()
	overlay.name = "MapOverlay"
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.visible = false
	overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	overlay.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(overlay)

	var fondo := ColorRect.new()
	fondo.color = Color(0.02, 0.015, 0.04, 0.90)
	fondo.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	fondo.mouse_filter = Control.MOUSE_FILTER_STOP
	overlay.add_child(fondo)

	var titulo := Label.new()
	titulo.text = "MAPA DEL CORAZÓN DEL MUNDO"
	titulo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	titulo.anchor_left = 0.0
	titulo.anchor_right = 1.0
	titulo.offset_top = 20
	titulo.offset_bottom = 60
	titulo.add_theme_font_size_override("font_size", 30)
	titulo.add_theme_color_override("font_color", Color(0.92, 0.88, 1.0, 1.0))
	overlay.add_child(titulo)

	var ayuda := Label.new()
	ayuda.text = "Rueda / +/- zoom · Clic medio arrastrar · C centrar · M o ESC cerrar"
	ayuda.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	ayuda.anchor_left = 0.0
	ayuda.anchor_right = 1.0
	ayuda.anchor_top = 1.0
	ayuda.anchor_bottom = 1.0
	ayuda.offset_top = -40
	ayuda.offset_bottom = -10
	ayuda.add_theme_font_size_override("font_size", 16)
	ayuda.add_theme_color_override("font_color", Color(0.75, 0.72, 0.9, 0.9))
	overlay.add_child(ayuda)

	display = _crear_display("MapDisplay")
	if display:
		display.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		display.offset_left = 60
		display.offset_top = 70
		display.offset_right = -60
		display.offset_bottom = -50
		overlay.add_child(display)

	minimapa = _crear_display("MinimapDisplay")
	if minimapa:
		minimapa.anchor_left = 1.0
		minimapa.anchor_right = 1.0
		minimapa.anchor_top = 0.0
		minimapa.anchor_bottom = 0.0
		minimapa.offset_left = -270
		minimapa.offset_right = -16
		minimapa.offset_top = 16
		minimapa.offset_bottom = 196
		minimapa.mouse_filter = Control.MOUSE_FILTER_IGNORE
		minimapa.visible = false
		add_child(minimapa)


func _crear_display(nombre: String) -> Control:
	var script_path := "res://scripts/map/map_display.gd"
	var nodo := Control.new()
	nodo.name = nombre
	if ResourceLoader.exists(script_path):
		nodo.set_script(load(script_path))
	else:
		nodo = ColorRect.new()
		nodo.name = nombre
		(nodo as ColorRect).color = Color(0.05, 0.04, 0.1, 0.75)
	return nodo


func _abrir_mapa() -> void:
	if mapa_abierto:
		return
	mapa_abierto = true
	if overlay:
		overlay.visible = true
	_ocultar_minimapa()
	_refrescar_displays()


func _cerrar_mapa_interno() -> void:
	mapa_abierto = false
	if overlay:
		overlay.visible = false
	_mostrar_minimapa()


func cerrar_mapa() -> void:
	_cerrar_mapa_interno()


func _mostrar_minimapa() -> void:
	if minimapa == null or mapa_abierto:
		_ocultar_minimapa()
		return
	var escena := get_tree().current_scene
	if escena == null or escena.scene_file_path.ends_with("main_menu.tscn"):
		_ocultar_minimapa()
		return
	minimapa.visible = true


func _ocultar_minimapa() -> void:
	if minimapa:
		minimapa.visible = false
