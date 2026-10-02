extends CharacterBody2D

## HEART OF THE WORLD — Enemy Basic AI v2
## IA de combate contextual: percepción, memoria, patrulla local,
## predicción de movimiento, separación entre enemigos y prevención de caídas.
## Godot 4.7

signal enemigo_derrotado_local(id: String)

enum State { IDLE, PATROL, CHASE, INVESTIGATE, ATTACK, HURT, DEAD }
var state: State = State.IDLE

@export_category("Movimiento")
@export var velocidad: float = 90.0
@export var aceleracion: float = 720.0
@export var desaceleracion: float = 980.0
@export var gravedad: float = 1200.0
@export var distancia_ataque: float = 55.0
@export var distancia_deteccion: float = 450.0
@export var distancia_perdida: float = 620.0
@export var evitar_caida: bool = true

@export_category("Inteligencia")
@export var usar_ia_avanzada: bool = true
@export var tiempo_memoria: float = 1.8
@export var tiempo_prediccion: float = 0.18
@export var radio_separacion: float = 72.0
@export var fuerza_separacion: float = 95.0
@export var radio_patrulla: float = 130.0
@export var tiempo_patrulla: float = 1.8
@export var tiempo_investigacion: float = 1.6
@export var distancia_vertical_ataque: float = 78.0
@export var intervalo_decision: float = 0.10
@export var angulo_vision: float = 145.0
@export var radio_escucha: float = 260.0
@export var velocidad_minima_ruido: float = 55.0
@export var max_atacantes_grupo: int = 2
@export var radio_coordinacion: float = 190.0
@export var distancia_flanco: float = 115.0
@export var usar_navegacion_opcional: bool = true

@export_category("Salud y Combate")
@export var hp_maxima: int = 50
@export var dano: int = 10
@export var tiempo_entre_ataques: float = 1.0
@export var empuje_recibido: float = 180.0
@export var tiempo_flash: float = 0.12
@export var tiempo_preparacion_ataque: float = 0.18

@export_category("Recompensa")
@export var recompensa_scene: PackedScene = preload("res://scenes/recompensa.tscn")
@export var recompensa_cantidad: int = 1

var jugador: Node2D = null
var hp_actual: int = 0
var puede_atacar: bool = true
var atacando: bool = false
var esta_muerto: bool = false

var posicion_inicial: Vector2
var objetivo_patrulla: Vector2
var patrulla_timer: float = 0.0
var memoria_timer: float = 0.0
var investigacion_timer: float = 0.0
var ultima_posicion_jugador: Vector2 = Vector2.ZERO
var decision_timer: float = 0.0
var direccion_mirando: float = 1.0
var tiempo_espera_idle: float = 0.0
var alarma_activa: bool = false
var tiempo_alarma: float = 0.0
var agente_navegacion: NavigationAgent2D = null

@onready var sprite: AnimatedSprite2D = get_node_or_null("AnimatedSprite2D") as AnimatedSprite2D
@onready var health_bar: ProgressBar = get_node_or_null("HealthBar") as ProgressBar

func _ready() -> void:
	add_to_group("enemy")
	add_to_group("enemies")

	posicion_inicial = global_position
	objetivo_patrulla = global_position
	patrulla_timer = randf_range(0.5, tiempo_patrulla)

	if has_node("/root/GameState"):
		hp_maxima = maxi(1, int(round(float(hp_maxima) * GameState.multiplicador_vida_enemigo)))
		dano = maxi(1, int(round(float(dano) * GameState.multiplicador_dano_enemigo)))
		recompensa_cantidad = maxi(1, int(round(float(recompensa_cantidad) * GameState.multiplicador_recompensa)))

	hp_actual = hp_maxima
	actualizar_barra_vida()
	_configurar_navegacion()
	reproducir_animacion("idle")
	jugador = get_tree().get_first_node_in_group("player") as Node2D
	state = State.IDLE

func change_state(new_state: State) -> void:
	cambiar_estado(new_state)

func cambiar_estado(nuevo_estado: State) -> void:
	if state == nuevo_estado:
		return
	state = nuevo_estado
	match state:
		State.IDLE:
			atacando = false
			reproducir_animacion("idle")
		State.PATROL:
			atacando = false
		State.CHASE:
			atacando = false
		State.INVESTIGATE:
			atacando = false
		State.ATTACK:
			atacando = true
		State.HURT:
			reproducir_animacion("hurt")
		State.DEAD:
			esta_muerto = true
			atacando = false
			puede_atacar = false

