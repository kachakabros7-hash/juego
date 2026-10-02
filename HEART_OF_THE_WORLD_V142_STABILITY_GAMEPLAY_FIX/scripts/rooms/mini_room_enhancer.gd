extends Node2D

const PLATFORM_COLOR = Color(0.33, 0.30, 0.42, 0.92)
const TOP_COLOR = Color(0.72, 0.65, 0.84, 0.68)

var ACCENT_COLORS = {
    "bosque": Color(0.32, 0.78, 0.46, 0.70),
    "cavernas": Color(0.63, 0.43, 0.31, 0.70),
    "cueva": Color(0.67, 0.46, 0.82, 0.72),
    "lago": Color(0.24, 0.65, 0.86, 0.72),
    "templo": Color(0.88, 0.68, 0.30, 0.72),
    "ciudad": Color(0.52, 0.66, 0.78, 0.72),
    "pantano": Color(0.39, 0.72, 0.42, 0.72),
    "torre": Color(0.68, 0.40, 0.86, 0.72),
    "jefe": Color(0.88, 0.30, 0.36, 0.72)
}

func _ready() -> void:
    var id = get_scene_file_path().get_file().get_basename()
    if id == "":
        return
    var tipo = "pasaje"
    if id.ends_with("_secreta"):
        tipo = "secreta"
    elif id.ends_with("_desafio"):
        tipo = "desafio"
    elif id.ends_with("_recompensa"):
        tipo = "recompensa"
    _aplicar_mejora(tipo, id)

func _aplicar_mejora(tipo, id) -> void:
    var seed_value = absi(id.hash())
    var drift_x = float(seed_value % 121) - 60.0
    var drift_y = float((seed_value / 17) % 81) - 40.0

    if tipo == "pasaje":
        _reubicar([Vector2(520, 1450), Vector2(1100, 1250), Vector2(1720, 1050), Vector2(2380, 1320)], drift_x, drift_y)
        _agregar_plataforma(Vector2(2850, 1050), Vector2(260, 45), "PasoFinal")
        _agregar_pilar(Vector2(820, 1560), 260.0)
    elif tipo == "secreta":
        _reubicar([Vector2(620, 1450), Vector2(1180, 1160), Vector2(1600, 860), Vector2(2020, 1160)], drift_x, drift_y)
        _agregar_plataforma(Vector2(2500, 820), Vector2(420, 45), "MiradorSecreto")
        _agregar_plataforma(Vector2(1600, 600), Vector2(260, 45), "NichoSuperior")
        _agregar_pilar(Vector2(2650, 1460), 420.0)
    elif tipo == "desafio":
        _reubicar([Vector2(500, 1500), Vector2(980, 1260), Vector2(1500, 1020), Vector2(2020, 780)], drift_x, drift_y)
        _agregar_plataforma(Vector2(2500, 1040), Vector2(360, 45), "Desafio5")
        _agregar_plataforma(Vector2(2800, 720), Vector2(260, 45), "Desafio6")
        _agregar_pilar(Vector2(1450, 1510), 360.0)
    elif tipo == "recompensa":
        _reubicar([Vector2(560, 1480), Vector2(1050, 1300), Vector2(2150, 1300), Vector2(2700, 1480)], drift_x, drift_y)
        _agregar_plataforma(Vector2(1600, 950), Vector2(560, 55), "PedestalRecompensa")
        _agregar_plataforma(Vector2(1600, 650), Vector2(300, 45), "AtajoRecompensa")
        _agregar_pilar(Vector2(850, 1520), 300.0)

    _agregar_detalle_unico(tipo, seed_value)
    if tipo == "secreta":
        _agregar_atajo_recompensa(id, seed_value)
    _agregar_recompensa_recomendada(tipo, id, seed_value)
    _agregar_marco_decorativo(tipo, id)

func _reubicar(posiciones, drift_x = 0.0, drift_y = 0.0) -> void:
    var limite = min(4, posiciones.size())
    for i in range(limite):
        var plataforma = get_node_or_null("Objects/Platform%d" % (i + 1))
        if plataforma != null and plataforma is StaticBody2D:
            var factor_x = 0.25
            var factor_y = 0.35
            if i != 0 and i != 3:
                factor_x = 0.45
            if i % 2 != 0:
                factor_y = 0.55
            plataforma.position = posiciones[i] + Vector2(drift_x * factor_x, drift_y * factor_y)

