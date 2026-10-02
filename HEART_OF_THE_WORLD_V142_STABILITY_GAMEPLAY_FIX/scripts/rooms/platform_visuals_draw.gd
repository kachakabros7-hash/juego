extends Node2D

@export var size: Vector2 = Vector2(400.0, 50.0)
@export var kind: String = "platform"
@export var seed_value: int = 1
@export var body_color: Color = Color("#171a24")
@export var mid_color: Color = Color("#292e3b")
@export var top_color: Color = Color("#4a505c")
@export var edge_color: Color = Color("#737986")
@export var shadow_color: Color = Color("#07090f")

func _ready() -> void:
	z_index = 1
	queue_redraw()

func _a(c: Color, a: float) -> Color:
	var r := c
	r.a = a
	return r

func _draw() -> void:
	match kind:
		"wall": _draw_wall()
		"ground": _draw_ground()
		"pillar": _draw_pillar()
		_: _draw_platform()

func _draw_platform() -> void:
	var half := size * 0.5
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_value
	draw_rect(Rect2(-half.x + 5.0, 1.0, size.x - 10.0, maxf(size.y * 0.45, 10.0)), shadow_color, true)
	draw_rect(Rect2(-half.x, -half.y + 5.0, size.x, maxf(size.y - 5.0, 8.0)), body_color, true)
	draw_rect(Rect2(-half.x + 2.0, -half.y + 7.0, size.x - 4.0, maxf(size.y - 9.0, 7.0)), mid_color, true)
	var pts := PackedVector2Array()
	var steps := clampi(int(size.x / 30.0), 8, 48)
	for i in range(steps + 1):
		var t := float(i) / float(steps)
		pts.append(Vector2(lerpf(-half.x, half.x, t), -half.y + rng.randf_range(-3.0, 2.0)))
	for i in range(steps, -1, -1):
		var t := float(i) / float(steps)
		pts.append(Vector2(lerpf(-half.x, half.x, t), -half.y + 10.0))
	draw_colored_polygon(pts, top_color)
	draw_polyline(PackedVector2Array(pts.slice(0, steps + 1)), edge_color, 2.2, true)
	for i in range(clampi(int(size.x / 95.0), 3, 12)):
		var x := rng.randf_range(-half.x + 12.0, half.x - 12.0)
		var y := rng.randf_range(-half.y + 12.0, half.y - 7.0)
		draw_circle(Vector2(x, y), rng.randf_range(1.5, 4.0), _a(edge_color, 0.28))
		if i % 2 == 0:
			draw_line(Vector2(x, y), Vector2(x + rng.randf_range(-8.0, 8.0), y + rng.randf_range(6.0, 18.0)), _a(shadow_color, 0.48), 1.7)
	draw_line(Vector2(-half.x, half.y - 1.0), Vector2(half.x, half.y - 1.0), _a(shadow_color, 0.9), 3.0)
	_dibujar_desgaste_superior(half, rng)

func _dibujar_desgaste_superior(half: Vector2, rng: RandomNumberGenerator, escala: float = 1.0) -> void:
	# Detalles pequeños y deterministas: hacen que cada plataforma tenga una silueta
	# ligeramente distinta sin tocar su colisión.
	var marcas := clampi(int(size.x / 150.0), 2, 10)
	for i in range(marcas):
		var x := rng.randf_range(-half.x + 16.0, half.x - 16.0)
		var y := -half.y + rng.randf_range(3.0, 8.0)
		var largo := rng.randf_range(7.0, 18.0) * escala
		draw_line(Vector2(x, y), Vector2(x + largo, y + rng.randf_range(2.0, 5.0)), _a(shadow_color, 0.34), 1.3)
		if i % 3 == 0:
			draw_line(Vector2(x + largo * 0.45, y + 2.0), Vector2(x + largo * 0.25, y + 9.0 * escala), _a(shadow_color, 0.25), 1.1)


