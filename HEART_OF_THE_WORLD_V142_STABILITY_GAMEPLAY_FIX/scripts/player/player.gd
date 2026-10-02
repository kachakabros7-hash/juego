extends CharacterBody2D


# ============================================================
# MOVIMIENTO HORIZONTAL
# ============================================================

@export_category("Movimiento Horizontal")

@export var velocidad_maxima: float = 235.0
@export var aceleracion: float = 1500.0
@export var friccion: float = 1300.0
@export_category("Cámara")
@export var camara_anticipacion: float = 82.0
@export var camara_suavizado_anticipacion: float = 6.0
@export var camara_altura_aire: float = 18.0


# ============================================================
# FÍSICA DE SALTO
# ============================================================

@export_category("Física de Salto")

@export var fuerza_salto: float = -800.0
@export var gravedad_base: float = 950.0
@export var multiplicador_caida: float = 1.35
@export var coyote_time: float = 0.18
@export var jump_buffer_time: float = 0.15


# ============================================================
# DASH
# ============================================================

@export_category("Dash")

@export var velocidad_dash: float = 720.0
@export var duracion_dash: float = 0.20
@export var cooldown_dash: float = 0.45


# ============================================================
# GARRA TREPADORA
# ============================================================

@export_category("Garra Trepadora")

@export var velocidad_deslizamiento_muro: float = 145.0
@export var fuerza_salto_muro: Vector2 = Vector2(500.0, -680.0)


# ============================================================
# EMBESTIDA CRISTALINA
# ============================================================

@export_category("Embestida Cristalina")

@export var velocidad_corazon_cristal: float = 1050.0
@export var duracion_corazon_cristal: float = 0.72
@export var carga_corazon_cristal: float = 0.65
@export var cooldown_corazon_cristal: float = 1.0


# ============================================================
# PASO UMBRÍO
# ============================================================

@export_category("Paso Umbrío")

@export var duracion_capa_sombria: float = 0.45
@export var cooldown_capa_sombria: float = 1.1

# ============================================================
# IMPULSO DE RAÍZ — RECOMPENSA DEL GUARDIÁN
# ============================================================

@export_category("Impulso de Raíz")
@export var fuerza_impulso_raiz: float = -1180.0
@export var cooldown_impulso_raiz: float = 1.6
@export var duracion_invulnerabilidad_raiz: float = 0.32


# ============================================================
# SALUD Y COMBATE
# ============================================================

@export_category("Salud y Combate")

@export var hp_maxima: int = 100
@export var dano_ataque: int = 25
@export var tiempo_invulnerabilidad: float = 0.6


# ============================================================
# VARIABLES
# ============================================================

var direccion: float = 0.0

var hp_actual: int = 100

var saltos_realizados: int = 0
var saltos_maximos: int = 1

var haciendo_dash: bool = false
var puede_hacer_dash: bool = true

var deslizandose_muro: bool = false
var cargando_corazon: bool = false
var corazon_en_vuelo: bool = false
var tiempo_cargando_corazon: float = 0.0
var tiempo_corazon_vuelo: float = 0.0
var puede_usar_corazon: bool = true

var capa_sombria_activa: bool = false
var puede_usar_capa_sombria: bool = true
var inmunidad_acido: bool = false
var puede_usar_impulso_raiz: bool = true
var tiempo_impulso_raiz: float = 0.0
var impulso_raiz_activo: bool = false

var es_invulnerable: bool = false

var esta_atacando: bool = false
var haciendo_parry: bool = false
var parry_consumido: bool = false
var esta_muerto: bool = false
var esta_herido: bool = false
var victoria_activa: bool = false
var nivel_arma: int = 1

# ============================================================
# SISTEMA DE ANIMACIONES SHAIA
# ============================================================
# Estas variables permiten usar las animaciones originales del paquete
# dentro del juego, no solo tenerlas guardadas en SpriteFrames.
var animacion_ataque_actual: String = "attack_1"
var indice_combo: int = 0
var tiempo_combo: float = 0.0
var tiempo_buffer_ataque: float = 0.0
@export var ventana_buffer_ataque: float = 0.14
var tiempo_landing: float = 0.0
var estaba_en_aire: bool = false
var animacion_estado: String = ""
var tiempo_animacion_estado: float = 0.0
var velocidad_x_anterior: float = 0.0
var ultimo_signo_direccion: float = 0.0
var camara_offset_objetivo: Vector2 = Vector2.ZERO

var coyote_time_valido: bool = false
var jump_buffer_activo: bool = false


# ============================================================
# REFERENCIAS A NODOS
# ============================================================

@onready var sprite: AnimatedSprite2D = $MishaVisual

@onready var coyote_timer: Timer = $CoyoteTimer
@onready var camara: Camera2D = get_node_or_null("Camera2D") as Camera2D

@onready var jump_buffer_timer: Timer = $JumpBufferTimer

