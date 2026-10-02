extends Node2D

const W := 5600.0
const H := 1900.0

func _ready() -> void:
    z_index = -10
    queue_redraw()

func _draw() -> void:
    draw_rect(Rect2(0, 0, W, H), Color("#071316"), true)
    # capas lejanas
    var far := PackedVector2Array([
        Vector2(0,760), Vector2(450,520), Vector2(920,650), Vector2(1400,430),
        Vector2(1880,610), Vector2(2380,390), Vector2(2860,560), Vector2(3340,420),
        Vector2(3820,620), Vector2(4300,450), Vector2(4780,590), Vector2(5200,430), Vector2(W,560),
        Vector2(W,H), Vector2(0,H)
    ])
    draw_colored_polygon(far, Color("#0d2424"))

    var mid := PackedVector2Array([
        Vector2(0,1040), Vector2(330,870), Vector2(700,930), Vector2(1120,760),
        Vector2(1500,900), Vector2(1900,700), Vector2(2300,860), Vector2(2700,680),
        Vector2(3150,850), Vector2(3550,710), Vector2(3980,900), Vector2(4400,760),
        Vector2(4820,900), Vector2(5250,740), Vector2(W,860), Vector2(W,H), Vector2(0,H)
    ])
    draw_colored_polygon(mid, Color("#102d2a"))

    # techo rocoso irregular
    var roof := PackedVector2Array([Vector2(0,0)])
    var roof_pts := [190,130,240,95,175,280,120,210,260,150,115,235,175,105,220,145,110,260,135,200,165,120,250,145,180,110,230,155]
    for i in range(roof_pts.size()):
        roof.append(Vector2(float(i) * 220.0, float(roof_pts[i])))
    roof.append(Vector2(W,0))
    draw_colored_polygon(roof, Color("#05090b"))

    # paredes laterales quebradas
    draw_line(Vector2(0,0), Vector2(0,H), Color("#263d3a"), 22.0)
    draw_line(Vector2(W,0), Vector2(W,H), Color("#263d3a"), 22.0)

    # raíces/ramas decorativas de fondo
    for i in range(24):
        var x := 90.0 + float(i) * 235.0
        var y := 250.0 + float((i * 83) % 500)
        draw_line(Vector2(x,y), Vector2(x + 90,y + 170), Color(0.12,0.28,0.25,0.35), 9.0)
        draw_line(Vector2(x + 35,y + 90), Vector2(x - 50,y + 150), Color(0.12,0.28,0.25,0.25), 6.0)

    # motas
    for i in range(38):
        var x := 80.0 + float((i * 317) % 5400)
        var y := 300.0 + float((i * 173) % 900)
        draw_circle(Vector2(x,y), 2.5 + float(i % 3), Color(0.45,0.82,0.62,0.10))
