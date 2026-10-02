extends CanvasLayer

## HEART OF THE WORLD — Pause Manager
## Versión estable para Godot 4.7.
## No depende de funciones anónimas para evitar problemas de parseo.

var panel: ColorRect
var titulo: Label
var ayuda: Label
var boton_seguir: Button
var boton_salir: Button
var boton_guardar: Button
var dialogo_salir: ConfirmationDialog
var slider_musica: HSlider
var slider_sfx: HSlider
var label_musica: Label
var label_sfx: Label
var pausado: bool = false

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	layer = 100
	_crear_interfaz()
	_actualizar_interfaz()

func _unhandled_input(event: InputEvent) -> void:
	if not event is InputEventKey:
		return
	var key: InputEventKey = event as InputEventKey
	if not key.pressed or key.echo:
		return
	var es_escape: bool = key.keycode == KEY_ESCAPE or key.physical_keycode == KEY_ESCAPE
	var es_pausa: bool = key.is_action_pressed("pausa")
	if not es_escape and not es_pausa:
		return
	if dialogo_salir != null and dialogo_salir.visible:
		dialogo_salir.hide()
		get_viewport().set_input_as_handled()
		return
	var escena_actual: Node = get_tree().current_scene
	if escena_actual != null and escena_actual.scene_file_path.ends_with("main_menu.tscn"):
		return
	if MapManager != null and MapManager.has_method("cerrar_mapa") and bool(MapManager.get("mapa_abierto")):
		MapManager.cerrar_mapa()
		get_viewport().set_input_as_handled()
		return
	_alternar_pausa()
	get_viewport().set_input_as_handled()

func _alternar_pausa() -> void:
	pausado = not pausado
	get_tree().paused = pausado
	_actualizar_interfaz()

func _crear_interfaz() -> void:
	panel = ColorRect.new()
	panel.name = "PauseOverlay"
	panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	panel.color = Color(0.02, 0.02, 0.04, 0.86)
	panel.mouse_filter = Control.MOUSE_FILTER_STOP
	panel.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(panel)

	titulo = Label.new()
	titulo.text = "PAUSA"
	titulo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	titulo.set_anchors_preset(Control.PRESET_CENTER)
	titulo.position = Vector2(-300, -220)
	titulo.size = Vector2(600, 80)
	titulo.add_theme_font_size_override("font_size", 56)
	titulo.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.add_child(titulo)

	ayuda = Label.new()
	ayuda.text = "ESC para continuar"
	ayuda.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	ayuda.set_anchors_preset(Control.PRESET_CENTER)
	ayuda.position = Vector2(-300, -140)
	ayuda.size = Vector2(600, 40)
	ayuda.add_theme_font_size_override("font_size", 20)
	ayuda.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.add_child(ayuda)

	label_musica = Label.new()
	label_musica.text = "MÚSICA"
	label_musica.set_anchors_preset(Control.PRESET_CENTER)
	label_musica.position = Vector2(-200, -90)
	label_musica.size = Vector2(120, 28)
	label_musica.add_theme_font_size_override("font_size", 18)
	panel.add_child(label_musica)

	slider_musica = HSlider.new()
	slider_musica.min_value = 0.0
	slider_musica.max_value = 1.0
	slider_musica.step = 0.05
	slider_musica.value = 0.8
	slider_musica.set_anchors_preset(Control.PRESET_CENTER)
	slider_musica.position = Vector2(-60, -90)
	slider_musica.size = Vector2(260, 28)
	slider_musica.process_mode = Node.PROCESS_MODE_ALWAYS
	slider_musica.value_changed.connect(_on_musica)
	panel.add_child(slider_musica)

	label_sfx = Label.new()
	label_sfx.text = "EFECTOS"
	label_sfx.set_anchors_preset(Control.PRESET_CENTER)
	label_sfx.position = Vector2(-200, -50)
	label_sfx.size = Vector2(120, 28)
	label_sfx.add_theme_font_size_override("font_size", 18)
	panel.add_child(label_sfx)

	slider_sfx = HSlider.new()
	slider_sfx.min_value = 0.0
	slider_sfx.max_value = 1.0
	slider_sfx.step = 0.05
	slider_sfx.value = 0.9
	slider_sfx.set_anchors_preset(Control.PRESET_CENTER)
	slider_sfx.position = Vector2(-60, -50)
	slider_sfx.size = Vector2(260, 28)
	slider_sfx.process_mode = Node.PROCESS_MODE_ALWAYS
	slider_sfx.value_changed.connect(_on_sfx)
	panel.add_child(slider_sfx)

	boton_seguir = _boton("SEGUIR", Vector2(-150, 20), _seguir)
	boton_guardar = _boton("GUARDAR", Vector2(-150, 100), _guardar)
	boton_salir = _boton("SALIR AL MENÚ", Vector2(-150, 180), _abrir_confirmacion_salida)

	dialogo_salir = ConfirmationDialog.new()
	dialogo_salir.title = "SALIR DE LA PARTIDA"
	dialogo_salir.dialog_text = "¿Volver al menú principal?\nTu progreso se guardará."
	dialogo_salir.ok_button_text = "SALIR"
	dialogo_salir.cancel_button_text = "CANCELAR"
	dialogo_salir.process_mode = Node.PROCESS_MODE_ALWAYS
	dialogo_salir.confirmed.connect(_salir_al_menu)
	panel.add_child(dialogo_salir)

