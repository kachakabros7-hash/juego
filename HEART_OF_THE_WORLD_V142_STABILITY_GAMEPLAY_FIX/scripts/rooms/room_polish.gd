extends Node2D

const WIDTH := 4100.0
const HEIGHT := 1400.0
const DEEPER := Color("#04060b")
const DEEP := Color("#080b13")
const ROCK := Color("#141824")
const ROCK_2 := Color("#1d2230")
const ROCK_3 := Color("#292f3e")
const MOSS := Color("#536b61")
const GLOW := Color("#7ca8a2")
const CRYSTAL := Color("#9b8be8")
const MOTE_COUNT := 46
const DETAIL_MOTE_COUNT := 24

var seed_value := 1
var zona := "caverna"
var motes: Array[Dictionary] = []
var detail_motes: Array[Dictionary] = []

func _ready() -> void:
	z_index = -1
	var ruta := get_scene_file_path()
	seed_value = 1 if ruta.is_empty() else abs(ruta.hash())
	zona = ruta.get_file().get_basename()
	_crear_motas()
	_crear_motas_detalle()
	_mostrar_nombre_zona()
	queue_redraw()

func _process(delta: float) -> void:
	for mote in motes:
		mote["phase"] = float(mote["phase"]) + delta * float(mote["speed"])
	for mote in detail_motes:
		mote["phase"] = float(mote["phase"]) + delta * float(mote["speed"])
		mote["x"] = float(mote["x"]) + float(mote["drift"]) * delta
		if float(mote["x"]) > WIDTH + 30.0:
			mote["x"] = -30.0
	queue_redraw()

func _crear_motas_detalle() -> void:
	detail_motes.clear()
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_value + 7331
	for i in range(DETAIL_MOTE_COUNT):
		detail_motes.append({
			"x": rng.randf_range(0.0, WIDTH),
			"y": rng.randf_range(260.0, 1180.0),
			"size": rng.randf_range(0.8, 2.2),
			"speed": rng.randf_range(0.7, 1.7),
			"drift": rng.randf_range(5.0, 18.0),
			"phase": rng.randf_range(0.0, TAU)
		})

func _mostrar_nombre_zona() -> void:
	# Solo las salas principales muestran el rótulo; las sub-salas no saturan la pantalla.
	var regiones_principales := ["bosque_entrada", "bosque_profundidad", "cavernas", "bosque_sendero", "bosque_santuario", "lago_oscuro", "ciudad_perdida", "pantano_sombrio", "templo_antiguo", "torre_abismo", "cueva_secreta", "jefe_guardian"]
	if zona not in regiones_principales:
		return
	var nombres := {
		"bosque_entrada": "BOSQUE DEL AMANECER",
		"bosque_profundidad": "RAÍCES PROFUNDAS",
		"cavernas": "CAVERNAS OLVIDADAS",
		"bosque_sendero": "MINAS ABANDONADAS",
		"bosque_santuario": "CIUDAD SUBTERRÁNEA",
		"lago_oscuro": "LAGO ESPECTRAL",
		"ciudad_perdida": "RUINAS DEL ECO PROFUNDO",
		"pantano_sombrio": "DESIERTO DE CRISTAL",
		"templo_antiguo": "TEMPLO ANCESTRAL",
		"torre_abismo": "TORRE ECLIPSE",
		"cueva_secreta": "ABISMO DE LA NIEBLA",
		"jefe_guardian": "EL CORAZÓN"
	}
	if not nombres.has(zona):
		return
	var layer := CanvasLayer.new()
	layer.name = "ZoneTitle"
	layer.layer = 80
	layer.process_mode = Node.PROCESS_MODE_ALWAYS
	get_tree().current_scene.add_child(layer)
	var panel := ColorRect.new()
	panel.color = Color(0.01, 0.015, 0.025, 0.62)
	panel.position = Vector2(70, 72)
	panel.size = Vector2(620, 88)
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer.add_child(panel)
	var label := Label.new()
	label.text = "✦  " + str(nombres[zona])
	label.position = Vector2(28, 17)
	label.size = Vector2(560, 45)
	label.add_theme_font_size_override("font_size", 27)
	label.add_theme_color_override("font_color", Color(0.80, 0.95, 0.86, 0.98))
	panel.add_child(label)
	var sub := Label.new()
	sub.text = "NUEVA REGIÓN"
	sub.position = Vector2(31, 51)
	sub.size = Vector2(250, 24)
	sub.add_theme_font_size_override("font_size", 13)
	sub.add_theme_color_override("font_color", Color(0.58, 0.72, 0.68, 0.9))
	panel.add_child(sub)
	panel.modulate.a = 0.0
	var tween := create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property(panel, "modulate:a", 1.0, 0.45)
	tween.tween_interval(1.7)
	tween.tween_property(panel, "modulate:a", 0.0, 0.8)
	tween.tween_callback(layer.queue_free)