func _physics_process(delta: float) -> void:
	if esta_muerto or state == State.DEAD:
		return

	if jugador == null or not is_instance_valid(jugador):
		jugador = get_tree().get_first_node_in_group("player") as Node2D
		velocity.x = move_toward(velocity.x, 0.0, desaceleracion * delta)
		aplicar_gravedad(delta)
		move_and_slide()
		reproducir_animacion("idle")
		return

	decision_timer = maxf(decision_timer - delta, 0.0)
	if memoria_timer > 0.0:
		memoria_timer = maxf(memoria_timer - delta, 0.0)
	if investigacion_timer > 0.0:
		investigacion_timer = maxf(investigacion_timer - delta, 0.0)

	var distancia := global_position.distance_to(jugador.global_position)
	var puede_ver := _puede_ver_al_jugador()
	var puede_oir := _puede_oir_al_jugador()

	if puede_ver:
		ultima_posicion_jugador = jugador.global_position
		memoria_timer = tiempo_memoria
		alarma_activa = true
		tiempo_alarma = 2.4
	elif puede_oir:
		ultima_posicion_jugador = jugador.global_position
		memoria_timer = maxf(memoria_timer, tiempo_memoria * 0.75)
		alarma_activa = true
		tiempo_alarma = 2.4

	if tiempo_alarma > 0.0:
		tiempo_alarma = maxf(tiempo_alarma - delta, 0.0)
	else:
		alarma_activa = false

	match state:
		State.IDLE, State.PATROL:
			procesar_movimiento_ia(delta, distancia, puede_ver, puede_oir)
		State.CHASE:
			procesar_movimiento_ia(delta, distancia, puede_ver, puede_oir)
		State.INVESTIGATE:
			procesar_investigacion(delta, distancia, puede_ver, puede_oir)
		State.ATTACK:
			procesar_ataque(delta)
		State.HURT:
			procesar_herido(delta)
		State.DEAD:
			return

func procesar_movimiento(delta: float, distancia: float) -> void:
	# Compatibilidad con variantes antiguas.
	procesar_movimiento_ia(delta, distancia, _puede_ver_al_jugador())

func procesar_movimiento_ia(delta: float, distancia: float, puede_ver: bool, puede_oir: bool = false) -> void:
	aplicar_gravedad(delta)

	if (puede_ver or puede_oir) and distancia <= distancia_deteccion:
		if puede_ver and _puede_atacar_por_posicion() and _puedo_tomar_turno_de_ataque():
			velocity.x = move_toward(velocity.x, 0.0, desaceleracion * delta)
			move_and_slide()
			if puede_atacar and not atacando:
				cambiar_estado(State.ATTACK)
				atacar()
			return

		if puede_ver:
			cambiar_estado(State.CHASE)
			perseguir()
		else:
			cambiar_estado(State.INVESTIGATE)
			investigacion_timer = maxf(investigacion_timer, tiempo_investigacion)
			procesar_investigacion(delta, distancia, puede_ver, puede_oir)
		return

	if state == State.CHASE and memoria_timer > 0.0:
		cambiar_estado(State.INVESTIGATE)
		investigacion_timer = tiempo_investigacion
		return

	if state == State.INVESTIGATE:
		procesar_investigacion(delta, distancia, puede_ver)
		return

	if usar_ia_avanzada:
		procesar_patrulla(delta)
	else:
		velocity.x = move_toward(velocity.x, 0.0, desaceleracion * delta)
		move_and_slide()
		reproducir_animacion("idle")