func _boton(texto: String, pos: Vector2, callback: Callable) -> Button:
	var boton: Button = Button.new()
	boton.text = texto
	boton.set_anchors_preset(Control.PRESET_CENTER)
	boton.position = pos
	boton.size = Vector2(300, 70)
	boton.add_theme_font_size_override("font_size", 26)
	boton.process_mode = Node.PROCESS_MODE_ALWAYS
	boton.pressed.connect(callback)
	panel.add_child(boton)
	return boton

func _on_musica(valor: float) -> void:
	if AudioManager != null and AudioManager.has_method("set_music_volume_linear"):
		AudioManager.set_music_volume_linear(valor)

func _on_sfx(valor: float) -> void:
	if AudioManager != null and AudioManager.has_method("set_sfx_volume_linear"):
		AudioManager.set_sfx_volume_linear(valor)

func _guardar() -> void:
	if SaveManager != null and SaveManager.has_method("guardar_partida"):
		SaveManager.guardar_partida()
	if ayuda != null:
		ayuda.text = "PARTIDA GUARDADA"
	get_tree().create_timer(1.2).timeout.connect(_restaurar_ayuda, CONNECT_ONE_SHOT)

func _restaurar_ayuda() -> void:
	if pausado and ayuda != null:
		ayuda.text = "ESC para continuar"

func _abrir_confirmacion_salida() -> void:
	if dialogo_salir != null:
		dialogo_salir.popup_centered(Vector2(520, 220))

func _salir_al_menu() -> void:
	pausado = false
	get_tree().paused = false
	if SaveManager != null and SaveManager.has_method("guardar_partida"):
		SaveManager.guardar_partida()
	if MapManager != null and MapManager.has_method("cerrar_mapa"):
		MapManager.cerrar_mapa()
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
	_actualizar_interfaz()

func _seguir() -> void:
	pausado = false
	get_tree().paused = false
	_actualizar_interfaz()

func _actualizar_interfaz() -> void:
	if panel != null:
		panel.visible = pausado
	var controles: Array[Control] = [
		boton_seguir,
		boton_guardar,
		boton_salir,
		slider_musica,
		slider_sfx,
		label_musica,
		label_sfx
	]
	for control in controles:
		if control != null:
			control.visible = pausado
	if pausado and boton_seguir != null:
		boton_seguir.grab_focus()
	if ayuda != null and pausado:
		ayuda.text = "ESC para continuar"
