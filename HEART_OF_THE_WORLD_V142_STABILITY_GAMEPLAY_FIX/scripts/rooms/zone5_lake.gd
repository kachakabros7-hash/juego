extends Node2D

@export var width: float = 4400.0
@export var height: float = 2500.0

func _ready() -> void:
    z_index = -2
    queue_redraw()

func _draw() -> void:
    draw_rect(Rect2(0, 0, width, height), Color("071521"), true)
    draw_circle(Vector2(3500, 500), 850, Color("102b3b", 0.75))
    draw_circle(Vector2(850, 900), 620, Color("0b2432", 0.7))
    for i in range(9):
        var y := 1510.0 + float(i % 3) * 245.0
        draw_line(Vector2(0, y), Vector2(width, y), Color("2e7181", 0.16), 3.0)
    # Agua visual: no hace daño y queda debajo de las rutas jugables.
    draw_rect(Rect2(0, 1850, width, 650), Color("0b3041", 0.86), true)
    for i in range(22):
        var x := 80.0 + float(i) * 205.0
        var y := 1900.0 + float((i * 97) % 480)
        draw_arc(Vector2(x, y), 42.0, PI, TAU, 16, Color("65c9dc", 0.18), 2.0)
    for i in range(15):
        var x2 := 170.0 + float((i * 311) % 4100)
        var h := 120.0 + float((i * 43) % 180)
        draw_line(Vector2(x2, 1840), Vector2(x2 - 18, 1840 - h), Color("4d8191", 0.18), 3.0)
    draw_string(ThemeDB.fallback_font, Vector2(220, 520), "LAGO OSCURO", HORIZONTAL_ALIGNMENT_LEFT, -1, 42, Color("9be5f2", 0.78))
    draw_string(ThemeDB.fallback_font, Vector2(220, 565), "ORILLAS · SALTOS · RUTA INFERIOR", HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Color("6e9eae", 0.78))
