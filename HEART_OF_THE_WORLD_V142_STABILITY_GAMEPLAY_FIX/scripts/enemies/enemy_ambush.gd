extends "res://scripts/enemies/enemy_basic.gd"

@export var distancia_activacion: float = 220.0
@export var velocidad_retirada: float = 180.0
@export var distancia_retirada: float = 115.0
var activado: bool = false
var retiro: float = 0.0
var ataque_emboscada: bool = false

func _ready() -> void:
	super._ready()
	sprite.modulate = Color(0.72, 0.62, 0.86, 0.55)

func _physics_process(delta: float) -> void:
	if esta_muerto:
		return
	if jugador == null or not is_instance_valid(jugador):
		jugador = get_tree().get_first_node_in_group("player")
		_aplicar_gravedad(delta)
		move_and_slide()
		return

	var distancia := global_position.distance_to(jugador.global_position)
	if not activado:
		velocity.x = 0.0
		_aplicar_gravedad(delta)
		move_and_slide()
		reproducir_animacion("idle")
		if distancia <= distancia_activacion and _puede_ver_al_jugador():
			activado = true
			sprite.modulate = Color.WHITE
			ataque_emboscada = true
			if puede_atacar:
				atacar()
		return

	if ataque_emboscada:
		# Después del primer golpe se reposiciona antes de volver a atacar.
		if not atacando:
			ataque_emboscada = false
			retiro = 0.42
		return

	if retiro > 0.0:
		retiro -= delta
		var dir := signf(global_position.x - jugador.global_position.x)
		if dir == 0.0:
			dir = -1.0 if jugador.global_position.x >= global_position.x else 1.0
		if _hay_suelo_delante(dir):
			velocity.x = move_toward(velocity.x, dir * velocidad_retirada, aceleracion * delta)
		else:
			velocity.x = 0.0
		_aplicar_gravedad(delta)
		move_and_slide()
		if absf(velocity.x) > 1.0:
			sprite.flip_h = velocity.x < 0.0
		reproducir_animacion("run")
		return

	if distancia <= distancia_retirada and not atacando:
		retiro = 0.5
		return

	super._physics_process(delta)

func atacar() -> void:
	if ataque_emboscada and not puede_atacar:
		return
	super.atacar()