func _a(c: Color, alpha: float) -> Color:
	var r := c
	r.a = alpha
	return r

func _crear_motas() -> void:
	motes.clear()
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_value
	for i in range(MOTE_COUNT):
		motes.append({
			"x": rng.randf_range(80.0, WIDTH - 80.0),
			"y": rng.randf_range(190.0, 1230.0),
			"size": rng.randf_range(1.2, 3.8),
			"speed": rng.randf_range(0.12, 0.42),
			"phase": rng.randf_range(0.0, TAU)
		})

func _draw() -> void:
	draw_rect(Rect2(0, 0, WIDTH, HEIGHT), DEEPER, true)
	_dibujar_capas_distantes()
	_dibujar_arcos()
	_dibujar_techo()
	_dibujar_paredes()
	_dibujar_formaciones()
	_dibujar_cristales()
	_dibujar_motivos()
	_dibujar_motas()
	_dibujar_primer_plano()

func _dibujar_capas_distantes() -> void:
	for layer in range(5):
		var y := 150.0 + float(layer) * 185.0
		var pts := PackedVector2Array()
		for i in range(19):
			var x := float(i) * 230.0 - 90.0
			var h := 70.0 + float((seed_value + i * 37 + layer * 23) % 210)
			pts.append(Vector2(x, y + h))
		pts.append(Vector2(WIDTH, HEIGHT))
		pts.append(Vector2(0, HEIGHT))
		draw_colored_polygon(pts, _a(ROCK, 0.055 + layer * 0.022))
	for i in range(14):
		var x := 120.0 + float(i) * 310.0
		var top := 350.0 + float((seed_value + i * 43) % 470)
		draw_line(Vector2(x, 1180), Vector2(x + 150, top), _a(ROCK_3, 0.08), 12.0)
		draw_circle(Vector2(x + 150, top), 24.0, _a(GLOW, 0.028))

func _dibujar_arcos() -> void:
	for i in range(8):
		var cx := 260.0 + float(i) * 520.0
		var h := 360.0 + float((seed_value + i * 71) % 300)
		var w := 250.0 + float((seed_value + i * 17) % 180)
		var pts := PackedVector2Array()
		for s in range(15):
			var t := float(s) / 14.0
			var x := lerpf(cx - w, cx + w, t)
			var curve := sin(t * PI) * h
			pts.append(Vector2(x, 210.0 + curve))
		for s in range(14, -1, -1):
			var t := float(s) / 14.0
			var x := lerpf(cx - w + 24.0, cx + w - 24.0, t)
			var curve := sin(t * PI) * (h - 35.0)
			pts.append(Vector2(x, 225.0 + curve))
		draw_colored_polygon(pts, _a(ROCK_2, 0.20))

func _dibujar_techo() -> void:
	var pts := PackedVector2Array([Vector2(0, 0)])
	for i in range(23):
		var x := float(i) * 190.0
		var dip := 105.0 + float((seed_value + i * 29) % 175)
		if i % 4 == 0:
			dip += 90.0
		pts.append(Vector2(x, dip))
	pts.append(Vector2(WIDTH, 0))
	draw_colored_polygon(pts, _a(ROCK, 0.96))
	for i in range(25):
		var x := 45.0 + float(i) * 170.0
		var h := 60.0 + float((seed_value + i * 31) % 180)
		var w := 14.0 + float((seed_value + i * 7) % 28)
		var base := 105.0 + float((seed_value + i * 29) % 145)
		var p := PackedVector2Array([
			Vector2(x - w, base), Vector2(x + w, base), Vector2(x + 5.0, base + h),
			Vector2(x, base + h + 22.0), Vector2(x - 5.0, base + h)
		])
		draw_colored_polygon(p, _a(ROCK_3, 0.72))
		draw_line(Vector2(x, base + h), Vector2(x, base + h + 22.0), _a(GLOW, 0.08), 2.0)

func _dibujar_paredes() -> void:
	for side in [0.0, WIDTH]:
		for i in range(13):
			var y := 190.0 + float(i) * 95.0
			var inward := 45.0 + float((seed_value + i * 23) % 110)
			var x2 := inward if side == 0.0 else WIDTH - inward
			draw_line(Vector2(side, y), Vector2(x2, y + 35.0), _a(ROCK_3, 0.16), 6.0)
	for i in range(42):
		var x := 60.0 + float((seed_value + i * 97) % 3980)
		var y := 220.0 + float((seed_value + i * 53) % 1040)
		draw_circle(Vector2(x, y), 3.0 + float(i % 5), _a(ROCK_3, 0.14))

