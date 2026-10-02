extends Node2D

var boss: Node = null
var player: Node = null
var locked: bool = false
var doors: Array[Node] = []
var started: bool = false

func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")
	if GameState.jefe_derrotado("guardian_bosque"):
		return
	boss = get_node_or_null("BossGuardian")
	for node in get_tree().get_nodes_in_group("boss_arena_door"):
		doors.append(node)
	var exit_left: Node = get_node_or_null("Exits/ExitLeft")
	if exit_left:
		doors.append(exit_left)
	if boss:
		boss.tree_exited.connect(_on_boss_defeated)
		await get_tree().create_timer(0.35).timeout
		_bloquear_arena()

func _process(_delta: float) -> void:
	if started or boss == null or not is_instance_valid(boss):
		return
	if player == null or not is_instance_valid(player):
		player = get_tree().get_first_node_in_group("player")
	if player == null:
		return
	if player.global_position.x > 1050.0:
		started = true
		_bloquear_arena()

func _bloquear_arena() -> void:
	locked = true
	for door in doors:
		if is_instance_valid(door):
			if door is Area2D:
				door.monitoring = false
			else:
				var shape: CollisionShape2D = door.get_node_or_null("CollisionShape2D")
				if shape:
					shape.set_deferred("disabled", false)
			door.visible = true
	var label: Label = get_node_or_null("LockMessage")
	if label:
		label.text = "ARENA CERRADA"
		label.modulate.a = 1.0

func _on_boss_defeated() -> void:
	locked = false
	for door in doors:
		if is_instance_valid(door):
			if door is Area2D:
				door.monitoring = true
			else:
				var shape: CollisionShape2D = door.get_node_or_null("CollisionShape2D")
				if shape:
					shape.set_deferred("disabled", true)
			door.visible = false
	var label: Label = get_node_or_null("LockMessage")
	if label:
		label.text = "CAMINO DESPEJADO"
		var tween: Tween = create_tween()
		tween.tween_property(label, "modulate:a", 0.0, 1.2)