@onready var invulnerability_timer: Timer = $InvulnerabilityTimer

@onready var area_ataque: Area2D = $AreaAtaque

@onready var colision_ataque: CollisionShape2D = $AreaAtaque/CollisionShape2D
@onready var area_parry: Area2D = $AreaParry

# BARRA DE VIDA
@onready var health_bar: ProgressBar = $CanvasLayer/HealthBar
@onready var coin_label: Label = $CanvasLayer/CoinLabel
@onready var ability_label: Label = $CanvasLayer/AbilityLabel
@onready var status_label: Label = $CanvasLayer/StatusLabel
@onready var ranged_attack: Node = $RangedAttack


# ============================================================
# INICIO
# ============================================================

func _ready() -> void:

	add_to_group("player")

	# Permite cerrar ataques y animaciones especiales exactamente cuando
	# termina la animación original, sin depender de tiempos inventados.
	if not sprite.animation_finished.is_connected(_on_sprite_animation_finished):
		sprite.animation_finished.connect(_on_sprite_animation_finished)

	_resolver_spawn()

	visible = true
	sprite.visible = true
	sprite.modulate = Color.WHITE
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST

	if camara != null:
		camara.enabled = true
		call_deferred("_ajustar_camara_inicial")


	# ========================================================
	# APLICAR MEJORAS YA COMPRADAS
	# ========================================================

	hp_maxima += GameState.mejora_vida * 25
	hp_maxima += GameState.bonus_vida_fragmentos
	GameState.vida_maxima = hp_maxima
	nivel_arma = GameState.nivel_arma
	dano_ataque = GameState.obtener_dano_arma()
	velocidad_dash += GameState.mejora_dash * 100

	# El dash solo se habilita cuando Misha consigue la habilidad.
	puede_hacer_dash = GameState.tiene_habilidad("dash")
	inmunidad_acido = GameState.tiene_habilidad("isma_tear")

	# ========================================================
	# VIDA
	# ========================================================

	if GameState.vida_actual > 0:

		hp_actual = clamp(
			GameState.vida_actual,
			1,
			hp_maxima
		)

	else:

		hp_actual = hp_maxima


	GameState.vida_maxima = hp_maxima
	GameState.vida_actual = hp_actual


	# ========================================================
	# BARRA DE VIDA
	# ========================================================

	if health_bar != null:
		health_bar.min_value = 0
		health_bar.max_value = hp_maxima
		health_bar.value = hp_actual
		health_bar.visible = true


	# ========================================================
	# ATAQUE DESACTIVADO AL COMENZAR
	# ========================================================

	colision_ataque.set_deferred(
		"disabled",
		true
	)


	# ========================================================
	# DOBLE SALTO
	# ========================================================

	if GameState.tiene_habilidad("double_jump"):

		saltos_maximos = 2

	actualizar_contador_monedas()
	actualizar_hud_habilidades()


	# ========================================================

func _resolver_spawn() -> void:
	var posicion_aplicada: bool = false
	var spawn_nombre: String = GameState.punto_spawn

	if spawn_nombre != "":
		var spawn_node: Node = get_parent().get_node_or_null(spawn_nombre)
		if spawn_node is Node2D:
			global_position = spawn_node.global_position
			posicion_aplicada = true
			GameState.punto_spawn = "PlayerSpawn"

	if not posicion_aplicada and GameState.posicion_spawn != Vector2.ZERO:
		global_position = GameState.posicion_spawn
		velocity = Vector2.ZERO
		GameState.posicion_spawn = Vector2.ZERO
		GameState.punto_spawn = "PlayerSpawn"

func _ajustar_camara_inicial() -> void:
	if not is_instance_valid(self):
		return
	var camara: Camera2D = get_node_or_null("Camera2D") as Camera2D
	if camara == null:
		return
	camara.enabled = true
	camara.reset_smoothing()
	camara.force_update_scroll()

# ============================================================
# ENTRADA DE JUGADOR
# Las animaciones externas se integrarán en un paso posterior.

func _unhandled_input(event: InputEvent) -> void:
	pass


# ============================================================
# FÍSICA PRINCIPAL
# ============================================================

