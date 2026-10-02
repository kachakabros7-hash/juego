extends Control

var zona: String = ""
var tiempo: float = 0.0
var motas: Array[Dictionary] = []

func configurar(zona_id: String) -> void:
	zona = zona_id.to_lower()
	var rng := RandomNumberGenerator.new()
	rng.seed = abs(zona.hash()) + 991
	motas.clear()
	for i in range(18):
		motas.append({"x": rng.randf_range(0.0, 1920.0), "y": rng.randf_range(80.0, 1080.0), "s": rng.randf_range(0.7, 2.2), "v": rng.randf_range(5.0, 15.0), "p": rng.randf_range(0.0, TAU)})
	queue_redraw()

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	modulate.a = 0.9

func _process(delta: float) -> void:
	tiempo += delta
	for m in motas:
		m["y"] = float(m["y"]) - float(m["v"]) * delta
		m["x"] = float(m["x"]) + sin(tiempo * 0.7 + float(m["p"])) * delta * 4.0
		if float(m["y"]) < 40.0:
			m["y"] = 1120.0
	queue_redraw()

func _color() -> Color:
	if zona.contains("bosque") or zona.contains("pantano"):
		return Color(0.35, 0.72, 0.58, 0.12)
	if zona.contains("lago") or zona.contains("caverna"):
		return Color(0.30, 0.60, 0.95, 0.12)
	if zona.contains("templo") or zona.contains("ciudad"):
		return Color(0.68, 0.58, 0.90, 0.10)
	if zona.contains("torre") or zona.contains("abismo"):
		return Color(0.52, 0.32, 0.82, 0.13)
	return Color(0.55, 0.80, 0.78, 0.08)

func _draw() -> void:
	var c := _color()
	var size := get_viewport_rect().size
	for m in motas:
		var pos := Vector2(float(m["x"]), float(m["y"]))
		draw_circle(pos, float(m["s"]), Color(c.r, c.g, c.b, c.a))
	# Viñeta muy ligera para dar profundidad sin tapar el juego.
	var edge := Color(0.0, 0.0, 0.02, 0.12)
	draw_rect(Rect2(0, 0, size.x, 46), edge, true)
	draw_rect(Rect2(0, size.y - 54, size.x, 54), edge, true)
