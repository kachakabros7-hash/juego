extends Node2D

@export var accent: Color = Color("#9ee86c")
@export var direction: String = "right"
@export var seed_value: int = 1
@export var phase: float = 0.0
@export var concealed: bool = false

func _ready() -> void:
	z_index = 1
	queue_redraw()

func _process(_delta: float) -> void:
	queue_redraw()

func _draw() -> void:
	var pulse: float = 1.0 + sin(phase * 2.4 + float(seed_value % 17)) * 0.05
	if concealed:
		_dibujar_pared_falsa(pulse)
		return
	var vertical: bool = direction == "top" or direction == "bottom"
	var span: float = 72.0 if vertical else 110.0
	var thickness: float = 34.0 if vertical else 30.0
	var edge: Color = Color(accent, 0.42)
	var glow: Color = Color(accent, 0.06)
	var soft: Color = Color(accent, 0.18)
	var arrow: PackedVector2Array

	if direction == "right":
		arrow = PackedVector2Array([Vector2(8, -11), Vector2(28, 0), Vector2(8, 11)])
	elif direction == "left":
		arrow = PackedVector2Array([Vector2(-8, -11), Vector2(-28, 0), Vector2(-8, 11)])
	elif direction == "top":
		arrow = PackedVector2Array([Vector2(-11, 8), Vector2(0, -28), Vector2(11, 8)])
	else:
		arrow = PackedVector2Array([Vector2(-11, -8), Vector2(0, 28), Vector2(11, -8)])

	if vertical:
		draw_line(Vector2(-thickness * 0.5, 0), Vector2(-thickness * 0.5, -span * 0.5), glow, 10.0)
		draw_line(Vector2(thickness * 0.5, 0), Vector2(thickness * 0.5, -span * 0.5), glow, 10.0)
		draw_line(Vector2(-thickness * 0.5, 0), Vector2(-thickness * 0.5, -span * 0.5), edge, 2.0)
		draw_line(Vector2(thickness * 0.5, 0), Vector2(thickness * 0.5, -span * 0.5), edge, 2.0)
	else:
		draw_line(Vector2(0, -thickness * 0.5), Vector2(span * 0.5, -thickness * 0.5), glow, 10.0)
		draw_line(Vector2(0, thickness * 0.5), Vector2(span * 0.5, thickness * 0.5), glow, 10.0)
		draw_line(Vector2(0, -thickness * 0.5), Vector2(span * 0.5, -thickness * 0.5), edge, 2.0)
		draw_line(Vector2(0, thickness * 0.5), Vector2(span * 0.5, thickness * 0.5), edge, 2.0)

	draw_polyline(PackedVector2Array([arrow[0], arrow[1], arrow[2]]), soft, 4.0, true)
	draw_circle(arrow[1], 2.5 * pulse, Color(accent, 0.5))


func _dibujar_pared_falsa(pulse: float) -> void:
	var cerca: bool = false
	var jugador: Node = get_tree().get_first_node_in_group("player")
	if jugador != null and is_instance_valid(jugador):
		cerca = global_position.distance_to((jugador as Node2D).global_position) < 210.0
	var opacidad: float = 0.18 if not cerca else 0.46
	var crack: Color = Color(accent, opacidad)
	draw_line(Vector2(-30, -46), Vector2(-12, -22), crack, 2.0)
	draw_line(Vector2(-12, -22), Vector2(-22, 0), crack, 2.0)
	draw_line(Vector2(-22, 0), Vector2(8, 17), crack, 2.0)
	draw_line(Vector2(8, 17), Vector2(2, 45), crack, 2.0)
	draw_line(Vector2(18, -35), Vector2(8, -8), crack, 1.5)
	if cerca:
		draw_circle(Vector2.ZERO, 24.0 * pulse, Color(accent, 0.035))
