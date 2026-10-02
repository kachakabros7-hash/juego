extends Node2D

@export var width: float = 4200.0
@export var height: float = 2400.0
@export var accent: Color = Color(0.55, 0.42, 0.72, 0.55)
@export var title: String = ""
@export var subtitle: String = ""

func _ready() -> void:
	z_index = 0
	queue_redraw()

func _draw() -> void:
	# Decoración ligera: marcos, líneas de lectura y puntos de orientación.
	var border := Color(accent.r, accent.g, accent.b, 0.22)
	draw_line(Vector2(90, 270), Vector2(width - 90, 270), border, 2.0)
	draw_line(Vector2(90, height - 180), Vector2(width - 90, height - 180), border, 2.0)
	for i in range(9):
		var x := 180.0 + float(i) * ((width - 360.0) / 8.0)
		draw_line(Vector2(x, 300), Vector2(x, 340), Color(accent.r, accent.g, accent.b, 0.18), 2.0)
		var y := 430.0 + float((i * 211) % max(500, int(height - 650)))
		draw_circle(Vector2(x, y), 3.0, Color(accent.r, accent.g, accent.b, 0.22))
	if not title.is_empty():
		draw_string(ThemeDB.fallback_font, Vector2(110, 135), title, HORIZONTAL_ALIGNMENT_LEFT, -1, 34, Color(0.88, 0.82, 0.96, 0.92))
	if not subtitle.is_empty():
		draw_string(ThemeDB.fallback_font, Vector2(110, 178), subtitle, HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Color(0.60, 0.54, 0.70, 0.88))
