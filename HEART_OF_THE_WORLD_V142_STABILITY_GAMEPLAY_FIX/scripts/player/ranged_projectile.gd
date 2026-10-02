extends Area2D

var velocity_projectile: Vector2 = Vector2.ZERO
var dano: int = 10
var vida: float = 3.0
var explosivo: bool = false
var penetrante: bool = false
var tamano: float = 1.0
var tipo: String = "onda"
var objetivo_regreso: Node2D = null
var tiempo_boomerang: float = 0.0

func configurar(direccion: Vector2, dano_base: int, velocidad: float, tipo: String) -> void:
	velocity_projectile = direccion.normalized() * velocidad
	dano = dano_base
	self.tipo = tipo
	name = "Proyectil_" + tipo
	match tipo:
		"onda":
			tamano = 1.0
		"boomerang":
			tamano = 0.9
		"corte":
			penetrante = true
			tamano = 0.75
		"explosion":
			explosivo = true
			tamano = 1.25
		"lluvia":
			tamano = 0.8
		"rayo":
			tamano = 1.4
		"cargado":
			tamano = 1.6
	queue_redraw()

func _ready() -> void:
	monitoring = true
	monitorable = true
	body_entered.connect(_on_body_entered)
	queue_redraw()

func _physics_process(delta: float) -> void:
	vida -= delta
	tiempo_boomerang += delta
	if tipo == "boomerang":
		if tiempo_boomerang > 0.45 and is_instance_valid(objetivo_regreso):
			var hacia: Vector2 = objetivo_regreso.global_position - global_position
			if hacia.length() < 45.0:
				queue_free()
				return
			velocity_projectile = hacia.normalized() * 700.0
	global_position += velocity_projectile * delta
	if vida <= 0.0:
		queue_free()
	queue_redraw()

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		return
	if body.has_method("recibir_dano"):
		body.recibir_dano(dano, global_position)
		if not penetrante:
			queue_free()

func _draw() -> void:
	var r := 10.0 * tamano
	draw_circle(Vector2.ZERO, r, Color(0.75, 0.95, 1.0, 0.92))
	draw_circle(Vector2.ZERO, r * 0.55, Color(1.0, 1.0, 1.0, 0.95))
	if explosivo:
		draw_arc(Vector2.ZERO, r * 1.7, 0.0, TAU, 24, Color(0.65, 0.9, 1.0, 0.65), 3.0)
