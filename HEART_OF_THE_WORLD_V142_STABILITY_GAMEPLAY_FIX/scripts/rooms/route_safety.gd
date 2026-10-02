extends Node

@export var limite_caida: float = 300.0
@export var enfriamiento: float = 0.8
@export var respawn_name: String = "PlayerSpawn"

var bloqueado: bool = false

func _physics_process(_delta: float) -> void:
    if bloqueado:
        return
    var root := get_parent()
    if root == null:
        return
    var player := root.get_node_or_null("player") as CharacterBody2D
    if player == null:
        player = root.get_node_or_null("Player") as CharacterBody2D
    if player == null:
        player = get_tree().get_first_node_in_group("player") as CharacterBody2D
    if player == null:
        return

    var bottom: float = 1400.0
    var camera_bounds: Node = root.get_node_or_null("CameraBounds")
    if camera_bounds != null:
        var value = camera_bounds.get("limit_bottom")
        if value != null:
            bottom = float(value)
    var room_height_value = root.get("room_height")
    if room_height_value != null:
        bottom = float(room_height_value)

    if player.global_position.y > bottom + limite_caida:
        _respawn(player)

func _respawn(player: CharacterBody2D) -> void:
    bloqueado = true
    var current_scene := get_tree().current_scene.scene_file_path
    var used_checkpoint := false
    if GameState.checkpoint_escena == current_scene and GameState.checkpoint_posicion != Vector2.ZERO:
        player.global_position = GameState.checkpoint_posicion
        used_checkpoint = true

    if not used_checkpoint:
        var marker := get_parent().get_node_or_null(respawn_name) as Marker2D
        if marker != null:
            player.global_position = marker.global_position
        else:
            player.global_position = Vector2(220.0, 1000.0)

    player.velocity = Vector2.ZERO
    GameState.vida_actual = GameState.vida_maxima
    if SaveManager != null:
        SaveManager.guardar_partida()
    var timer := get_tree().create_timer(enfriamiento)
    timer.timeout.connect(func() -> void:
        bloqueado = false
    )
