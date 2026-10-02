extends Node2D

@export var width: float = 4600.0
@export var height: float = 2600.0

func _ready() -> void:
    z_index = -2
    queue_redraw()

func _draw() -> void:
    draw_rect(Rect2(0, 0, width, height), Color("17130e"), true)
    draw_rect(Rect2(0, 500, width, 1500), Color("211b13", 0.82), true)
    for i in range(10):
        var x := 220.0 + float(i) * 460.0
        draw_rect(Rect2(x, 620, 90, 1300), Color("4a3b24", 0.36), true)
        draw_line(Vector2(x + 12, 640), Vector2(x + 12, 1890), Color("d5b867", 0.12), 4.0)
    for i in range(7):
        var x2 := 300.0 + float(i) * 650.0
        draw_arc(Vector2(x2, 410), 150.0, PI, TAU, 24, Color("b8944f", 0.20), 5.0)
    draw_rect(Rect2(0, 2000, width, 600), Color("0d0c0a", 0.75), true)
    for i in range(16):
        var x3 := 140.0 + float(i) * 285.0
        draw_line(Vector2(x3, 1980), Vector2(x3 + 70, 1980), Color("e0c778", 0.16), 4.0)
    draw_string(ThemeDB.fallback_font, Vector2(220, 310), "RUINAS ANTIGUAS", HORIZONTAL_ALIGNMENT_LEFT, -1, 42, Color("f0d58a", 0.82))
    draw_string(ThemeDB.fallback_font, Vector2(220, 355), "CORREDOR PRINCIPAL · RUTAS ALTERNAS", HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Color("b99e64", 0.78))
