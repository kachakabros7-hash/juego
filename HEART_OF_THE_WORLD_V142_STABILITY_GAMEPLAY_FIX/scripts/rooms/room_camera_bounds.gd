extends Node

@export var limit_left: int = 0
@export var limit_top: int = 0
@export var limit_right: int = 5600
@export var limit_bottom: int = 1900
@export var suavizado: float = 8.0
@export var duracion_fade: float = 0.18

func _ready() -> void:
    call_deferred("_apply")
    call_deferred("_fade_in")

func _apply() -> void:
    var player: Node = get_parent().get_node_or_null("player")
    if player == null:
        player = get_parent().get_node_or_null("Player")
    if player == null:
        return
    var cam := player.get_node_or_null("Camera2D") as Camera2D
    if cam == null:
        return
    cam.limit_left = limit_left
    cam.limit_top = limit_top
    cam.limit_right = limit_right
    cam.limit_bottom = limit_bottom
    cam.limit_smoothed = true
    cam.position_smoothing_enabled = true
    cam.position_smoothing_speed = suavizado
    cam.reset_smoothing()
    cam.force_update_scroll()

func _fade_in() -> void:
    var capa := CanvasLayer.new()
    capa.name = "RoomFadeIn"
    capa.layer = 190
    capa.process_mode = Node.PROCESS_MODE_ALWAYS
    get_tree().current_scene.add_child(capa)

    var fondo := ColorRect.new()
    fondo.color = Color(0.008, 0.006, 0.016, 1.0)
    fondo.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    fondo.mouse_filter = Control.MOUSE_FILTER_IGNORE
    capa.add_child(fondo)

    var tween := create_tween()
    tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
    tween.tween_property(fondo, "color:a", 0.0, duracion_fade)
    tween.tween_callback(capa.queue_free)