func procesar_investigacion(delta: float, distancia: float, puede_ver: bool, puede_oir: bool = false) -> void:
	if puede_ver and distancia <= distancia_deteccion:
		memoria_timer = tiempo_memoria
		alarma_activa = true
		cambiar_estado(State.CHASE)
		return

	if puede_oir:
		ultima_posicion_jugador = jugador.global_position
		memoria_timer = maxf(memoria_timer, tiempo_memoria * 0.75)

	aplicar_gravedad(delta)
	var distancia_objetivo := global_position.distance_to(ultima_posicion_jugador)
	if distancia_objetivo > 22.0 and investigacion_timer > 0.0:
		var dir := signf(ultima_posicion_jugador.x - global_position.x)
		if dir == 0.0:
			dir = direccion_mirando
		var velocidad_objetivo := velocidad * 0.82
		if _hay_suelo_delante(dir):
			velocity.x = move_toward(velocity.x, dir * velocidad_objetivo, aceleracion * delta)
		else:
			velocity.x = move_toward(velocity.x, 0.0, desaceleracion * delta)
		if absf(velocity.x) > 1.0:
			direccion_mirando = signf(velocity.x)
			if is_instance_valid(sprite):
				sprite.flip_h = direccion_mirando < 0.0
				sprite.play("run")
		move_and_slide()
		return

	investigacion_timer = 0.0
	cambiar_estado(State.PATROL)
	procesar_patrulla(delta)

func procesar_patrulla(delta: float) -> void:
	if not usar_ia_avanzada:
		return
	aplicar_gravedad(delta)
	patrulla_timer -= delta

	if tiempo_espera_idle > 0.0:
		tiempo_espera_idle -= delta
		velocity.x = move_toward(velocity.x, 0.0, desaceleracion * delta)
		move_and_slide()
		reproducir_animacion("idle")
		return

	if global_position.distance_to(objetivo_patrulla) < 18.0 or patrulla_timer <= 0.0:
		var nuevo_x := posicion_inicial.x + randf_range(-radio_patrulla, radio_patrulla)
		objetivo_patrulla = Vector2(nuevo_x, global_position.y)
		patrulla_timer = randf_range(1.0, tiempo_patrulla)
		if randf() < 0.30:
			tiempo_espera_idle = randf_range(0.35, 1.1)

	var dir := signf(objetivo_patrulla.x - global_position.x)
	if dir == 0.0:
		dir = direccion_mirando
	if _hay_suelo_delante(dir):
		velocity.x = move_toward(velocity.x, dir * velocidad * 0.55, aceleracion * delta)
	else:
		objetivo_patrulla.x = global_position.x - dir * 30.0
		velocity.x = move_toward(velocity.x, 0.0, desaceleracion * delta)
	move_and_slide()
	if absf(velocity.x) > 1.0:
		direccion_mirando = signf(velocity.x)
		if is_instance_valid(sprite):
			sprite.flip_h = direccion_mirando < 0.0
			sprite.play("run")
	else:
		reproducir_animacion("idle")

func procesar_ataque(_delta: float) -> void:
	velocity.x = move_toward(velocity.x, 0.0, desaceleracion * _delta)
	move_and_slide()

func procesar_herido(delta: float) -> void:
	velocity.x = move_toward(velocity.x, 0.0, 900.0 * delta)
	aplicar_gravedad(delta)
	move_and_slide()

func perseguir() -> void:
	if jugador == null or not is_instance_valid(jugador):
		return
	var objetivo := jugador.global_position
	if jugador is CharacterBody2D:
		objetivo += jugador.velocity * tiempo_prediccion

	var atacantes := _contar_atacantes_cercanos()
	if atacantes > 0:
		var lado := -1.0 if (get_instance_id() % 2) == 0 else 1.0
		objetivo.x += lado * distancia_flanco

	if agente_navegacion != null and NavigationServer2D.map_get_iteration_id(agente_navegacion.get_navigation_map()) > 0:
		agente_navegacion.target_position = objetivo
		var siguiente := agente_navegacion.get_next_path_position()
		if siguiente != Vector2.ZERO:
			objetivo = siguiente

	var dir_x := signf(objetivo.x - global_position.x)
	if dir_x == 0.0:
		dir_x = direccion_mirando

	var separacion := _calcular_separacion()
	var objetivo_velocidad := dir_x * velocidad + separacion
	if not _hay_suelo_delante(dir_x):
		objetivo_velocidad = 0.0
	velocity.x = move_toward(velocity.x, objetivo_velocidad, aceleracion * get_physics_process_delta_time())
	if absf(velocity.x) > 1.0:
		direccion_mirando = signf(velocity.x)
		if is_instance_valid(sprite):
			sprite.flip_h = direccion_mirando < 0.0
			sprite.play("run")
	aplicar_gravedad(get_physics_process_delta_time())
	move_and_slide()

func _perseguir() -> void:
	perseguir()