func _physics_process(delta: float) -> void:

	if tiempo_buffer_ataque > 0.0:
		tiempo_buffer_ataque = maxf(tiempo_buffer_ataque - delta, 0.0)

	if tiempo_combo > 0.0:
		tiempo_combo = maxf(tiempo_combo - delta, 0.0)
		if tiempo_combo <= 0.0:
			indice_combo = 0

	if tiempo_landing > 0.0:
		tiempo_landing = maxf(tiempo_landing - delta, 0.0)

	if tiempo_animacion_estado > 0.0:
		tiempo_animacion_estado = maxf(tiempo_animacion_estado - delta, 0.0)
		if tiempo_animacion_estado <= 0.0:
			animacion_estado = ""

	if esta_muerto:

		return


	# ========================================================
	# DASH
	# ========================================================

	if haciendo_dash:

		es_invulnerable = true

		velocity.y = 0.0

		move_and_slide()

		return


	# ========================================================
	# EMBESTIDA CRISTALINA
	# ========================================================

	procesar_corazon_cristal()

	if corazon_en_vuelo:
		move_and_slide()
		return

	if cargando_corazon:
		return

	# ========================================================
	# PASO UMBRÍO
	# ========================================================

	procesar_capa_sombria()

	# ========================================================
	# IMPULSO DE RAÍZ
	# ========================================================

	procesar_impulso_raiz(delta)

	# ========================================================
	# MOVIMIENTO HORIZONTAL
	# ========================================================

	# Misha puede moverse mientras ataca
	# y también mientras está herida.

	procesar_movimiento_horizontal(delta)


	# ========================================================
	# GRAVEDAD
	# ========================================================

	aplicar_gravedad(delta)


	# ========================================================
	# GARRA TREPADORA
	# ========================================================

	procesar_garra_mantis()

	# ========================================================
	# SALTO
	# ========================================================

	procesar_salto()


	# ========================================================
	# DASH
	# ========================================================

	procesar_dash()


	# ========================================================
	# PARRY
	# ========================================================

	procesar_parry()

	# ========================================================
	# ATAQUE
	# ========================================================

	procesar_ataque()


	# ========================================================
	# ANIMACIONES
	# ========================================================

	actualizar_animaciones()
	actualizar_anticipacion_camara(delta)


	# ========================================================
	# MOVIMIENTO
	# ========================================================

	var estaba_en_suelo: bool = is_on_floor()

	move_and_slide()
	velocidad_x_anterior = velocity.x


	# ========================================================
	# COYOTE TIME
	# ========================================================

	if estaba_en_suelo and not is_on_floor() and velocity.y >= 0.0:

		coyote_time_valido = true

		coyote_timer.start(coyote_time)


	# ========================================================
	# CUANDO TOCA EL SUELO
	# ========================================================

	if is_on_floor():

		saltos_realizados = 0

		coyote_time_valido = false


		if jump_buffer_activo:

			ejecutar_salto()

			jump_buffer_activo = false


# ============================================================
# GRAVEDAD
# ============================================================

func actualizar_anticipacion_camara(delta: float) -> void:
	var camara := get_node_or_null("Camera2D") as Camera2D
	if camara == null:
		return
	var direccion_visual := 0.0
	if absf(velocity.x) > 8.0:
		direccion_visual = signf(velocity.x)
	elif direccion != 0.0:
		direccion_visual = signf(direccion)
	var objetivo_x := direccion_visual * camara_anticipacion
	var objetivo_y := -camara_altura_aire if not is_on_floor() else 0.0
	camara_offset_objetivo = Vector2(objetivo_x, objetivo_y)
	camara.position = camara.position.lerp(camara_offset_objetivo, clampf(delta * camara_suavizado_anticipacion, 0.0, 1.0))


func aplicar_gravedad(delta: float) -> void:

	if not is_on_floor():

		var gravedad_actual: float = gravedad_base

		if velocity.y > 0.0:

			gravedad_actual *= multiplicador_caida

		velocity.y += gravedad_actual * delta


# ============================================================
# MOVIMIENTO HORIZONTAL
# ============================================================

func procesar_impulso_raiz(delta: float) -> void:
	if tiempo_impulso_raiz > 0.0:
		tiempo_impulso_raiz = maxf(tiempo_impulso_raiz - delta, 0.0)
		if tiempo_impulso_raiz <= 0.0:
			puede_usar_impulso_raiz = true

	if not GameState.tiene_habilidad("root_burst"):
		return
	if not Input.is_action_just_pressed("impulso_raiz"):
		return
	if not puede_usar_impulso_raiz or not is_on_floor():
		return
	if esta_muerto or esta_atacando or haciendo_dash or haciendo_parry:
		return

	puede_usar_impulso_raiz = false
	tiempo_impulso_raiz = cooldown_impulso_raiz
	impulso_raiz_activo = true
	es_invulnerable = true
	velocity.y = fuerza_impulso_raiz
	velocity.x *= 0.35

	var mensaje := Label.new()
	mensaje.text = "IMPULSO DE RAÍZ"
	mensaje.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	mensaje.position = Vector2(-180, -115)
	mensaje.size = Vector2(360, 50)
	mensaje.add_theme_font_size_override("font_size", 24)
	mensaje.modulate = Color(0.45, 1.0, 0.70, 1.0)
	mensaje.z_index = 60
	add_child(mensaje)
	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(mensaje, "position:y", -175.0, 0.55)
	tween.tween_property(mensaje, "modulate:a", 0.0, 0.55)
	tween.chain().tween_callback(mensaje.queue_free)

	get_tree().create_timer(duracion_invulnerabilidad_raiz).timeout.connect(_terminar_impulso_raiz, CONNECT_ONE_SHOT)

	# El pulso inicial puede apartar enemigos muy cercanos sin convertirse en un ataque principal.
	for enemigo in get_tree().get_nodes_in_group("enemies"):
		if is_instance_valid(enemigo) and enemigo is Node2D:
			if global_position.distance_to(enemigo.global_position) <= 135.0 and enemigo.has_method("recibir_dano"):
				enemigo.recibir_dano(18, global_position)


