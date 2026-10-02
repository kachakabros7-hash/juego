extends Node2D

## Cambios visuales sencillos del Bosque del Amanecer después de obtener el primer fragmento.

var tiempo: float = 0.0

func _ready() -> void:
	set_process(true)
	queue_redraw()

func _process(delta: float) -> void:
	tiempo += delta
	queue_redraw()

func _draw() -> void:
	if not GameState.bosque_restaurado:
		return

	# Respiración del bosque: pequeñas luces y pulsos cerca del suelo.
	var pulso := (sin(tiempo * 2.0) + 1.0) * 0.5
	for p in [Vector2(420, 1280), Vector2(980, 1270), Vector2(1510, 1300), Vector2(2480, 1260), Vector2(3300, 1290), Vector2(3820, 1260)]:
		draw_circle(p, 12.0 + pulso * 7.0, Color(0.42, 0.86, 0.68, 0.10 + pulso * 0.08))
		draw_circle(p, 4.0 + pulso * 2.0, Color(0.62, 1.0, 0.82, 0.34))

	# Brotes de energía alrededor de algunos puntos del bosque.
	for p in [Vector2(520, 1180), Vector2(1120, 1160), Vector2(1730, 1200), Vector2(2860, 1160), Vector2(3500, 1180)]:
		draw_line(p, p + Vector2(0, -34), Color(0.48, 0.90, 0.65, 0.38), 3.0)
		draw_circle(p + Vector2(0, -38), 5.0, Color(0.68, 1.0, 0.78, 0.55))