func _configurar_navegacion() -> void:
	if not usar_navegacion_opcional or agente_navegacion != null:
		return
	agente_navegacion = NavigationAgent2D.new()
	agente_navegacion.name = "EnemyNavigationAgent"
	agente_navegacion.path_desired_distance = 18.0
	agente_navegacion.target_desired_distance = 20.0
	agente_navegacion.radius = 16.0
	agente_navegacion.avoidance_enabled = true
	agente_navegacion.path_max_distance = 700.0
	add_child(agente_navegacion)

func _puede_ver_al_jugador() -> bool:
	if jugador == null or not is_instance_valid(jugador):
		return false
	var vector_objetivo := jugador.global_position - global_position
	var distancia := vector_objetivo.length()
	if distancia > distancia_deteccion or distancia <= 0.1:
		return false
	var direccion_objetivo := vector_objetivo.normalized()
	var direccion_frente := Vector2(direccion_mirando, 0.0)
	var limite := cos(deg_to_rad(angulo_vision * 0.5))
	var dentro_cono := direccion_frente.dot(direccion_objetivo) >= limite or distancia < 85.0
	if not dentro_cono:
		return false
	var query := PhysicsRayQueryParameters2D.create(global_position + Vector2(0.0, -8.0), jugador.global_position + Vector2(0.0, -8.0), 1)
	query.exclude = [self]
	var resultado := get_world_2d().direct_space_state.intersect_ray(query)
	return resultado.is_empty()

func _puede_oir_al_jugador() -> bool:
	if jugador == null or not is_instance_valid(jugador):
		return false
	var distancia := global_position.distance_to(jugador.global_position)
	if distancia > radio_escucha:
		return false
	if jugador is CharacterBody2D:
		return jugador.velocity.length() >= velocidad_minima_ruido
	return false

func _contar_atacantes_cercanos() -> int:
	var total := 0
	for otro in get_tree().get_nodes_in_group("enemies"):
		if otro == self or not is_instance_valid(otro):
			continue
		if global_position.distance_to(otro.global_position) > radio_coordinacion:
			continue
		if bool(otro.get("atacando")):
			total += 1
	return total

func _puedo_tomar_turno_de_ataque() -> bool:
	return _contar_atacantes_cercanos() < max_atacantes_grupo

func _puede_atacar_por_posicion() -> bool:
	if jugador == null or not is_instance_valid(jugador):
		return false
	var dx := absf(jugador.global_position.x - global_position.x)
	var dy := absf(jugador.global_position.y - global_position.y)
	return dx <= distancia_ataque and dy <= distancia_vertical_ataque

func _hay_suelo_delante(direccion: float) -> bool:
	if not evitar_caida or not is_on_floor() or direccion == 0.0:
		return true
	var origen := global_position + Vector2(direccion * 24.0, 8.0)
	var destino := origen + Vector2(0.0, 76.0)
	var query := PhysicsRayQueryParameters2D.create(origen, destino, 1)
	query.exclude = [self]
	var resultado := get_world_2d().direct_space_state.intersect_ray(query)
	return not resultado.is_empty()

func _calcular_separacion() -> float:
	var fuerza := 0.0
	for otro in get_tree().get_nodes_in_group("enemies"):
		if otro == self or not is_instance_valid(otro):
			continue
		var distancia := global_position.distance_to(otro.global_position)
		if distancia > 0.1 and distancia < radio_separacion:
			var direccion := signf(global_position.x - otro.global_position.x)
			if direccion == 0.0:
				direccion = 1.0 if randf() > 0.5 else -1.0
			fuerza += direccion * (1.0 - distancia / radio_separacion) * fuerza_separacion
	return clampf(fuerza, -velocidad * 0.75, velocidad * 0.75)

