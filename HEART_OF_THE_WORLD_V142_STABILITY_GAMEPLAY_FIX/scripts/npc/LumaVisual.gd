extends Node2D

## Visual procedural original de Luma.
## No depende de sprites externos.

func _ready() -> void:
	queue_redraw()

func _draw() -> void:
	# Aura
	draw_circle(Vector2(0, -38), 42.0, Color(0.35, 0.85, 0.70, 0.08))
	draw_circle(Vector2(0, -38), 28.0, Color(0.50, 1.0, 0.82, 0.08))

	# Cuerpo / capa
	var cuerpo := PackedVector2Array([
		Vector2(-18, -22), Vector2(18, -22), Vector2(25, 18),
		Vector2(10, 30), Vector2(-10, 30), Vector2(-25, 18)
	])
	draw_colored_polygon(cuerpo, Color(0.16, 0.27, 0.31, 1.0))

	# Manto luminoso
	draw_circle(Vector2(0, -22), 15.0, Color(0.48, 0.86, 0.74, 1.0))
	draw_circle(Vector2(0, -22), 8.0, Color(0.78, 1.0, 0.90, 1.0))

	# Cabeza
	draw_circle(Vector2(0, -49), 13.0, Color(0.67, 0.82, 0.76, 1.0))
	# Cabello / capucha
	draw_arc(Vector2(0, -50), 14.0, PI, TAU, 16, Color(0.08, 0.15, 0.19, 1.0), 5.0)

	# Cristal del pecho
	draw_colored_polygon(PackedVector2Array([
		Vector2(0, -30), Vector2(5, -22), Vector2(0, -14), Vector2(-5, -22)
	]), Color(0.55, 1.0, 0.80, 0.95))

	# Partículas
	for p in [Vector2(-27,-55), Vector2(25,-37), Vector2(-31,-10), Vector2(30,-2)]:
		draw_circle(p, 2.0, Color(0.55, 1.0, 0.82, 0.8))