func _agregar_plataforma(pos: Vector2, size: Vector2, nombre: String) -> void:
    var body = StaticBody2D.new()
    body.name = nombre
    body.position = pos
    var shape = CollisionShape2D.new()
    var rect = RectangleShape2D.new()
    rect.size = size
    shape.shape = rect
    body.add_child(shape)
    var visual = Polygon2D.new()
    visual.polygon = PackedVector2Array([
        Vector2(-size.x / 2.0, -size.y / 2.0),
        Vector2(size.x / 2.0, -size.y / 2.0),
        Vector2(size.x / 2.0, size.y / 2.0),
        Vector2(-size.x / 2.0, size.y / 2.0)
    ])
    visual.color = PLATFORM_COLOR
    body.add_child(visual)
    var top = Polygon2D.new()
    top.name = "TopHighlight"
    top.polygon = PackedVector2Array([
        Vector2(-size.x / 2.0, -size.y / 2.0),
        Vector2(size.x / 2.0, -size.y / 2.0),
        Vector2(size.x / 2.0, -size.y / 2.0 + 5.0),
        Vector2(-size.x / 2.0, -size.y / 2.0 + 5.0)
    ])
    top.color = TOP_COLOR
    body.add_child(top)
    get_node("Objects").add_child(body)

func _agregar_pilar(pos: Vector2, altura: float) -> void:
    var body = StaticBody2D.new()
    body.name = "PilarExtra_%d" % get_child_count()
    body.position = pos
    var shape = CollisionShape2D.new()
    var rect = RectangleShape2D.new()
    rect.size = Vector2(55.0, altura)
    shape.shape = rect
    body.add_child(shape)
    var visual = Polygon2D.new()
    visual.polygon = PackedVector2Array([
        Vector2(-27.5, -altura / 2.0),
        Vector2(27.5, -altura / 2.0),
        Vector2(27.5, altura / 2.0),
        Vector2(-27.5, altura / 2.0)
    ])
    visual.color = PLATFORM_COLOR
    body.add_child(visual)
    var cap = Polygon2D.new()
    cap.polygon = PackedVector2Array([
        Vector2(-35.0, -altura / 2.0),
        Vector2(35.0, -altura / 2.0),
        Vector2(25.0, -altura / 2.0 - 10.0),
        Vector2(-25.0, -altura / 2.0 - 10.0)
    ])
    cap.color = TOP_COLOR
    body.add_child(cap)
    get_node("Objects").add_child(body)

func _agregar_detalle_unico(tipo, seed_value) -> void:
    var rng = RandomNumberGenerator.new()
    rng.seed = seed_value
    var root = Node2D.new()
    root.name = "RoomIdentityDetail"
    root.z_index = -1
    add_child(root)
    var accent = Color("#8f76b5")
    for key in ACCENT_COLORS.keys():
        var texto = str(key)
        if (tipo == "pasaje" and texto == "bosque") or get_scene_file_path().get_file().begins_with(texto):
            var color_value = ACCENT_COLORS.get(texto, accent)
            if color_value is Color:
                accent = color_value
    var motif = seed_value % 4
    for i in range(6):
        var x = rng.randf_range(130.0, 3000.0)
        var y = rng.randf_range(320.0, 1460.0)
        var line = Line2D.new()
        line.width = rng.randf_range(1.2, 2.8)
        line.default_color = Color(accent.r, accent.g, accent.b, rng.randf_range(0.05, 0.12))
        if motif == 0:
            line.points = PackedVector2Array([Vector2(x, y), Vector2(x + rng.randf_range(18.0, 45.0), y + rng.randf_range(-8.0, 8.0))])
        elif motif == 1:
            line.points = PackedVector2Array([Vector2(x, y), Vector2(x + rng.randf_range(-10.0, 10.0), y - rng.randf_range(18.0, 40.0))])
        elif motif == 2:
            line.points = PackedVector2Array([Vector2(x - 8.0, y), Vector2(x + 4.0, y + 8.0), Vector2(x + 18.0, y - 5.0)])
        else:
            line.points = PackedVector2Array([Vector2(x, y), Vector2(x + 24.0, y), Vector2(x + 35.0, y + 16.0)])
        root.add_child(line)

func _agregar_marco_decorativo(tipo, id) -> void:
    var zona = id
    var idx = zona.rfind("_")
    if idx > 0:
        zona = zona.substr(0, idx)
    var accent = Color("#8f76b5")
    for key in ACCENT_COLORS.keys():
        var texto = str(key)
        if zona.begins_with(texto):
            accent = ACCENT_COLORS[texto]
            break
    var banner = Polygon2D.new()
    banner.name = "RoomAccent"
    banner.z_index = 5
    banner.polygon = PackedVector2Array([Vector2(60,185), Vector2(720,185), Vector2(720,193), Vector2(60,193)])
    banner.color = Color(accent.r, accent.g, accent.b, 0.55)
    add_child(banner)
    var badge = Label.new()
    badge.name = "RoomBadge"
    badge.position = Vector2(80,205)
    badge.z_index = 10
    badge.text = _texto_tipo(tipo)
    badge.add_theme_font_size_override("font_size", 16)
    badge.add_theme_color_override("font_color", Color(accent.r, accent.g, accent.b, 0.90))
    badge.add_theme_color_override("font_shadow_color", Color(0.02, 0.01, 0.04, 0.92))
    badge.add_theme_constant_override("shadow_offset_x", 2)
    badge.add_theme_constant_override("shadow_offset_y", 2)
    add_child(badge)

