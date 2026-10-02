extends CharacterBody2D

## HEART OF THE WORLD — Boss: Guardián de las Raíces
## Versión mejorada: más clara, fases definidas, telegráfos y segura.

# ------------------------------------------------------------
# EXPORTS
# ------------------------------------------------------------

@export var hp_maxima: int = 1200
@export var dano_contacto: int = 18
@export var velocidad: float = 150.0
@export var distancia_ataque: float = 110.0
@export var identificador_jefe: String = "guardian_bosque"

# ------------------------------------------------------------
# ESTADO
# ------------------------------------------------------------

var hp_actual: int = 0
var fase: int = 1
var jugador: Node2D = null

var atacando: bool = false
var invulnerable: bool = false
var muerto: bool = false
var activado: bool = false
var cambio_fase_en_curso: bool = false

var ataque_timer: float = 1.2
var golpe_cooldown: float = 0.0
var flash_timer: float = 0.0

var telegraph: Dictionary = {}
var anim_time: float = 0.0
var anim_index: int = 0
var anim_kind: String = "idle"

const HABILIDAD_PICKUP: PackedScene = preload("res://scenes/habilidad_pickup.tscn")

# ------------------------------------------------------------
# NODOS
# ------------------------------------------------------------

@onready var sprite: Sprite2D = $Sprite2D
@onready var barra: ProgressBar = $BossBar/Panel/Bar
@onready var nombre_label: Label = $BossBar/Panel/Nombre
@onready var fase_label: Label = $BossBar/Panel/Fase
@onready var arena_label: Label = $ArenaMessage
@onready var collision_shape: CollisionShape2D = $CollisionShape2D

# ------------------------------------------------------------
# CICLO DE VIDA
# ------------------------------------------------------------

func _ready() -> void:
	add_to_group("boss")
	add_to_group("enemy")
	add_to_group("enemies")

	if GameState.jefe_derrotado(identificador_jefe):
		visible = false
		set_physics_process(false)
		if collision_shape:
			collision_shape.set_deferred("disabled", true)
		return

	hp_actual = hp_maxima
	jugador = get_tree().get_first_node_in_group("player")

	if barra:
		barra.max_value = hp_maxima
		barra.value = hp_actual
	if nombre_label:
		nombre_label.text = "GUARDIÁN DE LAS RAÍCES"
	if fase_label:
		fase_label.text = "FASE I"
	if arena_label:
		arena_label.text = "EL GUARDIÁN DESPIERTA"
		arena_label.modulate.a = 0.0

	if sprite:
		sprite.scale = Vector2(4.0, 4.0)
		sprite.hframes = 8
		sprite.vframes = 7
		sprite.frame = 0

	_actualizar_fase(true)
	_actualizar_animacion("idle")
	queue_redraw()


func _physics_process(delta: float) -> void:
	if muerto:
		return

	if jugador == null or not is_instance_valid(jugador):
		jugador = get_tree().get_first_node_in_group("player")

	golpe_cooldown = maxf(golpe_cooldown - delta, 0.0)
	anim_time += delta

	# Flash de daño
	if flash_timer > 0.0:
		flash_timer -= delta
		if sprite:
			sprite.modulate = Color(1.0, 0.45, 0.45, 1.0)
	elif sprite:
		sprite.modulate = Color.WHITE

	if jugador == null:
		_actualizar_animacion("idle")
		return

	# Activación al acercarse
	if not activado:
		_actualizar_animacion("idle")
		if global_position.distance_to(jugador.global_position) <= 900.0:
			activado = true
			_mostrar_mensaje_arena("EL GUARDIÁN DESPIERTA")
		return

	if cambio_fase_en_curso:
		velocity = Vector2.ZERO
		move_and_slide()
		_actualizar_animacion(anim_kind)
		queue_redraw()
		return

	if not atacando:
		var dx: float = jugador.global_position.x - global_position.x
		velocity.x = clampf(dx * 1.4, -velocidad, velocidad)
		if absf(dx) > 45.0:
			if sprite:
				sprite.flip_h = dx < 0.0
			_actualizar_animacion("walk")
		else:
			velocity.x = move_toward(velocity.x, 0.0, 900.0 * delta)
			_actualizar_animacion("idle")
		move_and_slide()
		ataque_timer -= delta
		if ataque_timer <= 0.0:
			_elegir_ataque()
	else:
		velocity.x = move_toward(velocity.x, 0.0, 900.0 * delta)
		move_and_slide()

	_actualizar_animacion(anim_kind)
	queue_redraw()


# ------------------------------------------------------------
# DAÑO
# ------------------------------------------------------------

