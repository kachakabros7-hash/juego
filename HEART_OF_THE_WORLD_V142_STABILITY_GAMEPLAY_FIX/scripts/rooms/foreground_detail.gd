extends Node2D

@export var accent: Color = Color("#8bbf8c")
@export var deep: Color = Color("#0a1714")
@export var seed_value: int = 1

func _ready() -> void:
	z_index = 4
	queue_redraw()

func _alpha(c: Color, a: float) -> Color:
	var out: Color = c
	out.a = a
	return out

func _draw() -> void:
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = seed_value
	for i: int in range(18):
		var x: float = rng.randf_range(90.0, 3110.0)
		var y: float = rng.randf_range(300.0, 1660.0)
		var h: float = rng.randf_range(22.0, 70.0)
		var bend: float = rng.randf_range(-18.0, 18.0)
		draw_line(Vector2(x, y + h), Vector2(x + bend, y), _alpha(deep, 0.22), rng.randf_range(1.0, 2.5))
		draw_circle(Vector2(x + bend, y), rng.randf_range(1.5, 4.0), _alpha(accent, 0.24))

	for i: int in range(10):
		var x2: float = rng.randf_range(120.0, 3060.0)
		var y2: float = rng.randf_range(360.0, 1540.0)
		draw_arc(Vector2(x2, y2), rng.randf_range(18.0, 34.0), 0.2, 1.8, 16, _alpha(accent, 0.08), 1.4)
