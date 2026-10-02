extends Node2D

var portals: Array[Node2D] = []
var phase: float = 0.0
var accent: Color = Color("#8fdcff")

func _ready() -> void:
    z_index = 2
    var id: String = get_tree().current_scene.scene_file_path.get_file().get_basename() if get_tree().current_scene != null else "bosque_entrada"
    accent = _accent(_zone(id))
    for child: Node in get_children():
        if child is Area2D:
            var area: Area2D = child as Area2D
            var old_visual: Node = area.get_node_or_null("Visual")
            if old_visual != null:
                old_visual.visible = false
            var art: Node2D = Node2D.new()
            art.name = "PortalArt"
            art.position = area.position
            art.set_script(load("res://scripts/rooms/exit_visual_draw.gd"))
            art.set("accent", accent)
            art.set("direction", _direction(area.name))
            art.set("seed_value", abs(area.name.hash()))
            art.set("concealed", _es_salida_secreta(area))
            add_child(art)
            portals.append(art)
    queue_redraw()

func _process(delta: float) -> void:
    phase += delta
    for portal: Node2D in portals:
        if is_instance_valid(portal):
            portal.set("phase", phase)

func _es_salida_secreta(area: Area2D) -> bool:
    var destino: String = str(area.get("escena_destino"))
    if destino.is_empty():
        destino = str(area.get("siguiente_habitacion"))
    return destino.find("_secreta.tscn") >= 0

func _zone(id: String) -> String:
    if id.begins_with("cueva_secreta"): return "cueva"
    if id.begins_with("bosque_"): return "bosque"
    if id.begins_with("cavernas"): return "cavernas"
    if id.begins_with("lago_oscuro"): return "lago"
    if id.begins_with("templo_antiguo"): return "templo"
    if id.begins_with("ciudad_perdida"): return "ciudad"
    if id.begins_with("pantano_sombrio"): return "pantano"
    if id.begins_with("torre_abismo"): return "torre"
    if id.begins_with("jefe_guardian"): return "jefe"
    return "bosque"

func _accent(zone: String) -> Color:
    match zone:
        "bosque": return Color("#9ee86c")
        "cavernas": return Color("#d0a078")
        "cueva": return Color("#c49cff")
        "lago": return Color("#72d9f4")
        "templo": return Color("#f2d17d")
        "ciudad": return Color("#b8d6e5")
        "pantano": return Color("#9ddc73")
        "torre": return Color("#d19aff")
        "jefe": return Color("#ff8790")
        _: return Color("#9ee86c")

func _direction(id: String) -> String:
    var lower: String = id.to_lower()
    if lower.contains("left"): return "left"
    if lower.contains("right"): return "right"
    if lower.contains("top"): return "top"
    return "bottom"
