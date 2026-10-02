extends Node2D

@export var width: float = 4800.0
@export var height: float = 3000.0

func _ready() -> void:
    z_index = -2
    queue_redraw()

func _draw() -> void:
    draw_rect(Rect2(0.0, 0.0, width, height), Color("#0b1714"), true)
    draw_rect(Rect2(0.0, 400.0, width, 2200.0), Color(0.0627, 0.1451, 0.1176, 0.9), true)

    for i in range(18):
        var x: float = 90.0 + float(i) * 280.0
        var h: float = 500.0 + float((i * 97) % 900)
        draw_line(Vector2(x, 2450.0), Vector2(x - 45.0, 2450.0 - h), Color(0.1529, 0.2824, 0.2275, 0.55), 18.0)
        draw_line(Vector2(x + 18.0, 2450.0), Vector2(x + 70.0, 2450.0 - h * 0.72), Color(0.1922, 0.3294, 0.2588, 0.42), 11.0)

    for i in range(12):
        var x2: float = 180.0 + float(i) * 390.0
        var y: float = 760.0 + float((i * 137) % 1050)
        _draw_ellipse(Vector2(x2, y), Vector2(110.0, 35.0), Color(0.2157, 0.4235, 0.3490, 0.22))

    draw_rect(Rect2(0.0, 2500.0, width, 500.0), Color(0.0275, 0.0627, 0.0510, 0.86), true)

    for i in range(24):
        var x3: float = 70.0 + float(i) * 205.0
        draw_arc(Vector2(x3, 2570.0), 45.0, 0.0, PI, 16, Color(0.3569, 0.6078, 0.4745, 0.18), 3.0)

    draw_string(ThemeDB.fallback_font, Vector2(220.0, 300.0), "PANTANO SOMBRÍO", HORIZONTAL_ALIGNMENT_LEFT, -1.0, 44, Color(0.6471, 0.8157, 0.6471, 0.82))
    draw_string(ThemeDB.fallback_font, Vector2(220.0, 345.0), "ASCENSO · RAÍCES · CAMINOS ALTERNOS", HORIZONTAL_ALIGNMENT_LEFT, -1.0, 18, Color(0.4471, 0.5882, 0.4902, 0.8))

func _draw_ellipse(center: Vector2, radii: Vector2, color: Color) -> void:
    var pts: PackedVector2Array = PackedVector2Array()
    for i in range(25):
        var a: float = TAU * float(i) / 24.0
        pts.append(center + Vector2(cos(a) * radii.x, sin(a) * radii.y))
    draw_colored_polygon(pts, color)
