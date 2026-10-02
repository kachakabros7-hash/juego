extends Node2D
@export var width: float = 5000.0
@export var height: float = 2800.0
func _ready() -> void:
    z_index = -2
    queue_redraw()
func _draw() -> void:
    draw_rect(Rect2(0,0,width,height), Color("14151b"), true)
    draw_rect(Rect2(0,450,width,1800), Color("20232d",0.9), true)
    for i in range(11):
        var x := 140.0 + float(i)*470.0
        var h := 650.0 + float((i*83)%800)
        draw_rect(Rect2(x,2250-h,250,h), Color("303543",0.82), true)
        draw_rect(Rect2(x+35,2350-h,35,110), Color("d1b76a",0.16), true)
        draw_rect(Rect2(x+125,2400-h,35,160), Color("d1b76a",0.12), true)
    for i in range(8):
        var x2 := 300.0 + float(i)*610.0
        draw_arc(Vector2(x2,520),170,PI,TAU,24,Color("b9a66b",0.18),5)
    draw_rect(Rect2(0,2380,width,420), Color("0d0e12",0.85), true)
    for i in range(20):
        var x3 := 100.0 + float(i)*255.0
        draw_line(Vector2(x3,2380),Vector2(x3+70,2380),Color("c8ad64",0.16),4)
    draw_string(ThemeDB.fallback_font,Vector2(220,300),"CIUDAD PERDIDA",HORIZONTAL_ALIGNMENT_LEFT,-1,44,Color("e3cf91",0.84))
    draw_string(ThemeDB.fallback_font,Vector2(220,345),"PLAZAS · PASARELAS · RUTAS CRUZADAS",HORIZONTAL_ALIGNMENT_LEFT,-1,18,Color("aaa17f",0.78))
