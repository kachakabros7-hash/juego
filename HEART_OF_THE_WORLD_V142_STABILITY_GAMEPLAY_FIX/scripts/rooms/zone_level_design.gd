extends Node2D
## V70 - Capas de diseño jugable para las 12 zonas.
## Añade rutas elevadas, desafíos de habilidad y puertas bloqueadas sin sustituir la geometría existente.

const PLATFORM_COLOR := Color(0.30, 0.55, 0.78, 0.34)
const SPECIAL_COLOR := Color(0.68, 0.42, 0.92, 0.40)
const GATE_COLOR := Color(0.80, 0.55, 0.95, 0.28)

var layouts: Dictionary = {
	"bosque_entrada": [
		[Vector2(900, 930), Vector2(460, 42)], [Vector2(1540, 720), Vector2(380, 42)],
		[Vector2(2380, 610), Vector2(360, 42)], [Vector2(3050, 790), Vector2(420, 42)],
		[Vector2(3650, 560), Vector2(360, 42)]
	],
	"bosque_sendero": [
		[Vector2(700, 1120), Vector2(400, 42)], [Vector2(1250, 900), Vector2(360, 42)],
		[Vector2(1900, 700), Vector2(340, 42)], [Vector2(2500, 520), Vector2(360, 42)],
		[Vector2(3350, 420), Vector2(360, 42)], [Vector2(4300, 610), Vector2(400, 42)],
		[Vector2(5000, 780), Vector2(360, 42)]
	],
	"bosque_profundidad": [
		[Vector2(520, 4200), Vector2(360, 42)], [Vector2(980, 3750), Vector2(330, 42)],
		[Vector2(1500, 3300), Vector2(360, 42)], [Vector2(1050, 2850), Vector2(330, 42)],
		[Vector2(1750, 2450), Vector2(360, 42)], [Vector2(1050, 2050), Vector2(330, 42)],
		[Vector2(1750, 1650), Vector2(360, 42)], [Vector2(1200, 1200), Vector2(360, 42)],
		[Vector2(1900, 850), Vector2(360, 42)]
	],
	"bosque_santuario": [
		[Vector2(650, 1900), Vector2(360, 42)], [Vector2(1150, 1600), Vector2(360, 42)],
		[Vector2(1650, 1300), Vector2(360, 42)], [Vector2(2150, 1000), Vector2(360, 42)],
		[Vector2(2700, 1300), Vector2(360, 42)], [Vector2(3250, 1600), Vector2(360, 42)],
		[Vector2(3750, 1250), Vector2(320, 42)]
	],
	"lago_oscuro": [
		[Vector2(650, 1450), Vector2(360, 42)], [Vector2(1150, 1200), Vector2(340, 42)],
		[Vector2(1650, 950), Vector2(340, 42)], [Vector2(2200, 750), Vector2(360, 42)],
		[Vector2(2750, 950), Vector2(340, 42)], [Vector2(3250, 720), Vector2(360, 42)],
		[Vector2(3800, 900), Vector2(360, 42)], [Vector2(2200, 1850), Vector2(420, 42)]
	],
	"templo_antiguo": [
		[Vector2(600, 1950), Vector2(360, 42)], [Vector2(1100, 1650), Vector2(360, 42)],
		[Vector2(1600, 1350), Vector2(360, 42)], [Vector2(2200, 1050), Vector2(360, 42)],
		[Vector2(2800, 1350), Vector2(360, 42)], [Vector2(3350, 1050), Vector2(360, 42)],
		[Vector2(3900, 1350), Vector2(360, 42)], [Vector2(4250, 1600), Vector2(300, 42)]
	],
	"ciudad_perdida": [
		[Vector2(550, 2200), Vector2(400, 42)], [Vector2(1150, 1850), Vector2(360, 42)],
		[Vector2(1750, 1550), Vector2(360, 42)], [Vector2(2400, 1250), Vector2(400, 42)],
		[Vector2(3050, 950), Vector2(360, 42)], [Vector2(3700, 1250), Vector2(360, 42)],
		[Vector2(4350, 900), Vector2(380, 42)], [Vector2(2400, 550), Vector2(420, 42)]
	],
	"pantano_sombrio": [
		[Vector2(500, 2350), Vector2(400, 42)], [Vector2(1050, 2050), Vector2(360, 42)],
		[Vector2(1550, 1700), Vector2(360, 42)], [Vector2(2100, 1350), Vector2(380, 42)],
		[Vector2(2650, 1050), Vector2(360, 42)], [Vector2(3200, 1350), Vector2(360, 42)],
		[Vector2(3750, 1000), Vector2(360, 42)], [Vector2(4300, 700), Vector2(360, 42)]
	],
	"torre_abismo": [
		[Vector2(600, 1050), Vector2(360, 42)], [Vector2(1100, 820), Vector2(330, 42)],
		[Vector2(1600, 590), Vector2(330, 42)], [Vector2(2100, 360), Vector2(360, 42)],
		[Vector2(2600, 590), Vector2(330, 42)], [Vector2(3100, 820), Vector2(330, 42)],
		[Vector2(3600, 590), Vector2(330, 42)]
	],
	"jefe_guardian": [
		[Vector2(650, 1030), Vector2(360, 42)], [Vector2(1250, 800), Vector2(330, 42)],
		[Vector2(1900, 580), Vector2(330, 42)], [Vector2(2550, 800), Vector2(330, 42)],
		[Vector2(3200, 1030), Vector2(360, 42)], [Vector2(2100, 400), Vector2(420, 42)]
	],
	"cavernas": [
		[Vector2(650, 900), Vector2(360, 42)], [Vector2(1150, 650), Vector2(330, 42)],
		[Vector2(1650, 420), Vector2(330, 42)], [Vector2(2200, 650), Vector2(360, 42)],
		[Vector2(2750, 420), Vector2(330, 42)], [Vector2(3250, 650), Vector2(360, 42)],
		[Vector2(3700, 900), Vector2(330, 42)]
	],
	"cueva_secreta": [
		[Vector2(600, 1000), Vector2(360, 42)], [Vector2(1150, 760), Vector2(330, 42)],
		[Vector2(1700, 520), Vector2(330, 42)], [Vector2(2250, 760), Vector2(330, 42)],
		[Vector2(2800, 520), Vector2(330, 42)], [Vector2(3350, 760), Vector2(360, 42)]
	]
}