func _draw_ground() -> void:
	var half := size * 0.5
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_value
	draw_rect(Rect2(-half.x, -half.y, size.x, size.y), shadow_color, true)
	draw_rect(Rect2(-half.x + 4.0, -half.y + 6.0, size.x - 8.0, size.y - 8.0), body_color, true)
	var pts := PackedVector2Array()
	var steps := clampi(int(size.x / 28.0), 12, 90)
	for i in range(steps + 1):
		var t := float(i) / float(steps)
		pts.append(Vector2(lerpf(-half.x, half.x, t), -half.y + rng.randf_range(-2.0, 2.0)))
	for i in range(steps, -1, -1):
		var t := float(i) / float(steps)
		pts.append(Vector2(lerpf(-half.x, half.x, t), -half.y + 12.0))
	draw_colored_polygon(pts, top_color)
	draw_polyline(PackedVector2Array(pts.slice(0, steps + 1)), edge_color, 2.5, true)
	for i in range(45):
		var x := rng.randf_range(-half.x + 10.0, half.x - 10.0)
		var y := rng.randf_range(-half.y + 16.0, half.y - 10.0)
		var r := rng.randf_range(1.2, 3.6)
		draw_circle(Vector2(x, y), r, _a(mid_color, 0.72))
		if i % 3 == 0:
			draw_line(Vector2(x, y), Vector2(x + rng.randf_range(-8.0, 8.0), y + rng.randf_range(7.0, 22.0)), _a(shadow_color, 0.34), 1.8)
	draw_line(Vector2(-half.x, half.y - 2.0), Vector2(half.x, half.y - 2.0), _a(shadow_color, 0.95), 5.0)
	_dibujar_desgaste_superior(half, rng, 1.35)

func _draw_wall() -> void:
	var half := size * 0.5
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_value
	draw_rect(Rect2(-half.x, -half.y, size.x, size.y), shadow_color, true)
	draw_rect(Rect2(-half.x + 7.0, -half.y + 3.0, size.x - 14.0, size.y - 6.0), body_color, true)
	for i in range(20):
		var x := rng.randf_range(-half.x + 8.0, half.x - 8.0)
		var y := rng.randf_range(-half.y + 10.0, half.y - 10.0)
		draw_circle(Vector2(x, y), rng.randf_range(2.0, 6.0), _a(mid_color, 0.42))
	for i in range(8):
		var x := rng.randf_range(-half.x + 10.0, half.x - 10.0)
		var y := rng.randf_range(-half.y + 20.0, half.y - 20.0)
		draw_line(Vector2(x, y), Vector2(x + rng.randf_range(-12.0, 12.0), y + rng.randf_range(18.0, 55.0)), _a(shadow_color, 0.42), 2.5)
	draw_line(Vector2(-half.x + 3.0, -half.y), Vector2(-half.x + 3.0, half.y), _a(edge_color, 0.16), 3.0)

func _draw_pillar() -> void:
	var half := size * 0.5
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_value
	draw_rect(Rect2(-half.x, -half.y, size.x, size.y), shadow_color, true)
	draw_rect(Rect2(-half.x + 7.0, -half.y + 3.0, size.x - 14.0, size.y - 6.0), body_color, true)
	draw_rect(Rect2(-half.x - 10.0, -half.y - 10.0, size.x + 20.0, 12.0), mid_color, true)
	draw_rect(Rect2(-half.x - 15.0, -half.y - 14.0, size.x + 30.0, 5.0), edge_color, true)
	for i in range(9):
		var x := rng.randf_range(-half.x + 12.0, half.x - 12.0)
		var y := rng.randf_range(-half.y + 30.0, half.y - 20.0)
		draw_line(Vector2(x, y), Vector2(x + rng.randf_range(-5.0, 5.0), y + rng.randf_range(8.0, 25.0)), _a(shadow_color, 0.5), 1.8)
	draw_rect(Rect2(-half.x - 12.0, half.y - 2.0, size.x + 24.0, 12.0), shadow_color, true)
