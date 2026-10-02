extends Node2D

@export var room_width: float = 4200.0
@export var room_height: float = 2400.0
@export var directions: Array[String] = []

func _ready() -> void:
    z_index = 12
    queue_redraw()

func _draw() -> void:
    var font := ThemeDB.fallback_font
    var accent := Color(0.72, 0.64, 0.86, 0.82)
    var muted := Color(0.55, 0.50, 0.66, 0.70)
    var panel := Color(0.02, 0.015, 0.04, 0.72)

    if directions.size() > 0:
        var y := room_height - 70.0
        draw_rect(Rect2(70, y - 38, min(room_width - 140, 760.0), 46), panel, true)
        draw_string(font, Vector2(92, y - 8), "RUTA: " + "   ·   ".join(directions), HORIZONTAL_ALIGNMENT_LEFT, -1, 18, accent)

    # Pequeñas balizas de orientación; no tienen colisión.
    var points := [
        Vector2(110, room_height - 145),
        Vector2(room_width * 0.5, 120),
        Vector2(room_width - 150, room_height * 0.35)
    ]
    for p in points:
        draw_circle(p, 10.0, Color(accent.r, accent.g, accent.b, 0.12))
        draw_circle(p, 3.0, muted)
