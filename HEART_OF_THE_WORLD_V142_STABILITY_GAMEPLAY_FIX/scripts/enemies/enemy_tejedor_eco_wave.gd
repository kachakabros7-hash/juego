extends Area2D
var direccion: float = 1.0
var dano: int = 14
var vida: float = 2.2
@export var velocidad: float = 260.0
func _ready() -> void:
	collision_layer = 15
	collision_mask = 1
	body_entered.connect(_hit)
func _physics_process(delta: float) -> void:
	global_position.x += velocidad * direccion * delta
	vida -= delta
	if vida <= 0.0: queue_free()
func _hit(body: Node) -> void:
	if body.is_in_group("player") and body.has_method("recibir_dano"):
		body.recibir_dano(dano, global_position)
		queue_free()
