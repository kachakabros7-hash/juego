extends "res://scripts/enemies/enemy_basic.gd"

@export var velocidad_aerea: float = 105.0
@export var aceleracion_aerea: float = 320.0
@export var amplitud: float = 28.0
@export var frecuencia: float = 2.2
@export var distancia_ataque_aerea: float = 95.0
@export var radio_orbita: float = 145.0
var fase: float = 0.0
var altura_base: float = 0.0
var sentido_orbita: float = 1.0
var tiempo_orbita: float = 0.0

func _ready() -> void:
	super._ready()
	hp_maxima = 42
	hp_actual = hp_maxima
	dano = 11
	gravedad = 0.0
	velocidad = velocidad_aerea
	distancia_deteccion = 560.0
	aplicar_balance_especifico()
	actualizar_barra_vida()
	altura_base = global_position.y
	sentido_orbita = -1.0 if randf() < 0.5 else 1.0
	sprite.modulate = Color(0.55, 0.85, 1.0, 1.0)

func _physics_process(delta: float) -> void:
	if esta_muerto:
		return
	fase += delta
	tiempo_orbita += delta
	if jugador == null or not is_instance_valid(jugador):
		jugador = get_tree().get_first_node_in_group("player")
		velocity = Vector2.ZERO
		return

	var distancia := global_position.distance_to(jugador.global_position)
	if distancia > distancia_deteccion:
		velocity = velocity.move_toward(Vector2.ZERO, aceleracion_aerea * delta)
		move_and_slide()
		sprite.play("idle")
		return

	var objetivo := jugador.global_position + Vector2(0.0, -35.0)
	if jugador is CharacterBody2D:
		objetivo += jugador.velocity * 0.18

	# Vuelo orbital suave: busca un ángulo lateral al jugador para evitar ataques totalmente frontales.
	var offset := Vector2(-sentido_orbita * radio_orbita * 0.55, -55.0)
	if tiempo_orbita > 2.2:
		sentido_orbita *= -1.0
		tiempo_orbita = 0.0
	var objetivo_orbita := objetivo + offset
	var direccion := global_position.direction_to(objetivo_orbita)
	var velocidad_objetivo := direccion * velocidad_aerea
	velocity = velocity.move_toward(velocidad_objetivo, aceleracion_aerea * delta)
	move_and_slide()

	global_position.y += sin(fase * frecuencia) * amplitud * delta
	if abs(velocity.x) > 1.0:
		sprite.flip_h = velocity.x < 0.0
	sprite.play("run")

	if distancia < distancia_ataque_aerea and puede_atacar:
		atacar_aereo()

func atacar_aereo() -> void:
	puede_atacar = false
	if is_instance_valid(jugador) and jugador.has_method("recibir_dano"):
		# Solo golpea si realmente está en rango; evita daño a través de grandes separaciones verticales.
		if global_position.distance_to(jugador.global_position) <= distancia_ataque_aerea:
			jugador.recibir_dano(dano, global_position)
	await get_tree().create_timer(tiempo_entre_ataques).timeout
	if is_instance_valid(self) and not esta_muerto:
		puede_atacar = true
