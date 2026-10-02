extends Area2D

@export var identificador: String = "pocion_01"
@export var curacion: int = 30
var recogida: bool = false
var fase: float = 0.0

func _ready() -> void:
	if GameState.tiene_recompensa_especial(identificador):
		queue_free()
		return
	body_entered.connect(_on_body_entered)
	queue_redraw()

func _process(delta: float) -> void:
	fase += delta
	queue_redraw()

func _draw() -> void:
	var elevacion: float = sin(fase * 2.0) * 3.0
	draw_circle(Vector2(0, 4 + elevacion), 25.0, Color(0.35, 0.8, 1.0, 0.07))
	draw_circle(Vector2(0, 4 + elevacion), 20.0, Color(0.35, 0.8, 1.0))
	draw_rect(Rect2(-12, -20 + elevacion, 24, 12), Color(0.75, 0.75, 0.8))
	draw_rect(Rect2(-9, -26 + elevacion, 18, 8), Color(0.9, 0.9, 0.95))
	draw_circle(Vector2(-6, -2 + elevacion), 5.0, Color(0.8, 1.0, 1.0))

func _on_body_entered(body: Node2D) -> void:
	if recogida or not body.is_in_group("player"):
		return
	if GameState.tiene_recompensa_especial(identificador):
		queue_free()
		return

	recogida = true
	GameState.registrar_recompensa_especial(identificador)
	GameState.agregar_pociones(1)
	if body.has_method("actualizar_hud_habilidades"):
		body.actualizar_hud_habilidades()
	queue_free()
