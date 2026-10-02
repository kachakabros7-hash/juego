extends Node2D

const STYLES: Dictionary = {
    "bosque": {"body": Color("#182c2a"), "mid": Color("#23483b"), "top": Color("#86c95a"), "edge": Color("#d0ed78"), "shadow": Color("#081312")},
    "cavernas": {"body": Color("#29252d"), "mid": Color("#4a3940"), "top": Color("#a8795d"), "edge": Color("#d4a77e"), "shadow": Color("#120f16")},
    "cueva_secreta": {"body": Color("#211b31"), "mid": Color("#44345c"), "top": Color("#9d73d1"), "edge": Color("#d7b5ff"), "shadow": Color("#0e0918")},
    "lago_oscuro": {"body": Color("#132536"), "mid": Color("#21445a"), "top": Color("#4d9fc2"), "edge": Color("#8fe2ef"), "shadow": Color("#07111b")},
    "templo": {"body": Color("#342c20"), "mid": Color("#5b4b2c"), "top": Color("#c6a85a"), "edge": Color("#f0d58a"), "shadow": Color("#15110b")},
    "ciudad": {"body": Color("#252d35"), "mid": Color("#414b55"), "top": Color("#8299aa"), "edge": Color("#c3d6df"), "shadow": Color("#10151a")},
    "pantano": {"body": Color("#182b22"), "mid": Color("#31503a"), "top": Color("#72ad61"), "edge": Color("#b6d879"), "shadow": Color("#09140f")},
    "torre": {"body": Color("#241b31"), "mid": Color("#49335e"), "top": Color("#9b6ec1"), "edge": Color("#d4a0f2"), "shadow": Color("#100b17")},
    "jefe": {"body": Color("#2b1a20"), "mid": Color("#57303a"), "top": Color("#b55762"), "edge": Color("#ef9a9f"), "shadow": Color("#13090d")}
}

var style: Dictionary = STYLES["bosque"]
var seed_value: int = 1

func _ready() -> void:
    z_index = 1
    var scene_id: String = get_tree().current_scene.scene_file_path.get_file().get_basename() if get_tree().current_scene != null else "bosque_entrada"
    var zona: String = _zona(scene_id)
    style = STYLES.get(zona, STYLES["bosque"])
    seed_value = abs(str(scene_id + name).hash())
    _limpiar_visuales_de_prueba()
    _crear_visuales()
    queue_redraw()

func _zona(id: String) -> String:
    if id.begins_with("cueva_secreta"): return "cueva_secreta"
    if id.begins_with("bosque_"): return "bosque"
    if id.begins_with("cavernas"): return "cavernas"
    if id.begins_with("lago_oscuro"): return "lago_oscuro"
    if id.begins_with("templo_antiguo"): return "templo"
    if id.begins_with("ciudad_perdida"): return "ciudad"
    if id.begins_with("pantano_sombrio"): return "pantano"
    if id.begins_with("torre_abismo"): return "torre"
    if id.begins_with("jefe_guardian"): return "jefe"
    return "bosque"

func _limpiar_visuales_de_prueba() -> void:
    for nodo: Node in get_children():
        if nodo is Polygon2D or nodo is Line2D:
            nodo.visible = false
    for nodo: Node in get_children():
        for hijo: Node in nodo.get_children():
            if hijo is Polygon2D or hijo is Line2D:
                hijo.visible = false

func _crear_visuales() -> void:
    for nodo: Node in get_children():
        if nodo is StaticBody2D:
            var body: StaticBody2D = nodo as StaticBody2D
            if body.get_node_or_null("ArtPass") != null:
                continue
            var shape_node: CollisionShape2D = body.get_node_or_null("CollisionShape2D") as CollisionShape2D
            if shape_node == null or shape_node.shape == null:
                continue
            var rect: RectangleShape2D = shape_node.shape as RectangleShape2D
            if rect == null:
                continue
            var art: Node2D = Node2D.new()
            art.name = "ArtPass"
            art.set_script(preload("res://scripts/rooms/platform_visuals_draw.gd"))
            art.set("size", rect.size)
            art.set("kind", _kind(body.name))
            art.set("seed_value", seed_value + body.name.hash())
            art.set("body_color", style["body"])
            art.set("mid_color", style["mid"])
            art.set("top_color", style["top"])
            art.set("edge_color", style["edge"])
            art.set("shadow_color", style["shadow"])
            body.add_child(art)

func _kind(id: String) -> String:
    var lower: String = id.to_lower()
    if lower.contains("ground"): return "ground"
    if lower.contains("wall"): return "wall"
    if lower.contains("pilar"): return "pillar"
    return "platform"
