extends Area2D

@export var cantidad: int = 1
@export var velocidad_caida: float = 80.0
@export var tiempo_de_vida: float = 10.0

var velocidad_y: float = -180.0
var recogida: bool = false


func _ready() -> void:
	body_entered.connect(_on_body_entered)

	var timer: Timer = Timer.new()
	timer.wait_time = tiempo_de_vida
	timer.one_shot = true
	add_child(timer)
	timer.timeout.connect(_desaparecer)
	timer.start()


func _physics_process(delta: float) -> void:
	if recogida:
		return

	velocidad_y += velocidad_caida * delta
	position.y += velocidad_y * delta


func _on_body_entered(body: Node2D) -> void:
	if recogida:
		return

	if body.is_in_group("player"):
		recogida = true

		if body.has_method("recibir_recompensa"):
			body.recibir_recompensa(cantidad)

		queue_free()


func _desaparecer() -> void:
	if not recogida:
		queue_free()