var gates: Dictionary = {
	"bosque_entrada": [[3500, 1050, "Salto Celestial"]],
	"bosque_sendero": [[3050, 360, "Impulso Espectral"]],
	"bosque_profundidad": [[1450, 4600, "Impulso Espectral"]],
	"bosque_santuario": [[900, 1800, "Garra Trepadora"], [4100, 1500, "Impulso Espectral"]],
	"lago_oscuro": [[950, 1450, "Garra Trepadora"], [3600, 850, "Embestida Cristalina"]],
	"templo_antiguo": [[4000, 900, "Impulso Espectral"]],
	"ciudad_perdida": [[2400, 600, "Impulso Espectral"]],
	"pantano_sombrio": [[4300, 750, "Bendición del Pantano"]],
	"torre_abismo": [[2100, 400, "Paso Umbrío"]],
	"jefe_guardian": [[3500, 1050, "Paso Umbrío"]],
	"cavernas": [[3000, 500, "Garra Trepadora"]],
	"cueva_secreta": [[2250, 760, "Embestida Cristalina"]]
}

func _ready() -> void:
	var key := _zone_key()
	if layouts.has(key):
		var objects := get_parent().get_node_or_null("Objects")
		var has_explicit_platforms := false
		if objects != null:
			has_explicit_platforms = objects.get_node_or_null("Platform01") != null
		if not has_explicit_platforms:
			for data in layouts[key]:
				_crear_plataforma(Vector2(data[0]), Vector2(data[1]), false)
	if gates.has(key):
		for gate_data in gates[key]:
			_crear_puerta(Vector2(gate_data[0], gate_data[1]), str(gate_data[2]))
	_crear_instruccion(key)

func _zone_key() -> String:
	var scene := get_tree().current_scene.scene_file_path
	return scene.get_file().get_basename()