func _texto_tipo(tipo) -> String:
    if tipo == "secreta":
        return "◆ ZONA OCULTA"
    if tipo == "desafio":
        return "◆ DESAFÍO"
    if tipo == "recompensa":
        return "◆ RECOMPENSA"
    return "◆ PASAJE"

func _habilidad_atribuida(id) -> String:
    var lower = id.to_lower()
    if lower.begins_with("bosque_entrada") or lower.begins_with("bosque_sendero"):
        return "double_jump"
    if lower.begins_with("bosque_profundidad") or lower.begins_with("bosque_santuario"):
        return "dash"
    if lower.begins_with("cavernas") or lower.begins_with("cueva_secreta"):
        return "mantis_claw"
    if lower.begins_with("lago_oscuro"):
        return "crystal_heart"
    if lower.begins_with("templo_antiguo"):
        return "double_jump"
    if lower.begins_with("ciudad_perdida"):
        return "crystal_heart"
    if lower.begins_with("pantano_sombrio"):
        return "isma_tear"
    if lower.begins_with("torre_abismo") or lower.begins_with("jefe_guardian"):
        return "shade_cloak"
    return "dash"

func _nombre_habilidad(id) -> String:
    if id == "double_jump": return "Salto Celestial"
    if id == "dash": return "Impulso Espectral"
    if id == "mantis_claw": return "Garra Trepadora"
    if id == "crystal_heart": return "Embestida Cristalina"
    if id == "isma_tear": return "Bendición del Pantano"
    if id == "shade_cloak": return "Paso Umbrío"
    return "Habilidad"

func _agregar_atajo_recompensa(id, seed_value) -> void:
    var base = id.substr(0, id.rfind("_secreta"))
    var premio = "res://scenes/rooms/zonas/%s/%s_recompensa.tscn" % [base, base]
    if not ResourceLoader.exists(premio):
        return
    var atajo = Area2D.new()
    atajo.name = "AtajoOcultoRecompensa"
    atajo.position = Vector2(1600.0, 575.0 + float(seed_value % 90))
    atajo.collision_layer = 0
    atajo.collision_mask = 1
    atajo.set_script(load("res://scripts/rooms/room_transition.gd"))
    atajo.set("escena_destino", premio)
    atajo.set("spawn_destino", "SpawnBottom")
    atajo.set("habilidad_requerida", _habilidad_atribuida(id))
    var shape = CollisionShape2D.new()
    var rect = RectangleShape2D.new()
    rect.size = Vector2(170.0, 90.0)
    shape.shape = rect
    atajo.add_child(shape)
    var sello = Label.new()
    sello.name = "AtajoHint"
    sello.text = "◇ ATAJO  ·  %s" % _nombre_habilidad(_habilidad_atribuida(id))
    sello.position = Vector2(-210.0, -80.0)
    sello.size = Vector2(420.0, 36.0)
    sello.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    sello.add_theme_font_size_override("font_size", 14)
    sello.add_theme_color_override("font_color", Color(0.86, 0.80, 0.96, 0.56))
    sello.add_theme_color_override("font_shadow_color", Color(0.02, 0.01, 0.04, 0.85))
    sello.add_theme_constant_override("shadow_offset_x", 2)
    sello.add_theme_constant_override("shadow_offset_y", 2)
    sello.mouse_filter = Control.MOUSE_FILTER_IGNORE
    atajo.add_child(sello)
    get_node("Objects").add_child(atajo)

func _agregar_recompensa_recomendada(tipo, id, seed_value) -> void:
    if tipo != "recompensa":
        return
    var premio = Area2D.new()
    premio.name = "ReservaRecompensa"
    premio.position = Vector2(1600.0, 860.0 + float(seed_value % 180))
    premio.collision_layer = 2
    premio.collision_mask = 1
    premio.set_script(load("res://scripts/items/recompensa_especial.gd"))
    premio.set("tipo", "cofre")
    premio.set("identificador", "sello_recompensa_" + id)
    premio.set("cantidad_monedas", 8 + int(seed_value % 8))
    get_node("Objects").add_child(premio)
