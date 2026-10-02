extends "res://scripts/enemies/enemy_basic.gd"

@export var alcance_eco: float = 430.0
@export var cooldown_eco: float = 1.7
@export var distancia_preferida: float = 245.0
var puede_eco: bool = true
var sentido: float = 1.0
var cambio_sentido: float = 0.0

func _ready() -> void:
	super._ready()
	hp_maxima = 95
	hp_actual = hp_maxima
	dano = 14
	velocidad = 55.0
	distancia_deteccion = 650.0
	recompensa_cantidad = 3
	cambio_sentido = randf_range(0.8, 1.8)
	if sprite != null:
		sprite.modulate = Color(0.72, 0.45, 0.86, 1.0)
	aplicar_balance_especifico()
	actualizar_barra_vida()

func _physics_process(delta: float) -> void:
	if esta_muerto:
		return
	if jugador == null or not is_instance_valid(jugador):
		jugador = get_tree().get_first_node_in_group("player")
		return

	var dx: float = jugador.global_position.x - global_position.x
	var distancia: float = global_position.distance_to(jugador.global_position)
	var visible_objetivo := _puede_ver_al_jugador()
	_aplicar_gravedad(delta)

	if distancia > distancia_deteccion or not visible_objetivo:
		procesar_movimiento_ia(delta, distancia, visible_objetivo)
		return

	cambio_sentido -= delta
	if cambio_sentido <= 0.0:
		sentido *= -1.0
		cambio_sentido = randf_range(0.8, 1.7)

	var movimiento := 0.0
	if distancia > distancia_preferida + 55.0:
		movimiento = signf(dx) * velocidad
	elif distancia < distancia_preferida - 55.0:
		movimiento = -signf(dx) * velocidad
	else:
		movimiento = sentido * velocidad * 0.7

	velocity.x = move_toward(velocity.x, movimiento, aceleracion * delta)
	move_and_slide()
	if sprite != null:
		if absf(velocity.x) > 1.0:
			sprite.flip_h = velocity.x < 0.0
			sprite.play("run")
		else:
			sprite.play("idle")

	if puede_eco and absf(dx) <= alcance_eco and absf(jugador.global_position.y - global_position.y) < 110.0:
		disparar_eco(1.0 if dx >= 0.0 else -1.0)

func disparar_eco(direccion: float) -> void:
	puede_eco = false
	var escena_onda: PackedScene = preload("res://scenes/enemy_tejedor_eco_wave.tscn")
	var onda: Node = escena_onda.instantiate()
	onda.global_position = global_position + Vector2(62.0 * direccion, -4.0)
	onda.set("direccion", direccion)
	onda.set("dano", dano)
	get_parent().add_child(onda)
	await get_tree().create_timer(cooldown_eco).timeout
	if is_instance_valid(self) and not esta_muerto:
		puede_eco = true
