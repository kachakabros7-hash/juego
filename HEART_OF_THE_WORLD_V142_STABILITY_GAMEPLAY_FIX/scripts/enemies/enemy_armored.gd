extends "res://scripts/enemies/enemy_basic.gd"

@export var reduccion_dano: float = 0.55
@export var intervalo_guardia: float = 2.4
@export var duracion_guardia: float = 0.65
var guardia: float = 0.0
var reloj_guardia: float = 1.2

func _ready() -> void:
	super._ready()
	hp_maxima = 75
	hp_actual = hp_maxima
	empuje_recibido = 85.0
	velocidad = 65.0
	aplicar_balance_especifico()
	actualizar_barra_vida()
	sprite.modulate = Color(0.72, 0.82, 0.95, 1.0)

func _physics_process(delta: float) -> void:
	reloj_guardia -= delta
	if reloj_guardia <= 0.0 and not atacando and not esta_muerto:
		guardia = duracion_guardia
		reloj_guardia = intervalo_guardia
	if guardia > 0.0:
		guardia -= delta
		sprite.modulate = Color(0.48, 0.68, 1.0, 1.0)
	else:
		sprite.modulate = Color.WHITE
	super._physics_process(delta)

func recibir_dano(cantidad: int, origen_dano: Vector2 = Vector2.ZERO) -> void:
	var dano_final: int = cantidad
	if guardia > 0.0:
		dano_final = maxi(1, int(round(float(cantidad) * (1.0 - reduccion_dano))))
	super.recibir_dano(dano_final, origen_dano)