func _terminar_impulso_raiz() -> void:
	impulso_raiz_activo = false
	es_invulnerable = haciendo_dash or capa_sombria_activa


func procesar_movimiento_horizontal(delta: float) -> void:

	direccion = Input.get_axis(
		"mover_izquierda",
		"mover_derecha"
	)

	# Giro visible al cambiar de sentido usando las animaciones originales.
	if direccion != 0.0 and ultimo_signo_direccion != 0.0 and sign(direccion) != ultimo_signo_direccion:
		if Input.is_action_pressed("agacharse"):
			reproducir_giro_agachado()
		else:
			reproducir_giro()
	ultimo_signo_direccion = sign(direccion) if direccion != 0.0 else ultimo_signo_direccion

	if direccion != 0.0:

		velocity.x = move_toward(
			velocity.x,
			direccion * velocidad_maxima,
			aceleracion * delta
		)

		sprite.flip_h = direccion < 0.0

	else:

		velocity.x = move_toward(
			velocity.x,
			0.0,
			friccion * delta
		)


# ============================================================
# SALTO
# ============================================================

func procesar_salto() -> void:

	# Soltar el salto antes de tiempo produce un salto corto y controlable.
	if Input.is_action_just_released("saltar") and velocity.y < 0.0:
		velocity.y *= 0.45

	if Input.is_action_just_pressed("saltar"):

		# Garra Trepadora: rebote fuerte desde cualquier pared.
		if GameState.tiene_habilidad("mantis_claw") and not is_on_floor() and is_on_wall():
			var normal_muro: Vector2 = get_wall_normal()
			velocity.x = normal_muro.x * fuerza_salto_muro.x
			velocity.y = fuerza_salto_muro.y
			saltos_realizados = 0
			coyote_time_valido = false
			return

		if is_on_floor() or coyote_time_valido:

			ejecutar_salto()

		elif saltos_realizados > 0 and saltos_realizados < saltos_maximos:

			ejecutar_salto()

		else:

			jump_buffer_activo = true

			jump_buffer_timer.start(
				jump_buffer_time
			)


# ============================================================
# EJECUTAR SALTO
# ============================================================

func ejecutar_salto() -> void:

	if has_node("/root/AudioManager"):
		AudioManager.play_sfx("jump")

	velocity.y = fuerza_salto

	saltos_realizados += 1

	coyote_time_valido = false


# ============================================================
# GARRA TREPADORA
# ============================================================

func procesar_garra_mantis() -> void:
	deslizandose_muro = false
	if not GameState.tiene_habilidad("mantis_claw"):
		return
	if is_on_wall() and not is_on_floor() and velocity.y > 0.0:
		deslizandose_muro = true
		velocity.y = min(velocity.y, velocidad_deslizamiento_muro)


# ============================================================
# EMBESTIDA CRISTALINA
# ============================================================

func procesar_corazon_cristal() -> void:
	if not GameState.tiene_habilidad("crystal_heart"):
		return

	if corazon_en_vuelo:
		tiempo_corazon_vuelo -= get_physics_process_delta_time()
		if tiempo_corazon_vuelo <= 0.0:
			corazon_en_vuelo = false
			velocity = Vector2.ZERO
			puede_usar_corazon = false
			get_tree().create_timer(cooldown_corazon_cristal).timeout.connect(func(): puede_usar_corazon = true)
		return

	if Input.is_action_just_pressed("crystal_dash") and puede_usar_corazon and not esta_atacando and not haciendo_dash and not capa_sombria_activa:
		cargando_corazon = true
		tiempo_cargando_corazon = 0.0
		velocity = Vector2.ZERO

	if cargando_corazon:
		tiempo_cargando_corazon += get_physics_process_delta_time()
		velocity = Vector2.ZERO
		if Input.is_action_just_released("crystal_dash"):
			if tiempo_cargando_corazon >= 0.20:
				lanzar_corazon_cristal()
			else:
				cargando_corazon = false

func lanzar_corazon_cristal() -> void:
	cargando_corazon = false
	var dir: Vector2 = Vector2(-1.0 if sprite.flip_h else 1.0, 0.0)
	if Input.is_action_pressed("saltar"):
		dir.y = -1.0
	elif Input.is_action_pressed("agacharse"):
		dir.y = 1.0
	velocity = dir.normalized() * velocidad_corazon_cristal
	corazon_en_vuelo = true
	tiempo_corazon_vuelo = max(duracion_corazon_cristal, 0.1)
	puede_usar_corazon = false


