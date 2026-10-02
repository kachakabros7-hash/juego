extends Node

# Controlador de ataques a distancia para Misha.
# K lanza la tecnica seleccionada; Q/E cambia tecnica; R usa el especial.

var tecnicas: Array[String] = ["onda", "boomerang", "cargado", "corte", "explosion", "lluvia"]
var nombres: Dictionary = {
	"onda": "ONDA DE ESPADA",
	"boomerang": "BOOMERANG",
	"cargado": "PROYECTIL CARGADO",
	"corte": "CORTE PENETRANTE",
	"explosion": "EXPLOSION DE ENERGIA",
	"lluvia": "LLUVIA DE ESPADAS"
}
var indice: int = 0
var enfriamiento: float = 0.0
var energia: float = 100.0
var cargando: bool = false
var tiempo_carga: float = 0.0
var especial_enfriamiento: float = 0.0

@onready var player: CharacterBody2D = get_parent()

func _process(delta: float) -> void:
	enfriamiento = max(0.0, enfriamiento - delta)
	especial_enfriamiento = max(0.0, especial_enfriamiento - delta)
	energia = min(100.0, energia + delta * 8.0)
	if Input.is_action_just_pressed("habilidad_anterior"):
		cambiar(-1)
	if Input.is_action_just_pressed("habilidad_siguiente"):
		cambiar(1)
	if Input.is_action_just_pressed("ataque_distancia"):
		iniciar_ataque()
	if Input.is_action_just_released("ataque_distancia") and cargando:
		liberar_cargado()
	if Input.is_action_just_pressed("ataque_especial"):
		usar_especial()

func cambiar(paso: int) -> void:
	indice = wrapi(indice + paso, 0, tecnicas.size())
	actualizar_hud()

func tecnica_actual() -> String:
	return tecnicas[indice]

func iniciar_ataque() -> void:
	if not player.has_method("puede_usar_combate") or not player.puede_usar_combate():
		return
	var tipo := tecnica_actual()
	if tipo == "cargado":
		cargando = true
		tiempo_carga = 0.0
		actualizar_hud()
		return
	if enfriamiento > 0.0:
		return
	lanzar_tecnica(tipo)

func _physics_process(delta: float) -> void:
	if cargando:
		tiempo_carga += delta
		if tiempo_carga > 1.2:
			tiempo_carga = 1.2

func liberar_cargado() -> void:
	if not cargando:
		return
	cargando = false
	var potencia := clampf(tiempo_carga / 0.8, 0.35, 1.0)
	var dano := int(round(player.dano_ataque * 1.8 * potencia))
	crear_proyectil(_direccion(), dano, 900.0 + potencia * 300.0, "cargado", 2.4)
	enfriamiento = 0.45
	actualizar_hud()

func lanzar_tecnica(tipo: String) -> void:
	var dano_base: int = int(player.dano_ataque)
	match tipo:
		"onda":
			crear_proyectil(_direccion(), dano_base, 720.0, tipo, 2.0)
		"boomerang":
			crear_proyectil(_direccion(), int(dano_base * 0.8), 560.0, tipo, 2.2)
		"corte":
			crear_proyectil(_direccion(), int(dano_base * 1.35), 1100.0, tipo, 1.5)
		"explosion":
			if energia < 15.0: return
			energia -= 15.0
			crear_proyectil(_direccion(), int(dano_base * 1.15), 520.0, tipo, 2.0)
		"lluvia":
			if energia < 20.0: return
			energia -= 20.0
			for i in range(5):
				var offset := Vector2((i - 2) * 34.0, -420.0 - abs(i - 2) * 30.0)
				crear_proyectil(Vector2(0, 1), int(dano_base * 0.65), 650.0, tipo, 1.4, player.global_position + offset)
	enfriamiento = 0.25
	actualizar_hud()

func usar_especial() -> void:
	if especial_enfriamiento > 0.0 or energia < 30.0 or not player.puede_usar_combate():
		return
	energia -= 30.0
	especial_enfriamiento = 3.0
	var dir := _direccion()
	crear_proyectil(dir, int(player.dano_ataque * 2.8), 760.0, "especial", 3.0)
	actualizar_hud()

func crear_proyectil(dir: Vector2, dano: int, velocidad: float, tipo: String, duracion: float, posicion: Vector2 = Vector2.INF) -> void:
	var area = Area2D.new()
	area.set_script(load("res://scripts/player/ranged_projectile.gd"))
	var shape := CollisionShape2D.new()
	var circle := CircleShape2D.new()
	circle.radius = 18.0
	shape.shape = circle
	area.add_child(shape)
	player.get_parent().add_child(area)
	area.global_position = player.global_position + (dir.normalized() * 55.0 if posicion == Vector2.INF else posicion - player.global_position)
	area.configurar(dir, dano, velocidad, tipo)
	area.vida = duracion
	if tipo == "boomerang":
		area.objetivo_regreso = player

func _direccion() -> Vector2:
	var d := Vector2(Input.get_axis("mover_izquierda", "mover_derecha"), Input.get_axis("apuntar_arriba", "apuntar_abajo"))
	if d.length() < 0.1:
		d = Vector2(-1.0 if player.sprite.flip_h else 1.0, 0.0)
	return d.normalized()

func actualizar_hud() -> void:
	var label := player.get_node_or_null("CanvasLayer/AbilityLabel") as Label
	if label:
		label.text = nombres.get(tecnica_actual(), tecnica_actual()) + "  [K]   Q/E CAMBIAR   R ESPECIAL   ⚡ " + str(int(energia))