func recibir_dano(cantidad: int, _origen_dano: Vector2 = Vector2.ZERO) -> void:
	if muerto or invulnerable or not activado:
		return

	hp_actual = maxi(hp_actual - cantidad, 0)
	if barra:
		barra.value = hp_actual
	flash_timer = 0.10
	_actualizar_fase()

	if hp_actual <= 0:
		_morir()


# ------------------------------------------------------------
# FASES
# ------------------------------------------------------------

func _actualizar_fase(forzar: bool = false) -> void:
	var nueva_fase := 1
	if hp_actual <= int(hp_maxima * 0.40):
		nueva_fase = 3
	elif hp_actual <= int(hp_maxima * 0.70):
		nueva_fase = 2

	if nueva_fase == fase and not forzar:
		return

	fase = nueva_fase
	if fase_label:
		fase_label.text = "FASE %s" % ["I", "II", "III"][fase - 1]
	velocidad = 150.0 + float(fase - 1) * 35.0
	ataque_timer = 0.8

	if not forzar:
		_invocar_cambio_fase()


func _invocar_cambio_fase() -> void:
	if cambio_fase_en_curso or muerto:
		return

	cambio_fase_en_curso = true
	invulnerable = true
	atacando = false
	_actualizar_animacion("phase")
	telegraph = {"type": "phase", "time": 1.25}
	_mostrar_mensaje_arena("LAS RAÍCES DESPIERTAN — FASE %d" % fase)

	await get_tree().create_timer(1.25).timeout
	if not is_instance_valid(self) or muerto:
		return

	telegraph.clear()
	invulnerable = false
	cambio_fase_en_curso = false
	_actualizar_animacion("idle")
	queue_redraw()


# ------------------------------------------------------------
# ATAQUES
# ------------------------------------------------------------

func _elegir_ataque() -> void:
	if atacando or muerto or cambio_fase_en_curso:
		return

	atacando = true
	var opcion: int = randi_range(0, 2 + fase)

	match opcion:
		0:
			await _ataque_golpe()
		1:
			await _ataque_embestida()
		2:
			await _ataque_onda()
		_:
			await _ataque_lluvia()


func _ataque_golpe() -> void:
	_actualizar_animacion("attack")
	telegraph = {"type": "melee", "time": 0.65}
	await get_tree().create_timer(0.65).timeout
	if muerto:
		return
	telegraph.clear()
	_golpear_jugador(190.0, dano_contacto + fase * 4)
	await get_tree().create_timer(0.35).timeout
	_finalizar_ataque(0.75 if fase == 1 else 0.55)


func _ataque_embestida() -> void:
	_actualizar_animacion("attack")
	var dir: float = 1.0 if (jugador and jugador.global_position.x >= global_position.x) else -1.0
	telegraph = {"type": "dash", "dir": dir, "time": 0.8}
	await get_tree().create_timer(0.8).timeout
	if muerto:
		return
	telegraph.clear()
	velocity.x = dir * (520.0 + fase * 80.0)
	await get_tree().create_timer(0.55).timeout
	_golpear_jugador(155.0, dano_contacto + 8 + fase * 3)
	velocity.x = 0.0
	_finalizar_ataque(1.0 if fase == 1 else 0.7)


func _ataque_onda() -> void:
	_actualizar_animacion("attack")
	telegraph = {"type": "wave", "time": 0.9}
	await get_tree().create_timer(0.9).timeout
	if muerto:
		return
	telegraph.clear()
	if jugador:
		var centro := global_position + Vector2(0.0, 95.0)
		var dx := absf(jugador.global_position.x - centro.x)
		var dy := absf(jugador.global_position.y - centro.y)
		if dx < 620.0 and dy < 190.0:
			_golpear_jugador(620.0, dano_contacto + 6 + fase * 3)
	await get_tree().create_timer(0.3).timeout
	_finalizar_ataque(1.25 if fase == 1 else 0.8)


func _ataque_lluvia() -> void:
	_actualizar_animacion("attack")
	telegraph = {"type": "rain", "time": 1.15}
	await get_tree().create_timer(0.75).timeout
	if not muerto:
		_golpear_jugador(330.0, dano_contacto + 5 + fase * 4)
	await get_tree().create_timer(0.4).timeout
	telegraph.clear()
	_finalizar_ataque(1.5 if fase == 2 else 1.0)


func _finalizar_ataque(cooldown: float) -> void:
	if not is_instance_valid(self) or muerto:
		return
	atacando = false
	ataque_timer = cooldown
	_actualizar_animacion("idle")


func _golpear_jugador(radio: float, dano: int) -> void:
	if jugador == null or not is_instance_valid(jugador):
		return
	if golpe_cooldown > 0.0:
		return
	if global_position.distance_to(jugador.global_position) <= radio and jugador.has_method("recibir_dano"):
		jugador.recibir_dano(dano, global_position)
		golpe_cooldown = 0.42


