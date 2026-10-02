extends "res://scripts/enemies/enemy_basic.gd"

var fase: float = 0.0

func _ready() -> void:
    super._ready()
    queue_redraw()

func _process(delta: float) -> void:
    fase += delta
    queue_redraw()

func _draw() -> void:
    var pulse := 1.0 + sin(fase * 4.0) * 0.04
    # Criatura exclusiva de Raíces Profundas: larva de madera y piedra.
    draw_circle(Vector2.ZERO, 34.0 * pulse, Color(0.16, 0.10, 0.06, 1.0))
    draw_circle(Vector2(0, -3), 29.0 * pulse, Color(0.42, 0.25, 0.10, 1.0))
    draw_circle(Vector2(-10, -8), 5.0, Color(0.55, 0.88, 0.42, 1.0))
    draw_circle(Vector2(10, -8), 5.0, Color(0.55, 0.88, 0.42, 1.0))
    draw_line(Vector2(-15, 9), Vector2(-28, 20), Color(0.22,0.14,0.07,1), 7.0)
    draw_line(Vector2(15, 9), Vector2(28, 20), Color(0.22,0.14,0.07,1), 7.0)
    draw_arc(Vector2.ZERO, 30.0, 0.2, PI-0.2, 18, Color(0.68,0.48,0.18,1), 3.0)
