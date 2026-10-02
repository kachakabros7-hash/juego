extends CanvasLayer

## Tutoriales cortos la primera vez que se desbloquea una habilidad.

const MENSAJES := {
	"double_jump": "DOBLE SALTO\nPulsa [ESPACIO] en el aire para un segundo salto.",
	"dash": "IMPULSO ESPECTRAL\nPulsa [SHIFT] para un dash rápido e invulnerable.",
	"mantis_claw": "GARRA TREPADORA\nEn una pared, mantén dirección y salta para rebotar.",
	"crystal_heart": "EMBESTIDA CRISTALINA\nMantén [G] para cargar y suelta para lanzarte.",
	"isma_tear": "LÁGRIMA DE ISMA\nYa puedes atravesar ácidos y líquidos peligrosos.",
	"shade_cloak": "PASO UMBRÍO\nPulsa [C] para atravesar enemigos un instante.",
	"root_burst": "IMPULSO DE RAÍZ\nEn el suelo, pulsa [V] para un salto vertical poderoso.",
}

var _panel: PanelContainer
var _label: Label
var _timer: Timer
var _mostrando: bool = false


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	layer = 110
	_crear_ui()
	if not GameState.habilidad_desbloqueada.is_connected(_on_habilidad):
		GameState.habilidad_desbloqueada.connect(_on_habilidad)


func _crear_ui() -> void:
	_panel = PanelContainer.new()
	_panel.name = "TutorialPanel"
	_panel.visible = false
	_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_panel.set_anchors_preset(Control.PRESET_CENTER_BOTTOM)
	_panel.offset_left = -320
	_panel.offset_right = 320
	_panel.offset_top = -180
	_panel.offset_bottom = -80
	add_child(_panel)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 20)
	margin.add_theme_constant_override("margin_right", 20)
	margin.add_theme_constant_override("margin_top", 14)
	margin.add_theme_constant_override("margin_bottom", 14)
	_panel.add_child(margin)

	_label = Label.new()
	_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_label.add_theme_font_size_override("font_size", 20)
	_label.add_theme_color_override("font_color", Color(0.95, 0.93, 1.0, 1.0))
	_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	margin.add_child(_label)

	_timer = Timer.new()
	_timer.one_shot = true
	_timer.timeout.connect(_ocultar)
	add_child(_timer)


func _on_habilidad(nombre: String) -> void:
	if GameState.tutoriales_vistos.get(nombre, false):
		return
	mostrar_habilidad(nombre)


func mostrar_habilidad(nombre: String) -> void:
	var texto: String = str(MENSAJES.get(nombre, "Nueva habilidad: %s" % nombre))
	mostrar(texto)
	GameState.tutoriales_vistos[nombre] = true


func mostrar(texto: String, duracion: float = 4.0) -> void:
	_label.text = texto
	_panel.visible = true
	_panel.modulate.a = 0.0
	_mostrando = true
	var tw := create_tween()
	tw.tween_property(_panel, "modulate:a", 1.0, 0.25)
	_timer.start(duracion)


func _ocultar() -> void:
	if not _mostrando:
		return
	var tw := create_tween()
	tw.tween_property(_panel, "modulate:a", 0.0, 0.35)
	tw.tween_callback(func():
		_panel.visible = false
		_mostrando = false
	)