# ============================================================
# PASO UMBRÍO
# ============================================================

func procesar_capa_sombria() -> void:
	if not GameState.tiene_habilidad("shade_cloak"):
		return
	if Input.is_action_just_pressed("shade_cloak") and puede_usar_capa_sombria and not esta_muerto and not haciendo_dash and not cargando_corazon:
		activar_capa_sombria()

func activar_capa_sombria() -> void:
	capa_sombria_activa = true
	puede_usar_capa_sombria = false
	es_invulnerable = true
	for enemigo in get_tree().get_nodes_in_group("enemy"):
		if enemigo is CollisionObject2D:
			add_collision_exception_with(enemigo)
	get_tree().create_timer(duracion_capa_sombria).timeout.connect(finalizar_capa_sombria)

func finalizar_capa_sombria() -> void:
	if not is_instance_valid(self):
		return
	capa_sombria_activa = false
	if not haciendo_dash:
		es_invulnerable = false
	for enemigo in get_tree().get_nodes_in_group("enemy"):
		if enemigo is CollisionObject2D:
			remove_collision_exception_with(enemigo)
	get_tree().create_timer(cooldown_capa_sombria).timeout.connect(func(): puede_usar_capa_sombria = true)


func es_inmune_al_acido() -> bool:
	return inmunidad_acido or GameState.tiene_habilidad("isma_tear")


# ============================================================
# DASH
# ============================================================

func procesar_dash() -> void:

	if Input.is_action_just_pressed("dash") \
	and puede_hacer_dash \
	and not esta_atacando \
	and not cargando_corazon \
	and not capa_sombria_activa:

		var dir_dash: float = direccion

		if dir_dash == 0.0:

			dir_dash = -1.0 if sprite.flip_h else 1.0


		haciendo_dash = true

		puede_hacer_dash = false

		es_invulnerable = true


		velocity = Vector2(
			dir_dash * velocidad_dash,
			0.0
		)


		get_tree().create_timer(
			duracion_dash
		).timeout.connect(
			finalizar_dash
		)


# ============================================================
# TERMINAR DASH
# ============================================================

func finalizar_dash() -> void:

	haciendo_dash = false

	es_invulnerable = false
	velocity.x = move_toward(velocity.x, 0.0, 420.0)


	get_tree().create_timer(
		cooldown_dash
	).timeout.connect(
		func():
			puede_hacer_dash = true
	)


# ============================================================
# PARRY / CONTRAGOLPE
# ============================================================

func procesar_parry() -> void:
	if Input.is_action_just_pressed("parry") and not haciendo_parry and not esta_muerto and not haciendo_dash and not esta_atacando and not cargando_corazon:
		haciendo_parry = true
		parry_consumido = false
		es_invulnerable = true
		if status_label != null:
			status_label.text = "PARADA"
			status_label.visible = true
		var cuerpos: Array[Node2D] = area_parry.get_overlapping_bodies()
		for cuerpo: Node2D in cuerpos:
			if cuerpo != self and cuerpo.is_in_group("enemy") and cuerpo.has_method("recibir_dano"):
				parry_consumido = true
				cuerpo.recibir_dano(dano_ataque + 15, global_position)
				if cuerpo is CharacterBody2D:
					cuerpo.velocity = Vector2(sign(cuerpo.global_position.x - global_position.x) * 420.0, -220.0)
				break
		get_tree().create_timer(0.28).timeout.connect(finalizar_parry)

func finalizar_parry() -> void:
	if not is_instance_valid(self):
		return
	haciendo_parry = false
	es_invulnerable = haciendo_dash or capa_sombria_activa
	if status_label != null:
		status_label.visible = false


# ============================================================
# ATAQUE
# ============================================================

func puede_usar_combate() -> bool:
	return not esta_muerto and not haciendo_dash and not haciendo_parry and not cargando_corazon and not corazon_en_vuelo

func procesar_ataque() -> void:
	if Input.is_action_just_pressed("atacar"):
		tiempo_buffer_ataque = ventana_buffer_ataque

	if tiempo_buffer_ataque > 0.0 \
	and not esta_atacando \
	and not haciendo_dash \
	and not haciendo_parry \
	and not esta_muerto:

		# IMPORTANTE:
		# Misha puede atacar aunque esté herida.

		tiempo_buffer_ataque = 0.0
		esta_herido = false

		esta_atacando = true


		# ----------------------------------------------------
		# ELEGIR ANIMACIÓN DE ATAQUE
		# ----------------------------------------------------
		seleccionar_animacion_ataque()

		# ----------------------------------------------------
		# COLOCAR ÁREA DE ATAQUE
		# ----------------------------------------------------

		# Ajustar la hitbox al arma y al tamaño real de los sprites de Shaia.
		# El paquete original usa lienzos de 256x256 y el sprite está desplazado
		# verticalmente; la hitbox anterior quedaba demasiado arriba/cerca del cuerpo.
		ajustar_hitbox_ataque()


		# La animación original de Shaia controla ahora la duración visual.
		# La hitbox se mantiene sincronizada con el golpe inicial.


		# ----------------------------------------------------
		# ACTIVAR HITBOX
		# ----------------------------------------------------

		colision_ataque.set_deferred(
			"disabled",
			false
		)


		# ----------------------------------------------------
		# APLICAR GOLPE
		# ----------------------------------------------------

		get_tree().create_timer(
			0.10
		).timeout.connect(
			_aplicar_golpe_ataque
		)



