extends Node2D

func _ready() -> void:
	queue_redraw()

func _draw() -> void:
	# Fondo profundo, sin grandes bloques sólidos de colisión.
	draw_rect(Rect2(0, 0, 2600, 5200), Color(0.018, 0.014, 0.032, 1.0))
	# Capas verticales que enmarcan el abismo.
	draw_polygon(PackedVector2Array([
		Vector2(0, 0), Vector2(520, 0), Vector2(420, 900), Vector2(540, 1800),
		Vector2(360, 2800), Vector2(500, 3800), Vector2(300, 4700), Vector2(0, 5200)
	]), PackedColorArray([Color(0.055, 0.045, 0.075, 1.0)]))
	draw_polygon(PackedVector2Array([
		Vector2(2600, 0), Vector2(2080, 0), Vector2(2180, 900), Vector2(2060, 1800),
		Vector2(2240, 2800), Vector2(2100, 3800), Vector2(2300, 4700), Vector2(2600, 5200)
	]), PackedColorArray([Color(0.055, 0.045, 0.075, 1.0)]))

	# Eje central y grietas.
	for y in range(260, 5000, 520):
		var sway: float = sin(float(y) * 0.008) * 120.0
		draw_line(Vector2(1300 + sway, y), Vector2(1300 - sway * 0.35, y + 230), Color(0.22, 0.16, 0.30, 0.28), 3.0)

	# Faros de navegación.
	for p in [Vector2(690, 850), Vector2(1900, 1650), Vector2(720, 2650), Vector2(1870, 3550), Vector2(700, 4480)]:
		draw_circle(p, 20.0, Color(0.45, 0.34, 0.62, 0.42))
		draw_circle(p, 7.0, Color(0.78, 0.66, 0.92, 0.8))

	# Título.
	draw_string(ThemeDB.fallback_font, Vector2(90, 150), "ZONA 03 — PROFUNDIDAD DEL BOSQUE", HORIZONTAL_ALIGNMENT_LEFT, -1, 38, Color(0.82, 0.75, 0.92, 0.92))
	draw_string(ThemeDB.fallback_font, Vector2(90, 195), "EJE VERTICAL · DOBLE SALTO · DASH", HORIZONTAL_ALIGNMENT_LEFT, -1, 20, Color(0.52, 0.46, 0.62, 0.9))

	# Indicadores de rutas: pocos y colocados junto a decisiones reales.
	draw_string(ThemeDB.fallback_font, Vector2(110, 5050), "← REGRESO A Z02", HORIZONTAL_ALIGNMENT_LEFT, -1, 24, Color(0.68, 0.61, 0.78, 0.9))
	draw_string(ThemeDB.fallback_font, Vector2(1830, 170), "↑ RUMBO A Z04", HORIZONTAL_ALIGNMENT_LEFT, -1, 24, Color(0.68, 0.61, 0.78, 0.9))
	draw_string(ThemeDB.fallback_font, Vector2(1940, 2380), "→ DASH · RUTA SECUNDARIA", HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Color(0.58, 0.50, 0.70, 0.78))
	draw_string(ThemeDB.fallback_font, Vector2(980, 4020), "↑ CONTINÚA EL ASCENSO", HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Color(0.58, 0.50, 0.70, 0.78))
