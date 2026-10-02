extends Node2D

var pulse := 0.0

func _ready() -> void:
	z_index = -2
	queue_redraw()

func _process(delta: float) -> void:
	pulse += delta
	queue_redraw()

func _draw() -> void:
	var glow := 0.035 + sin(pulse * 2.0) * 0.008
	for i in range(16):
		var x := 80.0 + float(i) * 270.0
		var top := 250.0 + float(i % 4) * 80.0
		draw_line(Vector2(x, 1380.0), Vector2(x + 90.0, top), Color(0.82, 0.18, 0.30, glow), 5.0)
	for r in [230.0, 390.0, 590.0, 820.0]:
		draw_arc(Vector2(2096, 1410), r, PI + 0.16, TAU - 0.16, 80, Color(0.90, 0.22, 0.34, glow + 0.012), 4.0)
	for i in range(9):
		var x := 350.0 + float(i) * 440.0
		var y := 1140.0 + sin(pulse * 0.7 + i) * 18.0
		draw_circle(Vector2(x, y), 7.0 + sin(pulse + i) * 2.0, Color(0.90, 0.32, 0.42, 0.10))
	draw_circle(Vector2(2096, 1370), 180.0 + sin(pulse * 1.4) * 8.0, Color(0.95, 0.22, 0.34, 0.025))
