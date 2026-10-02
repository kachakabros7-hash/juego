extends "res://scripts/enemies/enemy_basic.gd"

@export var distancia_preferida: float = 260.0
@export var alcance_disparo: float = 380.0
@export var tiempo_apuntar: float = 0.55
@export var distancia_minima_segura: float = 150.0
@export var amplitud_strife: float = 55.0
var apuntando: float = 0.0
var sentido_strife: float = 1.0
var cambio_strife: float = 0.0

func _ready() -> void:
	super._ready()
	hp_maxima = 45
	hp_actual = hp_maxima
	dano = 9
	velocidad = 75.0
	aceleracion = 500.0
	distancia_deteccion = 520.0
	aplicar_balance_especifico()
	actualizar_barra_vida()
	cambio_strife = randf_range(0.8, 1.8)
	if sprite != null:
		sprite.modulate = Color(0.66, 0.45, 0.95, 1.0)

func _physics_process(delta: float) -> void:
	if esta_muerto:
		return
	if jugador == null or not is_instance_valid(jugador):
		jugador = get_tree().get_first_node_in_group("player")
		_aplicar_gravedad(delta)
		move_and_slide()
		return

	var distancia: float = global_position.distance_to(jugador.global_position)
	var visible_objetivo := _puede_ver_al_jugador()

	if distancia > distancia_deteccion or not visible_objetivo:
		if apuntando > 0.0:
			apuntando = 0.0
		procesar_movimiento_ia(delta, distancia, visible_objetivo)
		return

	if apuntando > 0.0:
		apuntando -= delta
		velocity.x = move_toward(velocity.x, 0.0, desaceleracion * delta)
		move_and_slide()
		if sprite != null:
			sprite.modulate = Color(1.0, 0.65, 0.85, 1.0)
		if apuntando <= 0.0:
			disparar()
		return

	if sprite != null:
		sprite.modulate = Color(0.66, 0.45, 0.95, 1.0)

	cambio_strife -= delta
	if cambio_strife <= 0.0:
		sentido_strife *= -1.0
		cambio_strife = randf_range(0.8, 1.6)

	var objetivo := jugador.global_position
	if jugador is CharacterBody2D:
		objetivo += jugador.velocity * 0.22
	var dx := objetivo.x - global_position.x
	var dy := absf(objetivo.y - global_position.y)
	var dir := signf(dx)
	if dir == 0.0:
		dir = sentido_strife

	# El tirador intenta conservar distancia, pero se mueve lateralmente para no ser predecible.
	var movimiento := 0.0
	if distancia < distancia_minima_segura:
		movimiento = -dir * velocidad
	elif distancia > distancia_preferida + 35.0:
		movimiento = dir * velocidad
	else:
		movimiento = sentido_strife * velocidad * 0.55
		if absf(dy) > 85.0:
			movimiento = dir * velocidad * 0.7

	velocity.x = move_toward(velocity.x, movimiento, aceleracion * delta)
	move_and_slide()

	if sprite != null:
		if absf(velocity.x) > 1.0:
			sprite.flip_h = velocity.x < 0.0
			sprite.play("run")
		else:
			sprite.play("idle")

	if distancia <= alcance_disparo and puede_atacar and dy < 120.0:
		apuntando = tiempo_apuntar
		puede_atacar = false

func disparar() -> void:
	if jugador == null or not is_instance_valid(jugador):
		puede_atacar = true
		return
	if _puede_ver_al_jugador() and global_position.distance_to(jugador.global_position) <= alcance_disparo and jugador.has_method("recibir_dano"):
		jugador.recibir_dano(dano, global_position)
	await get_tree().create_timer(tiempo_entre_ataques).timeout
	if is_instance_valid(self) and not esta_muerto:
		puede_atacar = true
