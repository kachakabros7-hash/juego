extends "res://scripts/enemies/enemy_basic.gd"

@export var velocidad_carga: float = 330.0
@export var duracion_carga: float = 0.38
@export var distancia_minima_carga: float = 105.0
@export var distancia_maxima_carga: float = 420.0
var carga: float = 0.0
var direccion_carga: float = 0.0
var carga_lista: bool = false
var puede_cargar: bool = true

func _ready() -> void:
	super._ready()
	hp_maxima = 90
	hp_actual = hp_maxima
	dano = 16
	velocidad = 105.0
	distancia_deteccion = 600.0
	tiempo_entre_ataques = 1.15
	aplicar_balance_especifico()
	actualizar_barra_vida()
	sprite.modulate = Color(0.92, 0.62, 0.35, 1.0)

func _physics_process(delta: float) -> void:
	if carga > 0.0:
		carga -= delta
		velocity.x = direccion_carga * velocidad_carga
		_aplicar_gravedad(delta)
		move_and_slide()
		if sprite != null:
			sprite.flip_h = direccion_carga < 0.0
			sprite.play("run")
		if carga <= 0.0:
			carga_lista = false
			velocity.x = 0.0
			atacando = false
			puede_cargar = false
			await get_tree().create_timer(tiempo_entre_ataques).timeout
			if is_instance_valid(self) and not esta_muerto:
				puede_cargar = true
		return

	if jugador != null and is_instance_valid(jugador) and not atacando and puede_cargar:
		var distancia := global_position.distance_to(jugador.global_position)
		var dy := absf(jugador.global_position.y - global_position.y)
		if distancia >= distancia_minima_carga and distancia <= distancia_maxima_carga and dy < 90.0 and _puede_ver_al_jugador():
			# Solo carga si hay suelo delante; evita suicidarse contra un vacío.
			var dir := signf(jugador.global_position.x - global_position.x)
			if dir == 0.0:
				dir = direccion_mirando
			if _hay_suelo_delante(dir):
				iniciar_carga(dir)
				return

	super._physics_process(delta)

func iniciar_carga(dir: float) -> void:
	if not puede_cargar or carga > 0.0 or esta_muerto:
		return
	direccion_carga = dir
	carga = duracion_carga
	carga_lista = true
	puede_cargar = false
	atacando = true
	reproducir_animacion("attack")

func atacar() -> void:
	# Si está muy lejos, el comportamiento especializado decide usar carga.
	if jugador != null and is_instance_valid(jugador):
		var distancia := global_position.distance_to(jugador.global_position)
		if distancia > distancia_ataque and puede_cargar:
			var dir := signf(jugador.global_position.x - global_position.x)
			if dir == 0.0:
				dir = direccion_mirando
			iniciar_carga(dir)
			return
	super.atacar()