func ajustar_hitbox_ataque() -> void:
	if not is_instance_valid(area_ataque) or not is_instance_valid(colision_ataque):
		return

	# Perfil pensado para attack_1 del paquete original de Shaia.
	# X positivo = delante del personaje; flip_h invierte automáticamente la posición.
	var delante := 58.0
	area_ataque.position = Vector2(-delante if sprite.flip_h else delante, 58.0)

	var forma := colision_ataque.shape as RectangleShape2D
	if forma != null:
		forma.size = Vector2(105.0, 68.0)


func _terminar_ataque_temporal() -> void:
	if esta_muerto:
		return
	esta_atacando = false
	colision_ataque.set_deferred("disabled", true)


func seleccionar_animacion_ataque() -> void:
	# Las variantes se eligen según la situación del jugador.
	if not is_on_floor():
		animacion_ataque_actual = "attack_jump"
	elif Input.is_action_pressed("agacharse"):
		var ataque_agachado: Array[String] = ["attack_crouch_1", "attack_crouch_2", "attack_knee"]
		animacion_ataque_actual = ataque_agachado[indice_combo % ataque_agachado.size()]
	elif abs(velocity.x) > 120.0:
		animacion_ataque_actual = "attack_run_kick"
	else:
		var combo: Array[String] = ["attack", "attack_1", "attack_2", "attack_3"]
		if tiempo_combo <= 0.0:
			indice_combo = 0
		else:
			indice_combo = (indice_combo + 1) % combo.size()
		animacion_ataque_actual = combo[indice_combo]

	tiempo_combo = 0.75
	if sprite.sprite_frames.has_animation(animacion_ataque_actual):
		sprite.play(animacion_ataque_actual)


func _on_sprite_animation_finished() -> void:
	if esta_atacando and animacion_ataque_actual == sprite.animation:
		esta_atacando = false
		colision_ataque.set_deferred("disabled", true)
		return

	if animacion_estado != "" and animacion_estado == sprite.animation:
		animacion_estado = ""
		tiempo_animacion_estado = 0.0


# ============================================================
# APLICAR GOLPE DE ATAQUE
# ============================================================

func _aplicar_golpe_ataque() -> void:

	if not is_instance_valid(self):

		return


	if not esta_atacando:

		return


	var cuerpos: Array[Node2D] = (
		area_ataque.get_overlapping_bodies()
	)


	for cuerpo: Node2D in cuerpos:

		if cuerpo != self \
		and cuerpo.has_method("recibir_dano"):

			cuerpo.recibir_dano(
				dano_ataque,
				global_position
			)


# ============================================================
# ENEMIGO GOLPEADO
# ============================================================

func _on_area_ataque_body_entered(_body: Node2D) -> void:

	# El daño se aplica desde _aplicar_golpe_ataque().
	#
	# Esto permite golpear nuevamente al mismo enemigo
	# en ataques posteriores.

	pass


# ============================================================
# RECIBIR DAÑO
# ============================================================

func recibir_dano(
	cantidad: int,
	origen_dano: Vector2 = Vector2.ZERO
) -> void:

	if has_node("/root/AudioManager"):
		AudioManager.play_sfx("hurt")

	if es_invulnerable or esta_muerto:

		return


	# ========================================================
	# RESTAR VIDA
	# ========================================================

	hp_actual = max(
		hp_actual - cantidad,
		0
	)


	# ========================================================
	# GUARDAR VIDA
	# ========================================================

	GameState.vida_actual = hp_actual


	# ========================================================
	# ACTUALIZAR BARRA
	# ========================================================

	actualizar_barra_vida()


	# ========================================================
	# RETROCESO
	# ========================================================

	if origen_dano != Vector2.ZERO:

		var empuje: float = float(
			sign(
				global_position.x
				- origen_dano.x
			)
		)


		if empuje == 0.0:

			empuje = 1.0


		velocity = Vector2(
			empuje * 200.0,
			-150.0
		)


	# ========================================================
	# SIGUE VIVO
	# ========================================================

	if hp_actual > 0:

		es_invulnerable = true

		esta_herido = true


		invulnerability_timer.start(
			tiempo_invulnerabilidad
		)




	# ========================================================
	# MUERTO
	# ========================================================

	else:

		ejecutar_muerte()


