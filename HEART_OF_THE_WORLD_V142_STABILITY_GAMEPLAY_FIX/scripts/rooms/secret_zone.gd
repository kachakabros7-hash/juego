extends Area2D

@export var mensaje: String = "Has encontrado una zona secreta."
var encontrado: bool = false

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node) -> void:
	if encontrado or not body.is_in_group("player"):
		return
	encontrado = true
	var label: Label = Label.new()
	label.text = mensaje
	label.position = Vector2(-170, -60)
	label.z_index = 20
	add_child(label)
	var timer: SceneTreeTimer = get_tree().create_timer(2.5)
	timer.timeout.connect(label.queue_free)
