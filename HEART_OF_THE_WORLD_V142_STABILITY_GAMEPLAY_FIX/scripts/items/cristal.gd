extends Area2D

@export var identificador: String = "cristal_01"
@export var monedas: int = 5
var recogido: bool = false
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
	var pulso: float = 1.0 + sin(fase * 3.2) * 0.10
	draw_circle(Vector2.ZERO, 25.0 * pulso, Color(0.25, 0.85, 1.0, 0.06))
	var pts := PackedVector2Array([
		Vector2(0, -18), Vector2(12, -5), Vector2(8, 14),
		Vector2(0, 20), Vector2(-8, 14), Vector2(-12, -5)
	])
	draw_colored_polygon(pts, Color(0.35, 0.9, 1.0))
	draw_polyline(PackedVector2Array([Vector2(0,-18), Vector2(12,-5), Vector2(8,14), Vector2(0,20), Vector2(-8,14), Vector2(-12,-5), Vector2(0,-18)]), Color.WHITE, 2.0)

func _on_body_entered(body: Node2D) -> void:
	if recogido or not body.is_in_group("player"):
		return
	recogido = true
	GameState.registrar_recompensa_especial(identificador)
	GameState.agregar_monedas(monedas)
	if body.has_method("actualizar_contador_monedas"):
		body.actualizar_contador_monedas()
	queue_free()
