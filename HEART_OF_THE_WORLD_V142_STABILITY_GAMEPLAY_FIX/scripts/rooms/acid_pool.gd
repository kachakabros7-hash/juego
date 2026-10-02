extends Area2D

@export var dano: int = 12
@export var intervalo_dano: float = 0.45

var jugador: Node2D = null
var tiempo: float = 0.0

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _physics_process(delta: float) -> void:
	if jugador == null or not is_instance_valid(jugador):
		return
	if jugador.has_method("es_inmune_al_acido") and jugador.es_inmune_al_acido():
		tiempo = 0.0
		return
	tiempo -= delta
	if tiempo <= 0.0:
		tiempo = intervalo_dano
		if jugador.has_method("recibir_dano"):
			jugador.recibir_dano(dano, global_position)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		jugador = body
		tiempo = 0.0

func _on_body_exited(body: Node2D) -> void:
	if body == jugador:
		jugador = null
		tiempo = 0.0
