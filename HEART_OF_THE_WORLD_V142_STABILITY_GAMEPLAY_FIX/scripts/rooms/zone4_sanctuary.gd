extends Node2D

func _ready() -> void:
    queue_redraw()

func _draw() -> void:
    draw_rect(Rect2(0, 0, 4200, 2400), Color(0.025, 0.018, 0.045, 1.0))
    # Grandes columnas laterales: marco visual, no colisión.
    for x in [260.0, 900.0, 3300.0, 3940.0]:
        draw_rect(Rect2(x, 420, 70, 1500), Color(0.075, 0.055, 0.11, 1.0))
        draw_line(Vector2(x + 35, 420), Vector2(x + 35, 1920), Color(0.22, 0.16, 0.30, 0.35), 3.0)
    # Arcos del santuario.
    for center in [Vector2(1250, 720), Vector2(2100, 480), Vector2(2950, 720)]:
        draw_arc(center, 260.0, PI, TAU, 40, Color(0.34, 0.24, 0.46, 0.45), 5.0)
        draw_arc(center, 220.0, PI, TAU, 40, Color(0.16, 0.12, 0.24, 0.75), 2.0)
    # Fragmentos de luz y orientación.
    for p in [Vector2(700, 1830), Vector2(1500, 1450), Vector2(2300, 980), Vector2(3150, 1450), Vector2(3650, 820)]:
        draw_circle(p, 18.0, Color(0.48, 0.35, 0.66, 0.35))
        draw_circle(p, 6.0, Color(0.82, 0.72, 0.96, 0.85))
    draw_string(ThemeDB.fallback_font, Vector2(100, 150), "ZONA 04 — SANTUARIO OLVIDADO", HORIZONTAL_ALIGNMENT_LEFT, -1, 40, Color(0.84, 0.76, 0.95, 0.95))
    draw_string(ThemeDB.fallback_font, Vector2(100, 194), "RUINAS · RUTAS ELEVADAS · DASH", HORIZONTAL_ALIGNMENT_LEFT, -1, 20, Color(0.55, 0.48, 0.66, 0.9))
    draw_string(ThemeDB.fallback_font, Vector2(95, 2260), "← REGRESO A Z03", HORIZONTAL_ALIGNMENT_LEFT, -1, 24, Color(0.70, 0.62, 0.80, 0.9))
    draw_string(ThemeDB.fallback_font, Vector2(3510, 300), "→ RUTA PRINCIPAL · Z06", HORIZONTAL_ALIGNMENT_LEFT, -1, 24, Color(0.70, 0.62, 0.80, 0.9))
    draw_string(ThemeDB.fallback_font, Vector2(3300, 2140), "↓ RUTA ALTERNATIVA · Z05", HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Color(0.58, 0.50, 0.70, 0.78))
    draw_string(ThemeDB.fallback_font, Vector2(1920, 360), "ALTAR · PUNTO DE ORIENTACIÓN", HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color(0.60, 0.52, 0.72, 0.72))
