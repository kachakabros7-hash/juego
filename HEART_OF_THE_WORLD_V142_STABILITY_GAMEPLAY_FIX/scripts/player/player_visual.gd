extends Node2D

var phase: float = 0.0
var base_alpha: float = 0.0

func _ready() -> void:
	z_index = -1
	queue_redraw()

func _process(delta: float) -> void:
	phase += delta
	queue_redraw()

func _draw() -> void:
	var jugador: Node = get_parent()
	var sombra: Color = Color(0.01, 0.01, 0.02, 0.42)
	var aura: Color = Color(0.58, 0.40, 0.86, 0.0)
	var activo: bool = false

	if jugador != null:
		if bool(jugador.get("haciendo_dash")):
			aura = Color(0.45, 0.78, 1.0, 0.16)
			activo = true
		elif bool(jugador.get("capa_sombria_activa")):
			aura = Color(0.62, 0.32, 0.95, 0.20)
			activo = true
		elif bool(jugador.get("cargando_corazon")):
			aura = Color(0.40, 0.92, 1.0, 0.16)
			activo = true

	var shadow_scale: float = 1.0 + sin(phase * 2.2) * 0.035
	var shadow_points: PackedVector2Array = PackedVector2Array()
	for i: int in range(32):
		var angle: float = TAU * float(i) / 32.0
		shadow_points.append(Vector2(cos(angle) * 38.0 * shadow_scale, sin(angle) * 10.0))
	draw_colored_polygon(shadow_points, sombra)

	if activo:
		var pulse: float = 1.0 + sin(phase * 7.0) * 0.08
		draw_circle(Vector2.ZERO, 38.0 * pulse, aura)
		draw_circle(Vector2.ZERO, 28.0 * pulse, Color(aura.r, aura.g, aura.b, 0.10))