# ============================================================
# RECOMPENSAS Y MEJORAS DE TIENDA
# ============================================================

func recibir_recompensa(cantidad: int) -> void:
	GameState.agregar_monedas(cantidad)
	actualizar_contador_monedas()


func actualizar_contador_monedas() -> void:
	if coin_label != null:
		coin_label.text = "MONEDAS: " + str(GameState.monedas)


func curar_desde_pocion(cantidad: int) -> void:
	if esta_muerto:
		return
	hp_actual = min(hp_actual + cantidad, hp_maxima)
	GameState.vida_actual = hp_actual
	actualizar_barra_vida()
	actualizar_hud_habilidades()


func aplicar_fragmento_vida() -> void:
	GameState.bonus_vida_fragmentos += 10
	hp_maxima += 10
	hp_actual = min(hp_actual + 10, hp_maxima)
	GameState.vida_maxima = hp_maxima
	GameState.vida_actual = hp_actual
	actualizar_barra_vida()


func aplicar_mejora_tienda(tipo: String) -> void:
	match tipo:
		"vida":
			hp_maxima += 25
			hp_actual = min(hp_actual + 25, hp_maxima)
			GameState.vida_maxima = hp_maxima
			GameState.vida_actual = hp_actual
		"dano":
			nivel_arma = GameState.nivel_arma
			dano_ataque = GameState.obtener_dano_arma()
		"dash":
			velocidad_dash += 100
	actualizar_barra_vida()


func curar_desde_tienda() -> void:
	if esta_muerto:
		return
	hp_actual = hp_maxima
	GameState.vida_actual = hp_actual
	actualizar_barra_vida()


func desbloquear_doble_salto() -> void:
	saltos_maximos = 2
	saltos_realizados = 0
	actualizar_hud_habilidades()


func desbloquear_dash() -> void:
	puede_hacer_dash = true
	actualizar_hud_habilidades()

func desbloquear_garra_mantis() -> void:
	GameState.obtener_habilidad("mantis_claw")
	actualizar_hud_habilidades()

func desbloquear_corazon_cristal() -> void:
	GameState.obtener_habilidad("crystal_heart")
	actualizar_hud_habilidades()

func desbloquear_lagrima_isma() -> void:
	inmunidad_acido = true
	GameState.obtener_habilidad("isma_tear")
	actualizar_hud_habilidades()

func desbloquear_capa_sombria() -> void:
	GameState.obtener_habilidad("shade_cloak")
	actualizar_hud_habilidades()

func desbloquear_impulso_raiz() -> void:
	GameState.obtener_habilidad("root_burst")
	puede_usar_impulso_raiz = true
	tiempo_impulso_raiz = 0.0
	actualizar_hud_habilidades()



# ============================================================
# CURAR
# ============================================================

func curar_vida(cantidad: int) -> void:

	if esta_muerto:

		return


	hp_actual = min(
		hp_actual + cantidad,
		hp_maxima
	)


	GameState.vida_actual = hp_actual

	actualizar_barra_vida()


# ============================================================
# ACTUALIZAR BARRA DE VIDA
# ============================================================

func actualizar_hud_habilidades() -> void:
	if ability_label == null:
		return
	var habilidades_visibles: Array[String] = ["HABILIDADES"]
	if GameState.tiene_habilidad("double_jump"):
		habilidades_visibles.append("2X SALTO [SPACE]")
	if GameState.tiene_habilidad("dash"):
		habilidades_visibles.append("DASH [SHIFT]")
	if GameState.tiene_habilidad("mantis_claw"):
		habilidades_visibles.append("GARRA")
	if GameState.tiene_habilidad("crystal_heart"):
		habilidades_visibles.append("EMBESTIDA [G]")
	if GameState.tiene_habilidad("shade_cloak"):
		habilidades_visibles.append("PASO UMBRÍO [C]")
	if GameState.tiene_habilidad("root_burst"):
		habilidades_visibles.append("IMPULSO DE RAÍZ [V]")
	habilidades_visibles.append("PARRY [L]")
	habilidades_visibles.append("ARMA NIVEL " + str(nivel_arma) + " · DAÑO " + str(dano_ataque))
	ability_label.text = " · ".join(habilidades_visibles)


func actualizar_barra_vida() -> void:

	if health_bar == null:

		return


	health_bar.min_value = 0

	health_bar.max_value = hp_maxima

	health_bar.value = hp_actual


	# La barra permanece visible.
	health_bar.visible = true
	health_bar.modulate = Color(1.0, 0.72, 0.72, 1.0) if hp_actual <= int(hp_maxima * 0.25) else Color.WHITE


# ============================================================
# MUERTE
# ============================================================