func _dibujar_formaciones() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_value + 991
	for i in range(28):
		var x := rng.randf_range(90.0, WIDTH - 90.0)
		var y := rng.randf_range(1030.0, 1280.0)
		var h := rng.randf_range(25.0, 105.0)
		var w := rng.randf_range(16.0, 42.0)
		var p := PackedVector2Array([
			Vector2(x - w, y + 40.0), Vector2(x + w, y + 40.0),
			Vector2(x + w * 0.55, y - h * 0.25), Vector2(x, y - h),
			Vector2(x - w * 0.55, y - h * 0.25)
		])
		draw_colored_polygon(p, _a(ROCK_2, 0.78))
		draw_line(Vector2(x, y - h), Vector2(x + 5.0, y + 25.0), _a(ROCK_3, 0.22), 3.0)
	for i in range(12):
		var x := 180.0 + float(i) * 330.0
		var h := 150.0 + float((seed_value + i * 19) % 190)
		draw_line(Vector2(x, 1280), Vector2(x + 45.0, 1280 - h), _a(ROCK_3, 0.18), 20.0)
		draw_line(Vector2(x + 45.0, 1280 - h), Vector2(x + 90.0, 1280), _a(ROCK, 0.22), 15.0)

func _dibujar_cristales() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_value + 1818
	for i in range(18):
		var x := rng.randf_range(140.0, WIDTH - 140.0)
		var y := rng.randf_range(760.0, 1160.0)
		var h := rng.randf_range(28.0, 78.0)
		var w := rng.randf_range(7.0, 16.0)
		var p := PackedVector2Array([
			Vector2(x, y - h), Vector2(x + w, y - 8.0), Vector2(x + w * 0.4, y),
			Vector2(x - w * 0.65, y - 6.0), Vector2(x - w, y - h * 0.45)
		])
		draw_colored_polygon(p, _a(CRYSTAL, 0.12))
		draw_line(Vector2(x, y - h + 5.0), Vector2(x - 2.0, y - 10.0), _a(CRYSTAL, 0.25), 2.0)
		draw_circle(Vector2(x, y - h * 0.45), 18.0, _a(CRYSTAL, 0.025))

func _dibujar_motivos() -> void:
	var lower := zona.to_lower()
	if lower.contains("lago"):
		for i in range(10):
			var y := 1010.0 + float(i) * 35.0
			draw_arc(Vector2(420.0 + i * 410.0, y), 190.0 + i * 15.0, 0.05, 3.05, 40, _a(GLOW, 0.08), 2.0)
	elif lower.contains("templo") or lower.contains("ciudad"):
		for i in range(10):
			var x := 150.0 + float(i) * 430.0
			draw_line(Vector2(x, 1240.0), Vector2(x + 35.0, 350.0), _a(ROCK_3, 0.22), 16.0)
			draw_line(Vector2(x + 8.0, 1200.0), Vector2(x + 43.0, 365.0), _a(CRYSTAL, 0.055), 3.0)
	elif lower.contains("pantano"):
		for i in range(18):
			var x := 70.0 + float(i) * 240.0
			var y := 1100.0 + float((seed_value + i * 41) % 150)
			draw_line(Vector2(x, y), Vector2(x + 60.0, y - 155.0), _a(MOSS, 0.26), 5.0)
			draw_circle(Vector2(x + 55.0, y - 160.0), 10.0, _a(GLOW, 0.07))
	elif lower.contains("torre"):
		for i in range(10):
			var x := 150.0 + float(i) * 420.0
			draw_line(Vector2(x, 1260.0), Vector2(x + 80.0, 230.0), _a(CRYSTAL, 0.05), 7.0)
	else:
		for i in range(24):
			var x := 70.0 + float(i) * 175.0
			var y := 1170.0 + float((seed_value + i * 19) % 110)
			draw_line(Vector2(x, y), Vector2(x + 28.0, y - 70.0), _a(MOSS, 0.16), 4.0)

func _dibujar_motas() -> void:
	for mote in motes:
		var p := Vector2(float(mote["x"]), float(mote["y"]) + sin(float(mote["phase"])) * 9.0)
		draw_circle(p, float(mote["size"]), _a(GLOW, 0.11))
	for mote in detail_motes:
		var p2 := Vector2(float(mote["x"]), float(mote["y"]) + sin(float(mote["phase"])) * 5.0)
		draw_circle(p2, float(mote["size"]), _a(CRYSTAL if zona.contains("torre") or zona.contains("cueva") else GLOW, 0.16))

func _dibujar_primer_plano() -> void:
	for i in range(17):
		var x := 70.0 + float(i) * 250.0
		var y := 1335.0 - float((seed_value + i * 37) % 65)
		draw_line(Vector2(x, 1400), Vector2(x + 38, y), _a(ROCK_3, 0.30), 15.0)
		draw_line(Vector2(x + 38, y), Vector2(x + 82, 1400), _a(ROCK, 0.40), 11.0)