func _crear_plataforma(pos: Vector2, size: Vector2, especial: bool) -> void:
	var body := StaticBody2D.new()
	body.position = pos
	body.collision_layer = 1
	body.collision_mask = 0
	body.name = "V70_Plataforma"
	var shape := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = size
	shape.shape = rect
	body.add_child(shape)
	var poly := Polygon2D.new()
	poly.polygon = PackedVector2Array([
		Vector2(-size.x * 0.5, -size.y * 0.5), Vector2(size.x * 0.5, -size.y * 0.5),
		Vector2(size.x * 0.5, size.y * 0.5), Vector2(-size.x * 0.5, size.y * 0.5)
	])
	poly.color = SPECIAL_COLOR if especial else PLATFORM_COLOR
	body.add_child(poly)
	add_child(body)

func _crear_puerta(pos: Vector2, habilidad: String) -> void:
	var root := Node2D.new()
	root.position = pos
	root.name = "V70_Puerta_" + habilidad.replace(" ", "_")
	add_child(root)
	var barrier := StaticBody2D.new()
	barrier.collision_layer = 1
	barrier.collision_mask = 0
	barrier.name = "Barrera"
	var shape := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = Vector2(90, 260)
	shape.shape = rect
	barrier.add_child(shape)
	root.add_child(barrier)
	var poly := Polygon2D.new()
	poly.polygon = PackedVector2Array([Vector2(-45,-130), Vector2(45,-130), Vector2(45,130), Vector2(-45,130)])
	poly.color = GATE_COLOR
	root.add_child(poly)
	var label := Label.new()
	label.text = "🔒 " + habilidad
	label.position = Vector2(-150, -175)
	label.size = Vector2(300, 45)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 17)
	root.add_child(label)
	var timer := Timer.new()
	timer.wait_time = 0.35
	timer.autostart = true
	timer.timeout.connect(func() -> void:
		var unlocked := _habilidad_desbloqueada(habilidad)
		barrier.process_mode = Node.PROCESS_MODE_DISABLED if unlocked else Node.PROCESS_MODE_INHERIT
		poly.modulate.a = 0.12 if unlocked else 1.0
		label.visible = not unlocked
	)
	root.add_child(timer)
	# Primera comprobación inmediata.
	var unlocked := _habilidad_desbloqueada(habilidad)
	barrier.process_mode = Node.PROCESS_MODE_DISABLED if unlocked else Node.PROCESS_MODE_INHERIT
	poly.modulate.a = 0.12 if unlocked else 1.0
	label.visible = not unlocked

func _habilidad_desbloqueada(nombre: String) -> bool:
	var mapa := {
		"Impulso Espectral": "dash", "Garra Trepadora": "mantis_claw",
		"Embestida Cristalina": "crystal_heart", "Salto Celestial": "double_jump",
		"Bendición del Pantano": "isma_tear", "Paso Umbrío": "shade_cloak"
	}
	return GameState.tiene_habilidad(str(mapa.get(nombre, "")))

func _crear_instruccion(key: String) -> void:
	var hints := {
		"bosque_entrada": "RUTA: aprende a encadenar saltos y encuentra la salida elevada.",
		"bosque_sendero": "DESAFÍO: usa el DASH para cruzar la ruta superior.",
		"bosque_profundidad": "DESAFÍO VERTICAL: alterna plataformas y usa doble salto.",
		"bosque_santuario": "ATAJO: la Garra abre la ruta de pared; Dash abre el altar alto.",
		"lago_oscuro": "RUTAS: la Garra permite rodear el lago; el Corazón rompe la ruta cristalina.",
		"templo_antiguo": "ATAJO: Dash permite cruzar el corredor superior.",
		"ciudad_perdida": "RUTA ALTA: el Dash abre el paso sobre las ruinas.",
		"pantano_sombrio": "ASCENSO: usa plataformas y la Bendición para alcanzar la salida.",
		"torre_abismo": "PRUEBA: el Paso Umbrío abre el puente central.",
		"jefe_guardian": "ARENA: usa plataformas altas para esquivar y atacar a distancia.",
		"cavernas": "EXPLORACIÓN: la Garra abre el camino superior.",
		"cueva_secreta": "SECRETO: la Embestida Cristalina desbloquea la cámara profunda."
	}
	if not hints.has(key):
		return
	var label := Label.new()
	label.text = hints[key]
	label.position = Vector2(70, 110)
	label.size = Vector2(1500, 44)
	label.z_index = 20
	label.add_theme_font_size_override("font_size", 16)
	label.add_theme_color_override("font_color", Color(0.84, 0.88, 1.0, 0.88))
	add_child(label)