# ------------------------------------------------------------
# MUERTE Y RECOMPENSA
# ------------------------------------------------------------

func _morir() -> void:
	if muerto:
		return

	muerto = true
	atacando = false
	invulnerable = true
	telegraph.clear()
	velocity = Vector2.ZERO

	if barra:
		barra.value = 0
	if fase_label:
		fase_label.text = "DERROTADO"
	_mostrar_mensaje_arena("EL GUARDIÁN DE LAS RAÍCES HA CAÍDO")
	_actualizar_animacion("death")

	GameState.registrar_jefe_derrotado(identificador_jefe)
	GameState.registrar_recompensa_especial("corazon_raiz")
	GameState.agregar_monedas(200)
	_crear_recompensa_habilidad()

	if SaveManager:
		SaveManager.guardar_partida()

	if sprite:
		var tween := create_tween()
		tween.set_parallel(true)
		tween.tween_property(sprite, "scale", Vector2(4.7, 4.7), 0.45)
		tween.tween_property(sprite, "modulate:a", 0.0, 1.25)

	await get_tree().create_timer(1.30).timeout
	if is_instance_valid(self):
		queue_free()


func _crear_recompensa_habilidad() -> void:
	if GameState.tiene_habilidad("root_burst"):
		return
	if get_parent() == null:
		return
	var pickup = HABILIDAD_PICKUP.instantiate()
	if pickup == null:
		return
	pickup.set("habilidad", "root_burst")
	pickup.set("nombre_habilidad", "IMPULSO DE RAÍZ")
	pickup.set("descripcion", "Una fuerza ancestral te lanza hacia arriba desde el suelo.")
	pickup.position = global_position + Vector2(0, -90)
	get_parent().add_child.call_deferred(pickup)


# ------------------------------------------------------------
# UTILIDADES
# ------------------------------------------------------------

func _mostrar_mensaje_arena(texto: String) -> void:
	if arena_label == null:
		return
	arena_label.text = texto
	arena_label.modulate.a = 1.0
	var tween := create_tween()
	tween.tween_property(arena_label, "modulate:a", 0.0, 1.4)


func _actualizar_animacion(tipo: String) -> void:
	if sprite == null:
		return
	if tipo != anim_kind:
		anim_kind = tipo
		anim_time = 0.0
		anim_index = 0

	var fps: float = 6.0
	var fila: int = 0
	var frames: int = 8

	match tipo:
		"idle":
			fila = 0; frames = 8; fps = 5.0
		"walk":
			fila = 1; frames = 8; fps = 8.0
		"attack":
			fila = 3; frames = 8; fps = 11.0
		"phase":
			fila = 5; frames = 8; fps = 7.0
		"death":
			fila = 6; frames = 8; fps = 7.0
		_:
			fila = 0

	var nuevo: int = mini(int(anim_time * fps), frames - 1)
	anim_index = nuevo
	if tipo in ["attack", "death", "phase"]:
		sprite.frame = fila * 8 + anim_index
	else:
		sprite.frame = fila * 8 + (anim_index % frames)


func _draw() -> void:
	var aura := Color(0.20, 0.85, 0.55, 0.08 + fase * 0.025)
	draw_circle(Vector2.ZERO, 125.0 + fase * 10.0, aura)
	draw_arc(Vector2.ZERO, 145.0 + fase * 12.0, -PI, PI, 64, Color(0.20, 0.90, 0.62, 0.22), 3.0)

	if telegraph.is_empty():
		return

	var pulse: float = 1.0 + sin(Time.get_ticks_msec() * 0.012) * 0.08
	match String(telegraph.get("type", "")):
		"melee":
			draw_arc(Vector2(0, 10), 145.0 * pulse, -0.9, 0.9, 32, Color(0.25, 1.0, 0.55, 0.75), 8.0)
		"dash":
			var dir: float = float(telegraph.get("dir", 1.0))
			draw_line(Vector2(0, 20), Vector2(dir * 650.0, 20), Color(0.25, 1.0, 0.55, 0.55), 26.0)
		"wave":
			draw_arc(Vector2(0, 95), 620.0 * pulse, 0.1, PI - 0.1, 48, Color(0.25, 1.0, 0.55, 0.55), 18.0)
		"rain":
			for i in range(7):
				var x: float = -500.0 + float(i) * 165.0
				draw_line(Vector2(x, -700), Vector2(x + sin(float(i)) * 35.0, 200), Color(0.25, 1.0, 0.55, 0.35), 9.0)
		"phase":
			draw_circle(Vector2.ZERO, 210.0 * pulse, Color(0.20, 1.0, 0.55, 0.12))