func aplicar_gravedad(delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravedad * delta
	else:
		velocity.y = 0.0

func _aplicar_gravedad(delta: float) -> void:
	aplicar_gravedad(delta)

func atacar() -> void:
	if esta_muerto or atacando or not puede_atacar:
		return
	atacando = true
	puede_atacar = false
	reproducir_animacion("attack")
	await get_tree().create_timer(tiempo_preparacion_ataque).timeout
	if not is_instance_valid(self) or esta_muerto:
		return
	if jugador != null and is_instance_valid(jugador) and _puede_atacar_por_posicion():
		if jugador.has_method("recibir_dano"):
			jugador.recibir_dano(dano, global_position)
	await get_tree().create_timer(0.10).timeout
	if not is_instance_valid(self) or esta_muerto:
		return
	atacando = false
	if state == State.ATTACK:
		cambiar_estado(State.CHASE)
	await get_tree().create_timer(tiempo_entre_ataques).timeout
	if is_instance_valid(self) and not esta_muerto:
		puede_atacar = true

func _timer_hurt_terminado() -> void:
	if is_instance_valid(self) and state == State.HURT and not esta_muerto:
		cambiar_estado(State.CHASE)

func recibir_dano(cantidad: int, origen_dano: Vector2 = Vector2.ZERO) -> void:
	if esta_muerto:
		return
	hp_actual = maxi(hp_actual - cantidad, 0)
	actualizar_barra_vida()
	mostrar_dano(cantidad)
	if is_instance_valid(sprite):
		sprite.modulate = Color(1.0, 0.45, 0.45, 1.0)
		get_tree().create_timer(tiempo_flash).timeout.connect(_quitar_flash, CONNECT_ONE_SHOT)
	if origen_dano != Vector2.ZERO:
		var dir := signf(global_position.x - origen_dano.x)
		if dir == 0.0:
			dir = 1.0
		velocity.x = dir * empuje_recibido
	if hp_actual <= 0:
		ejecutar_muerte()
	else:
		memoria_timer = tiempo_memoria
		ultima_posicion_jugador = origen_dano
		cambiar_estado(State.HURT)
		get_tree().create_timer(0.25).timeout.connect(_timer_hurt_terminado, CONNECT_ONE_SHOT)

func _quitar_flash() -> void:
	if not is_instance_valid(self) or not is_instance_valid(sprite) or esta_muerto:
		return
	sprite.modulate = Color.WHITE

func mostrar_dano(cantidad: int) -> void:
	var etiqueta := Label.new()
	etiqueta.text = "-" + str(cantidad)
	etiqueta.position = Vector2(-18, -78)
	etiqueta.z_index = 20
	etiqueta.add_theme_font_size_override("font_size", 18)
	etiqueta.modulate = Color(1.0, 0.82, 0.88, 1.0)
	add_child(etiqueta)
	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(etiqueta, "position:y", -108.0, 0.45)
	tween.tween_property(etiqueta, "modulate:a", 0.0, 0.45)
	tween.set_parallel(false)
	tween.tween_callback(etiqueta.queue_free)

func aplicar_balance_especifico() -> void:
	if not has_node("/root/GameState"):
		return
	hp_maxima = maxi(1, int(round(float(hp_maxima) * GameState.multiplicador_vida_enemigo)))
	dano = maxi(1, int(round(float(dano) * GameState.multiplicador_dano_enemigo)))
	hp_actual = hp_maxima

func actualizar_barra_vida() -> void:
	if not is_instance_valid(health_bar):
		return
	health_bar.min_value = 0
	health_bar.max_value = hp_maxima
	health_bar.value = hp_actual
	health_bar.visible = hp_actual < hp_maxima

func ejecutar_muerte() -> void:
	if esta_muerto:
		return
	esta_muerto = true
	state = State.DEAD
	velocity = Vector2.ZERO
	if is_instance_valid(health_bar):
		health_bar.visible = false
	reproducir_animacion("death")
	if is_instance_valid(sprite) and sprite.sprite_frames != null and sprite.sprite_frames.has_animation("death"):
		await sprite.animation_finished
	else:
		await get_tree().create_timer(0.35).timeout
	if not is_instance_valid(self):
		return
	if has_node("/root/GameState"):
		GameState.registrar_enemigo_derrotado(name)
	enemigo_derrotado_local.emit(name)
	soltar_recompensa()
	queue_free()

func soltar_recompensa() -> void:
	if recompensa_scene == null:
		return
	var drop = recompensa_scene.instantiate()
	if drop == null:
		return
	drop.global_position = global_position
	if "cantidad" in drop:
		drop.cantidad = recompensa_cantidad
	get_parent().add_child(drop)

func reproducir_animacion(nombre: String) -> void:
	if not is_instance_valid(sprite) or sprite.sprite_frames == null:
		return
	if not sprite.sprite_frames.has_animation(nombre):
		return
	if sprite.animation != nombre or not sprite.is_playing():
		sprite.play(nombre)