func ejecutar_muerte() -> void:

	if esta_muerto:

		return


	esta_muerto = true

	esta_atacando = false

	velocity = Vector2.ZERO


	colision_ataque.set_deferred(
		"disabled",
		true
	)


	actualizar_barra_vida()



	await get_tree().create_timer(1.0).timeout
	if not is_instance_valid(self):
		return

	# Al morir, Misha vuelve al último checkpoint aunque esté en otra sala.
	# Si todavía no existe checkpoint, reinicia la sala actual con vida completa.
	GameState.vida_actual = GameState.vida_maxima

	if GameState.checkpoint_escena != "":
		GameState.punto_spawn = ""
		GameState.posicion_spawn = GameState.checkpoint_posicion
		var resultado: Error = get_tree().change_scene_to_file(GameState.checkpoint_escena)
		if resultado != OK:
			GameState.posicion_spawn = Vector2.ZERO
			GameState.checkpoint_escena = ""
			get_tree().reload_current_scene()
	else:
		get_tree().reload_current_scene()


func reproducir_victoria() -> void:
	## Reproduce la victoria una sola vez.
	if esta_muerto or victoria_activa:
		return
	victoria_activa = true
	velocity = Vector2.ZERO
	if is_instance_valid(sprite) and sprite.sprite_frames != null and sprite.sprite_frames.has_animation("victory"):
		sprite.play("victory")
		await sprite.animation_finished
	victoria_activa = false
	actualizar_animaciones()

# ============================================================
# VISUAL DEL JUGADOR
# Las animaciones anteriores de Misha/Shaia fueron retiradas del proyecto.
# El nodo MishaVisual se conserva para no romper la escena y facilitar
# la instalación del próximo paquete de sprites.
func actualizar_animaciones() -> void:
	if not is_instance_valid(sprite) or sprite.sprite_frames == null:
		return

	var siguiente := "idle"
	if esta_muerto and sprite.sprite_frames.has_animation("death"):
		siguiente = "death"
	elif esta_herido and sprite.sprite_frames.has_animation("hurt"):
		siguiente = "hurt"
	elif esta_atacando and sprite.sprite_frames.has_animation(animacion_ataque_actual):
		siguiente = animacion_ataque_actual
	elif haciendo_dash and sprite.sprite_frames.has_animation("dash"):
		siguiente = "dash"
	elif not is_on_floor():
		siguiente = "jump" if velocity.y < 0.0 else "fall"
	elif abs(velocity.x) > 1.0:
		siguiente = "run"
	else:
		siguiente = "idle"

	if sprite.animation != StringName(siguiente) or not sprite.is_playing():
		sprite.play(siguiente)


# ============================================================
# ANIMACIONES ESPECIALES
# API conservada para que el combate y los enemigos no se rompan.
# No reproduce recursos porque las animaciones anteriores fueron retiradas.

func reproducir_animacion_estado(nombre: String, duracion: float = 0.0) -> void:
	animacion_estado = nombre
	tiempo_animacion_estado = duracion
	if is_instance_valid(sprite) and sprite.sprite_frames != null and sprite.sprite_frames.has_animation(nombre):
		sprite.play(nombre)

func reproducir_aturdido(duracion: float = 0.8) -> void:
	reproducir_animacion_estado("stun", duracion)

func reproducir_atado(duracion: float = 0.8) -> void:
	reproducir_animacion_estado("bind", duracion)

func reproducir_electrificado(duracion: float = 0.8) -> void:
	reproducir_animacion_estado("electric", duracion)

func reproducir_quemado() -> void:
	reproducir_animacion_estado("burn", 0.5)

func reproducir_golpe_fuerte() -> void:
	reproducir_animacion_estado("damage_blow", 0.9)



# ============================================================
# GIROS
# ============================================================
# Reproduce el giro solo si la animación existe.
# Si el paquete de sprites no la tiene, usamos una animación segura.
func reproducir_giro() -> void:
	if not is_instance_valid(sprite) or sprite.sprite_frames == null:
		return

	if sprite.sprite_frames.has_animation("turn"):
		sprite.play("turn")
	elif sprite.sprite_frames.has_animation("run"):
		sprite.play("run")
	elif sprite.sprite_frames.has_animation("idle"):
		sprite.play("idle")


func reproducir_giro_agachado() -> void:
	if not is_instance_valid(sprite) or sprite.sprite_frames == null:
		return

	if sprite.sprite_frames.has_animation("turn_crouch"):
		sprite.play("turn_crouch")
	elif sprite.sprite_frames.has_animation("crouch"):
		sprite.play("crouch")
	elif sprite.sprite_frames.has_animation("idle"):
		sprite.play("idle")


# ============================================================
# COYOTE TIMER
# ============================================================

func _on_coyote_timer_timeout() -> void:

	coyote_time_valido = false


# ============================================================
# JUMP BUFFER TIMER
# ============================================================

func _on_jump_buffer_timer_timeout() -> void:

	jump_buffer_activo = false


# ============================================================
# INVULNERABILIDAD TIMER
# ============================================================

func _on_invulnerability_timer_timeout() -> void:

	es_invulnerable = false

	esta_herido = false
