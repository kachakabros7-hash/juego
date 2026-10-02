extends Area2D

@export_enum("cofre", "fragmento_vida") var tipo: String = "cofre"
@export var identificador: String = "especial_01"
@export var cantidad_monedas: int = 10

var recogido: bool = false

func _ready() -> void:
	if GameState.tiene_recompensa_especial(identificador):
		queue_free()
		return
	body_entered.connect(_on_body_entered)
	queue_redraw()

func _draw() -> void:
	if tipo == "cofre":
		draw_rect(Rect2(-28, -20, 56, 40), Color(0.48, 0.25, 0.08))
		draw_rect(Rect2(-28, -20, 56, 10), Color(0.9, 0.65, 0.18))
		draw_rect(Rect2(-5, -4, 10, 16), Color(1.0, 0.88, 0.3))
	else:
		draw_circle(Vector2.ZERO, 24.0, Color(0.95, 0.25, 0.35))
		draw_circle(Vector2.ZERO, 17.0, Color(1.0, 0.72, 0.78))
		draw_circle(Vector2(-7, -4), 5.0, Color.WHITE)

func _on_body_entered(body: Node2D) -> void:
	if recogido or not body.is_in_group("player"):
		return
	if GameState.tiene_recompensa_especial(identificador):
		queue_free()
		return

	recogido = true
	GameState.registrar_recompensa_especial(identificador)

	if tipo == "cofre":
		GameState.agregar_monedas(cantidad_monedas)
		if body.has_method("actualizar_contador_monedas"):
			body.actualizar_contador_monedas()
	else:
		if body.has_method("aplicar_fragmento_vida"):
			body.aplicar_fragmento_vida()
		else:
			GameState.bonus_vida_fragmentos += 10
			GameState.vida_maxima += 10
			GameState.vida_actual = min(GameState.vida_actual + 10, GameState.vida_maxima)

	queue_free()
