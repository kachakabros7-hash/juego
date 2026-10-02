extends Control

var current_room: String = ""
var visited: Dictionary = {}
var visited_rooms: Dictionary = {}
var blocked_doors: Dictionary = {}
var zoom: float = 0.48
var map_offset: Vector2 = Vector2.ZERO
var dragging: bool = false
var drag_start: Vector2 = Vector2.ZERO
var offset_start: Vector2 = Vector2.ZERO
var pulse_time: float = 0.0
var modo_minimapa: bool = false
var _dirty: bool = true
var _mini_redraw_accum: float = 0.0
var _cached_mini_box: StyleBoxFlat = null
var _cached_zone_id: String = ""
var _cached_known_rooms: int = -1
var _cached_stars: PackedVector2Array = PackedVector2Array()
var _cached_stars_size: Vector2 = Vector2.ZERO
const FULL_MAP_REDRAW_INTERVAL: float = 0.05  # ~20 FPS cuando hay pulso

const MAP_SIZE: Vector2 = Vector2(3300, 1800)
const MINI_MARGIN: Vector2 = Vector2(18, 48)
const MINI_REDRAW_INTERVAL: float = 0.08  # ~12.5 FPS para el pulso del minimapa

# Mapa mundial de Misha: 12 zonas, con composición ramificada y vertical.
# Las posiciones son del mapa lógico, no alteran las escenas jugables.
const ZONES: Dictionary = {
    "bosque_entrada": {"name":"Bosque del Amanecer", "number":1, "pos":Vector2(110,150), "size":Vector2(680,320), "color":Color(0.42,0.86,0.38), "shape":"forest", "rooms":["Entrada","Sendero","Pasaje","Secreta","Desafío","Recompensa","Claro de Luma","Ruinas","Arboleda","Cascada","Raíces Antiguas","Cueva del Musgo","Mirador","Pasaje del Corazón","Antesala","Cámara de la Raíz","Guardián"]},
    "bosque_profundidad": {"name":"Raíces Profundas", "number":2, "pos":Vector2(300,520), "size":Vector2(610,330), "color":Color(0.86,0.56,0.24), "shape":"cave", "rooms":["Raíces","Túneles","Cámara","Abismo","Pozo","Cámara Raizada","Nido Antiguo"]},
    "cavernas": {"name":"Cavernas Olvidadas", "number":3, "pos":Vector2(950,120), "size":Vector2(650,340), "color":Color(0.62,0.40,0.96), "shape":"cave", "rooms":["Entrada","Cristales","Puente","Cámara Profunda"]},
    "bosque_sendero": {"name":"Minas Abandonadas", "number":4, "pos":Vector2(1570,155), "size":Vector2(560,315), "color":Color(0.92,0.68,0.30), "shape":"mine", "rooms":["Andén","Túnel","Rieles","Pozo"]},
    "bosque_santuario": {"name":"Ciudad Subterránea", "number":5, "pos":Vector2(2040,400), "size":Vector2(650,350), "color":Color(0.18,0.84,0.92), "shape":"city", "rooms":["Entrada","Plaza","Galería","Torre"]},
    "lago_oscuro": {"name":"Jardines Marchitos", "number":6, "pos":Vector2(2740,280), "size":Vector2(450,320), "color":Color(0.40,0.78,0.42), "shape":"swamp", "rooms":["Jardín","Invernadero","Raíces","Santuario"]},
    "templo_antiguo": {"name":"Lago de las Sombras", "number":7, "pos":Vector2(90,930), "size":Vector2(680,320), "color":Color(0.22,0.58,0.96), "shape":"lake", "rooms":["Orilla","Cascada","Lago","Profundidad"]},
    "ciudad_perdida": {"name":"Templo Hundido", "number":8, "pos":Vector2(870,720), "size":Vector2(650,350), "color":Color(0.60,0.54,0.96), "shape":"temple", "rooms":["Atrio","Nave","Cripta","Altar"]},
    "pantano_sombrio": {"name":"Abismo", "number":9, "pos":Vector2(1570,760), "size":Vector2(680,360), "color":Color(0.96,0.18,0.62), "shape":"abyss", "rooms":["Borde","Fosas","Puentes","Profundidad"]},
    "torre_abismo": {"name":"Ciudad Antigua", "number":10, "pos":Vector2(2510,820), "size":Vector2(570,350), "color":Color(0.64,0.72,0.94), "shape":"city", "rooms":["Puertas","Calles","Plaza","Torre"]},
    "cueva_secreta": {"name":"Santuario", "number":11, "pos":Vector2(850,1190), "size":Vector2(650,320), "color":Color(0.68,0.70,0.96), "shape":"temple", "rooms":["Entrada","Patio","Sala Sagrada","Cámara"]},
    "jefe_guardian": {"name":"Corazón del Mundo", "number":12, "pos":Vector2(1570,1230), "size":Vector2(700,380), "color":Color(0.24,0.58,1.0), "shape":"heart", "rooms":["Umbral","Santuario","Núcleo","Corazón"]}
}

const CONNECTIONS: Array = [
    ["bosque_entrada", "bosque_profundidad", "principal"],
    ["bosque_entrada", "cavernas", "secundaria"],
    ["bosque_profundidad", "templo_antiguo", "principal"],
    ["bosque_profundidad", "ciudad_perdida", "secundaria"],
    ["cavernas", "bosque_sendero", "principal"],
    ["cavernas", "bosque_santuario", "secundaria"],
    ["bosque_sendero", "bosque_santuario", "principal"],
    ["bosque_santuario", "lago_oscuro", "secundaria"],
    ["bosque_santuario", "pantano_sombrio", "principal"],
    ["templo_antiguo", "ciudad_perdida", "principal"],
    ["ciudad_perdida", "pantano_sombrio", "secundaria"],
    ["ciudad_perdida", "cueva_secreta", "secundaria"],
    ["pantano_sombrio", "torre_abismo", "principal"],
    ["pantano_sombrio", "jefe_guardian", "secundaria"],
    ["cueva_secreta", "jefe_guardian", "principal"],
    ["torre_abismo", "lago_oscuro", "secundaria"]
]

const ROOM_FEATURES: Dictionary = {
    "bosque_entrada": ["spawn", "enemy", "coins"],
    "bosque_profundidad": ["double_jump", "enemy", "checkpoint"],
    "cavernas": ["enemy", "crystal", "chest"],
    "bosque_sendero": ["enemy", "crystal", "checkpoint"],
    "bosque_santuario": ["shop", "checkpoint", "enemy"],
    "lago_oscuro": ["crystal", "potion", "life_fragment"],
    "templo_antiguo": ["crystal_heart", "potion", "enemy"],
    "ciudad_perdida": ["checkpoint", "life_fragment", "enemy"],
    "pantano_sombrio": ["isma_tear", "enemy", "chest"],
    "torre_abismo": ["shade_cloak", "enemy", "checkpoint"],
    "cueva_secreta": ["checkpoint", "crystal", "chest"],
    "jefe_guardian": ["boss", "goal", "checkpoint"]
}

const WORLD_MARKERS: Dictionary = {
    # Marcadores del mapa mundial. Los fragmentos futuros quedan
    # representados como objetivos conocidos solo cuando la zona ya fue descubierta.
    "bosque_entrada": {"fragment": "corazon_fragmento_01", "luma": true, "guardian": "guardian_bosque_01", "secret": true},
    "bosque_profundidad": {"fragment": "corazon_fragmento_02", "guardian": "guardian_raices_02", "secret": true},
    "cavernas": {"fragment": "corazon_fragmento_03", "guardian": "guardian_cavernas_03", "secret": true},
    "bosque_sendero": {"fragment": "corazon_fragmento_04", "guardian": "guardian_minas_04", "secret": true},
    "bosque_santuario": {"fragment": "corazon_fragmento_05", "guardian": "guardian_ciudad_05", "secret": true},
    "lago_oscuro": {"fragment": "corazon_fragmento_06", "guardian": "guardian_jardines_06", "secret": true},
    "templo_antiguo": {"fragment": "corazon_fragmento_07", "guardian": "guardian_lago_07", "secret": true},
    "ciudad_perdida": {"fragment": "corazon_fragmento_08", "guardian": "guardian_templo_08", "secret": true},
    "pantano_sombrio": {"fragment": "corazon_fragmento_09", "guardian": "guardian_abismo_09", "secret": true},
    "torre_abismo": {"fragment": "corazon_fragmento_10", "guardian": "guardian_ciudad_antigua_10", "secret": true},
    "cueva_secreta": {"fragment": "corazon_fragmento_11", "guardian": "guardian_santuario_11", "secret": true},
    "jefe_guardian": {"fragment": "corazon_fragmento_12", "guardian": "espejo_corazon_12", "secret": true}
}

const ROOM_LAYOUTS: Dictionary = {
    # 5 puntos por zona: principal -> pasaje; el pasaje se divide en
    # ruta secreta y desafio; el desafio conduce a la recompensa.
    "forest": [Vector2(0.08,0.56), Vector2(0.22,0.40), Vector2(0.38,0.24), Vector2(0.55,0.20), Vector2(0.72,0.34), Vector2(0.88,0.50), Vector2(0.78,0.72), Vector2(0.58,0.82), Vector2(0.38,0.76), Vector2(0.22,0.88), Vector2(0.48,0.48), Vector2(0.70,0.60)],
    "cave": [Vector2(0.10,0.48), Vector2(0.36,0.50), Vector2(0.60,0.25), Vector2(0.60,0.76), Vector2(0.88,0.52)],
    "secret": [Vector2(0.10,0.58), Vector2(0.36,0.55), Vector2(0.60,0.30), Vector2(0.60,0.78), Vector2(0.88,0.60)],
    "lake": [Vector2(0.10,0.42), Vector2(0.36,0.48), Vector2(0.60,0.25), Vector2(0.60,0.75), Vector2(0.88,0.52)],
    "temple": [Vector2(0.10,0.62), Vector2(0.36,0.55), Vector2(0.60,0.28), Vector2(0.60,0.78), Vector2(0.88,0.56)],
    "city": [Vector2(0.10,0.55), Vector2(0.36,0.52), Vector2(0.60,0.25), Vector2(0.60,0.78), Vector2(0.88,0.56)],
    "swamp": [Vector2(0.10,0.40), Vector2(0.36,0.48), Vector2(0.60,0.25), Vector2(0.60,0.76), Vector2(0.88,0.52)],
    "tower": [Vector2(0.50,0.90), Vector2(0.50,0.65), Vector2(0.28,0.45), Vector2(0.72,0.45), Vector2(0.72,0.12)],
    "mine": [Vector2(0.10,0.60), Vector2(0.36,0.55), Vector2(0.60,0.28), Vector2(0.60,0.78), Vector2(0.88,0.58)],
    "abyss": [Vector2(0.10,0.38), Vector2(0.36,0.50), Vector2(0.60,0.24), Vector2(0.60,0.78), Vector2(0.88,0.50)],
    "heart": [Vector2(0.10,0.60), Vector2(0.36,0.50), Vector2(0.60,0.25), Vector2(0.60,0.76), Vector2(0.88,0.48)],
    "boss": [Vector2(0.10,0.50), Vector2(0.36,0.50), Vector2(0.60,0.25), Vector2(0.60,0.76), Vector2(0.88,0.54)]
}

func _process(delta: float) -> void:
    pulse_time += delta
    if not visible:
        return
    _mini_redraw_accum += delta
    if not modo_minimapa:
        # Mapa grande: redibuja por datos nuevos o a ritmo limitado (pulso de sala actual)
        if _dirty or _mini_redraw_accum >= FULL_MAP_REDRAW_INTERVAL:
            _mini_redraw_accum = 0.0
            _dirty = false
            queue_redraw()
        return
    # Minimapa: redibujado limitado
    if _dirty or _mini_redraw_accum >= MINI_REDRAW_INTERVAL:
        _mini_redraw_accum = 0.0
        _dirty = false
        queue_redraw()

func configurar(room: String, seen: Dictionary, seen_rooms: Dictionary = {}, blocked: Dictionary = {}) -> void:
    modo_minimapa = false
    current_room = room
    visited = seen.duplicate()
    visited_rooms = seen_rooms.duplicate()
    blocked_doors = blocked.duplicate()
    _centrar_en_habitacion()
    _dirty = true
    queue_redraw()

func configurar_minimapa(room: String, seen: Dictionary, seen_rooms: Dictionary = {}, blocked: Dictionary = {}) -> void:
    modo_minimapa = true
    current_room = room
    visited = seen.duplicate()
    visited_rooms = seen_rooms.duplicate()
    blocked_doors = blocked.duplicate()
    var usable: Vector2 = size - MINI_MARGIN * 2.0
    if usable.x > 1.0 and usable.y > 1.0:
        zoom = minf(usable.x / MAP_SIZE.x, usable.y / MAP_SIZE.y)
        zoom = clampf(zoom, 0.065, 0.12)
    map_offset = -MAP_SIZE * zoom * 0.5 + Vector2(0, 8)
    _dirty = true
    queue_redraw()

func _unhandled_input(event: InputEvent) -> void:
    if modo_minimapa or not visible:
        return
    if event is InputEventMouseButton:
        if event.button_index == MOUSE_BUTTON_WHEEL_UP and event.pressed:
            _zoom_at(event.position, 1.12)
        elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.pressed:
            _zoom_at(event.position, 0.89)
        elif event.button_index == MOUSE_BUTTON_MIDDLE:
            dragging = event.pressed
            drag_start = event.position
            offset_start = map_offset
        elif event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
            _seleccionar_zona_con_clic(event.position)
    elif event is InputEventMouseMotion and dragging:
        map_offset = offset_start + (event.position - drag_start)
        _limitar_desplazamiento()
        queue_redraw()
    elif event is InputEventKey and event.pressed:
        match event.keycode:
            KEY_EQUAL, KEY_KP_ADD:
                _zoom_at(size * 0.5, 1.12)
            KEY_MINUS, KEY_KP_SUBTRACT:
                _zoom_at(size * 0.5, 0.89)
            KEY_0:
                zoom = 0.48
                _centrar_en_habitacion()
            KEY_C:
                _centrar_en_habitacion()

func _seleccionar_zona_con_clic(screen_pos: Vector2) -> void:
    # El clic solo centra zonas ya descubiertas; no permite revelar el mapa.
    var seleccionada: String = ""
    var distancia: float = INF
    for id in ZONES.keys():
        var zone_id: String = str(id)
        if not visited.has(zone_id) and zone_id != _current_zone_id():
            continue
        var poly: PackedVector2Array = _zone_polygon(zone_id)
        if Geometry2D.is_point_in_polygon(screen_pos, poly):
            seleccionada = zone_id
            break
        var d: float = screen_pos.distance_to(_zone_center(zone_id))
        if d < distancia and d < 95.0:
            distancia = d
            seleccionada = zone_id
    if seleccionada.is_empty():
        return
    var p: Vector2 = ZONES[seleccionada]["pos"] + ZONES[seleccionada]["size"] * 0.5
    map_offset = -(p * zoom) + size * 0.5
    _limitar_desplazamiento()
    _dirty = true
    queue_redraw()

func _zoom_at(screen_pos: Vector2, factor: float) -> void:
    var old_zoom: float = zoom
    zoom = clampf(zoom * factor, 0.28, 1.45)
    var map_center: Vector2 = size * 0.5
    var before: Vector2 = (screen_pos - map_center - map_offset) / maxf(old_zoom, 0.001)
    map_offset = screen_pos - map_center - before * zoom
    _limitar_desplazamiento()
    _dirty = true
    queue_redraw()

func _centrar_en_habitacion() -> void:
    var current_zone: String = _current_zone_id()
    if not ZONES.has(current_zone):
        map_offset = Vector2.ZERO
        return
    var p: Vector2 = ZONES[current_zone]["pos"] + ZONES[current_zone]["size"] * 0.5
    map_offset = -(p * zoom) + size * 0.5
    _limitar_desplazamiento()
    queue_redraw()

func _limitar_desplazamiento() -> void:
    var map_pixels: Vector2 = MAP_SIZE * zoom
    var margin: float = 55.0
    if map_pixels.x <= size.x:
        map_offset.x = (size.x - map_pixels.x) * 0.5
    else:
        map_offset.x = clamp(map_offset.x, size.x - map_pixels.x - margin, margin)
    if map_pixels.y <= size.y:
        map_offset.y = (size.y - map_pixels.y) * 0.5
    else:
        map_offset.y = clamp(map_offset.y, size.y - map_pixels.y - margin, margin)

func _map_to_screen(p: Vector2) -> Vector2:
    return size * 0.5 + map_offset + p * zoom

func _current_zone_id() -> String:
    if ZONES.has(current_room):
        return current_room
    for id in ZONES.keys():
        var base: String = str(id)
        if current_room.begins_with(base + "_"):
            return base
    return ""

func _zone_center(id: String) -> Vector2:
    var info: Dictionary = ZONES[id]
    return _map_to_screen(info["pos"] + info["size"] * 0.5)

func _zone_polygon(id: String, extra: float = 0.0) -> PackedVector2Array:
    var info: Dictionary = ZONES[id]
    var p: Vector2 = info["pos"] - Vector2(extra, extra)
    var s: Vector2 = info["size"] + Vector2(extra * 2.0, extra * 2.0)
    var shape: String = str(info["shape"])
    var points: PackedVector2Array
    match shape:
        "forest":
            points = PackedVector2Array([
                p + Vector2(s.x*0.02,s.y*0.46), p + Vector2(s.x*0.10,s.y*0.28),
                p + Vector2(s.x*0.22,s.y*0.30), p + Vector2(s.x*0.26,s.y*0.12),
                p + Vector2(s.x*0.43,s.y*0.05), p + Vector2(s.x*0.56,s.y*0.14),
                p + Vector2(s.x*0.72,s.y*0.07), p + Vector2(s.x*0.91,s.y*0.20),
                p + Vector2(s.x,s.y*0.40), p + Vector2(s.x*0.91,s.y*0.56),
                p + Vector2(s.x*0.96,s.y*0.76), p + Vector2(s.x*0.76,s.y*0.91),
                p + Vector2(s.x*0.58,s.y*0.84), p + Vector2(s.x*0.45,s.y),
                p + Vector2(s.x*0.25,s.y*0.89), p + Vector2(s.x*0.12,s.y*0.74),
                p + Vector2(s.x*0.02,s.y*0.80)
            ])
        "cave":
            points = PackedVector2Array([
                p + Vector2(0,s.y*0.50), p + Vector2(s.x*0.08,s.y*0.30),
                p + Vector2(s.x*0.20,s.y*0.34), p + Vector2(s.x*0.26,s.y*0.12),
                p + Vector2(s.x*0.40,s.y*0.05), p + Vector2(s.x*0.52,s.y*0.20),
                p + Vector2(s.x*0.67,s.y*0.10), p + Vector2(s.x*0.82,s.y*0.22),
                p + Vector2(s.x,s.y*0.38), p + Vector2(s.x*0.91,s.y*0.54),
                p + Vector2(s.x*0.98,s.y*0.74), p + Vector2(s.x*0.79,s.y*0.66),
                p + Vector2(s.x*0.69,s.y*0.92), p + Vector2(s.x*0.50,s.y*0.82),
                p + Vector2(s.x*0.36,s.y), p + Vector2(s.x*0.20,s.y*0.82),
                p + Vector2(s.x*0.06,s.y*0.90)
            ])
        "lake":
            points = PackedVector2Array([
                p + Vector2(0,s.y*0.48), p + Vector2(s.x*0.12,s.y*0.28),
                p + Vector2(s.x*0.27,s.y*0.22), p + Vector2(s.x*0.40,s.y*0.08),
                p + Vector2(s.x*0.57,s.y*0.16), p + Vector2(s.x*0.72,s.y*0.05),
                p + Vector2(s.x*0.90,s.y*0.22), p + Vector2(s.x,s.y*0.42),
                p + Vector2(s.x*0.90,s.y*0.60), p + Vector2(s.x*0.96,s.y*0.78),
                p + Vector2(s.x*0.74,s.y*0.88), p + Vector2(s.x*0.57,s.y*0.76),
                p + Vector2(s.x*0.42,s.y), p + Vector2(s.x*0.24,s.y*0.86),
                p + Vector2(s.x*0.08,s.y*0.76)
            ])
        "temple":
            points = PackedVector2Array([
                p + Vector2(0,s.y*0.30), p + Vector2(s.x*0.16,s.y*0.10),
                p + Vector2(s.x*0.30,s.y*0.16), p + Vector2(s.x*0.42,0),
                p + Vector2(s.x*0.58,s.y*0.12), p + Vector2(s.x*0.76,s.y*0.04),
                p + Vector2(s.x,s.y*0.24), p + Vector2(s.x*0.90,s.y*0.44),
                p + Vector2(s.x,s.y*0.68), p + Vector2(s.x*0.80,s.y*0.86),
                p + Vector2(s.x*0.61,s.y*0.76), p + Vector2(s.x*0.47,s.y),
                p + Vector2(s.x*0.29,s.y*0.84), p + Vector2(s.x*0.12,s.y),
                p + Vector2(s.x*0.08,s.y*0.60)
            ])
        "city":
            points = PackedVector2Array([
                p + Vector2(0,s.y*0.38), p + Vector2(s.x*0.12,s.y*0.18),
                p + Vector2(s.x*0.23,s.y*0.22), p + Vector2(s.x*0.31,s.y*0.04),
                p + Vector2(s.x*0.46,s.y*0.16), p + Vector2(s.x*0.58,0),
                p + Vector2(s.x*0.72,s.y*0.12), p + Vector2(s.x*0.88,s.y*0.08),
                p + Vector2(s.x,s.y*0.30), p + Vector2(s.x*0.86,s.y*0.48),
                p + Vector2(s.x,s.y*0.68), p + Vector2(s.x*0.74,s.y*0.88),
                p + Vector2(s.x*0.57,s.y*0.76), p + Vector2(s.x*0.44,s.y),
                p + Vector2(s.x*0.29,s.y*0.82), p + Vector2(s.x*0.14,s.y),
                p + Vector2(s.x*0.06,s.y*0.68)
            ])
        "swamp":
            points = PackedVector2Array([
                p + Vector2(0,s.y*0.44), p + Vector2(s.x*0.11,s.y*0.25),
                p + Vector2(s.x*0.25,s.y*0.31), p + Vector2(s.x*0.38,s.y*0.08),
                p + Vector2(s.x*0.53,s.y*0.18), p + Vector2(s.x*0.70,s.y*0.06),
                p + Vector2(s.x*0.90,s.y*0.22), p + Vector2(s.x,s.y*0.44),
                p + Vector2(s.x*0.91,s.y*0.58), p + Vector2(s.x*0.98,s.y*0.78),
                p + Vector2(s.x*0.77,s.y*0.90), p + Vector2(s.x*0.59,s.y*0.80),
                p + Vector2(s.x*0.42,s.y), p + Vector2(s.x*0.25,s.y*0.84),
                p + Vector2(s.x*0.09,s.y*0.78)
            ])
        "secret":
            points = PackedVector2Array([
                p + Vector2(0,s.y*0.52), p + Vector2(s.x*0.12,s.y*0.30),
                p + Vector2(s.x*0.28,s.y*0.34), p + Vector2(s.x*0.39,s.y*0.10),
                p + Vector2(s.x*0.57,s.y*0.18), p + Vector2(s.x*0.76,s.y*0.06),
                p + Vector2(s.x,s.y*0.30), p + Vector2(s.x*0.90,s.y*0.52),
                p + Vector2(s.x*0.98,s.y*0.72), p + Vector2(s.x*0.76,s.y*0.88),
                p + Vector2(s.x*0.57,s.y*0.78), p + Vector2(s.x*0.40,s.y),
                p + Vector2(s.x*0.22,s.y*0.84), p + Vector2(s.x*0.06,s.y*0.72)
            ])
        "tower":
            points = PackedVector2Array([
                p + Vector2(s.x*0.30,s.y), p + Vector2(s.x*0.24,s.y*0.76),
                p + Vector2(s.x*0.34,s.y*0.62), p + Vector2(s.x*0.26,s.y*0.48),
                p + Vector2(s.x*0.37,s.y*0.34), p + Vector2(s.x*0.30,s.y*0.20),
                p + Vector2(s.x*0.42,0), p + Vector2(s.x*0.60,s.y*0.06),
                p + Vector2(s.x*0.71,s.y*0.22), p + Vector2(s.x*0.62,s.y*0.39),
                p + Vector2(s.x*0.74,s.y*0.55), p + Vector2(s.x*0.65,s.y*0.70),
                p + Vector2(s.x*0.75,s.y*0.84), p + Vector2(s.x*0.60,s.y),
                p + Vector2(s.x*0.45,s.y*0.84)
            ])
        "mine":
            points = PackedVector2Array([
                p + Vector2(0,s.y*0.50), p + Vector2(s.x*0.10,s.y*0.22),
                p + Vector2(s.x*0.28,s.y*0.28), p + Vector2(s.x*0.40,s.y*0.08),
                p + Vector2(s.x*0.62,s.y*0.18), p + Vector2(s.x*0.80,s.y*0.06),
                p + Vector2(s.x,s.y*0.36), p + Vector2(s.x*0.90,s.y*0.60),
                p + Vector2(s.x,s.y*0.82), p + Vector2(s.x*0.70,s.y*0.94),
                p + Vector2(s.x*0.52,s.y*0.78), p + Vector2(s.x*0.32,s.y),
                p + Vector2(s.x*0.16,s.y*0.82)
            ])
        "abyss":
            points = PackedVector2Array([
                p + Vector2(s.x*0.08,s.y*0.10), p + Vector2(s.x*0.34,s.y*0.04),
                p + Vector2(s.x*0.56,s.y*0.14), p + Vector2(s.x*0.88,s.y*0.08),
                p + Vector2(s.x,s.y*0.28), p + Vector2(s.x*0.82,s.y*0.44),
                p + Vector2(s.x*0.94,s.y*0.64), p + Vector2(s.x*0.70,s.y*0.72),
                p + Vector2(s.x*0.82,s.y), p + Vector2(s.x*0.48,s.y*0.90),
                p + Vector2(s.x*0.30,s.y), p + Vector2(s.x*0.14,s.y*0.78),
                p + Vector2(s.x*0.22,s.y*0.54), p
            ])
        "heart":
            points = PackedVector2Array([
                p + Vector2(s.x*0.05,s.y*0.30), p + Vector2(s.x*0.18,s.y*0.08),
                p + Vector2(s.x*0.36,s.y*0.02), p + Vector2(s.x*0.50,s.y*0.18),
                p + Vector2(s.x*0.64,s.y*0.02), p + Vector2(s.x*0.84,s.y*0.08),
                p + Vector2(s.x*0.96,s.y*0.30), p + Vector2(s.x*0.84,s.y*0.58),
                p + Vector2(s.x*0.66,s.y*0.76), p + Vector2(s.x*0.50,s.y),
                p + Vector2(s.x*0.34,s.y*0.76), p + Vector2(s.x*0.16,s.y*0.58)
            ])
        "boss":
            points = PackedVector2Array([
                p + Vector2(s.x*0.05,s.y*0.44), p + Vector2(s.x*0.16,s.y*0.24),
                p + Vector2(s.x*0.34,s.y*0.18), p + Vector2(s.x*0.43,s.y*0.02),
                p + Vector2(s.x*0.63,s.y*0.10), p + Vector2(s.x*0.82,s.y*0.20),
                p + Vector2(s.x,s.y*0.40), p + Vector2(s.x*0.90,s.y*0.62),
                p + Vector2(s.x*0.78,s.y*0.88), p + Vector2(s.x*0.56,s.y),
                p + Vector2(s.x*0.36,s.y*0.90), p + Vector2(s.x*0.16,s.y*0.76)
            ])
        _:
            points = PackedVector2Array([
                p + Vector2(0,s.y*0.45), p + Vector2(s.x*0.18,0), p + Vector2(s.x*0.50,s.y*0.08),
                p + Vector2(s.x*0.82,0), p + Vector2(s.x,s.y*0.44), p + Vector2(s.x*0.78,s.y),
                p + Vector2(s.x*0.46,s.y*0.90), p + Vector2(s.x*0.18,s.y)
            ])
    var screen_points: PackedVector2Array = PackedVector2Array()
    for point in points:
        screen_points.append(_map_to_screen(point))
    return screen_points

func _room_center_inside_zone(id: String, index: int) -> Vector2:
    var info: Dictionary = ZONES[id]
    var shape: String = str(info["shape"])
    var layout: Array = ROOM_LAYOUTS.get(shape, ROOM_LAYOUTS["forest"])
    var normalized: Vector2 = layout[index % layout.size()]
    return _map_to_screen(info["pos"] + info["size"] * normalized)

func _draw() -> void:
    if modo_minimapa:
        _draw_minimapa()
    else:
        _draw_mapa_grande()

func _draw_mapa_grande() -> void:
    var font: Font = ThemeDB.fallback_font
    draw_rect(Rect2(Vector2.ZERO, size), Color(0.003,0.004,0.008,1.0), true)
    _draw_background_stars(false)
    _draw_vignette()
    _draw_ornate_frame()
    for id in ZONES.keys():
        _draw_zone(id, false)
    _draw_connections(false)
    _draw_blocked_routes(false)
    _draw_title(font)
    _draw_zone_index(font)
    _draw_progress(font)
    _draw_current_card(font)
    _draw_legend(font)
    _draw_controls(font)
    _draw_compass(font, false)

func _draw_minimapa() -> void:
    var font: Font = ThemeDB.fallback_font
    var panel: Rect2 = Rect2(Vector2.ZERO, size)

    # StyleBox cacheado (no crear cada frame)
    if _cached_mini_box == null:
        _cached_mini_box = _crear_box(Color(0.002, 0.004, 0.008, 0.97), Color(0.57, 0.61, 0.63, 0.82), 2.0)
    draw_style_box(_cached_mini_box, panel.grow(-1.0))
    draw_line(Vector2(14, 39), Vector2(size.x - 14, 39), Color(0.78, 0.70, 0.46, 0.30), 1.0)

    var zone_id: String = _current_zone_id()
    var zone_name: String = str(ZONES[zone_id]["name"]) if ZONES.has(zone_id) else "SIN ZONA"
    var accent: Color = ZONES[zone_id]["color"] if ZONES.has(zone_id) else Color(0.55, 0.65, 0.72)
    var known_rooms: int = _known_room_count(zone_id)
    var total_rooms: int = _room_count_for_zone(zone_id)

    draw_string(font, Vector2(18, 26), "MAPA DE ZONA", HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color(0.90, 0.88, 0.78))
    draw_string(font, Vector2(size.x - 124, 26), "%d/%d SALAS" % [known_rooms, total_rooms], HORIZONTAL_ALIGNMENT_LEFT, -1, 9, Color(accent.r, accent.g, accent.b, 0.95))

    if ZONES.has(zone_id):
        _draw_zone_minimap_card_fast(zone_id, accent, font)
    else:
        draw_string(font, Vector2(18, 78), "Explora para cartografiar esta zona.", HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color(0.55, 0.60, 0.63))

    # Barra de exploración
    var progress: float = float(known_rooms) / float(maxi(total_rooms, 1))
    draw_rect(Rect2(18, size.y - 49, size.x - 36, 5), Color(0.05, 0.07, 0.08, 1.0), true)
    draw_rect(Rect2(18, size.y - 49, (size.x - 36) * progress, 5), Color(accent.r, accent.g, accent.b, 0.82), true)
    draw_string(font, Vector2(18, size.y - 25), zone_name, HORIZONTAL_ALIGNMENT_LEFT, size.x - 120, 10, Color(0.84, 0.88, 0.88))
    draw_string(font, Vector2(size.x - 90, size.y - 25), "M · MUNDO", HORIZONTAL_ALIGNMENT_LEFT, -1, 9, Color(0.57, 0.75, 0.68))


func _draw_zone_minimap_card_fast(zone_id: String, accent: Color, font: Font) -> void:
    ## Versión ligera del minimapa de zona: menos polígonos, menos transformaciones.
    var info: Dictionary = ZONES[zone_id]
    var area: Rect2 = Rect2(18, 55, size.x - 36, size.y - 112)

    # Fondo de zona simple
    draw_rect(area, Color(accent.r * 0.12, accent.g * 0.12, accent.b * 0.14, 0.55), true)
    draw_rect(area, Color(accent.r, accent.g, accent.b, 0.35), false, 1.5)

    # Número y nombre
    draw_circle(area.position + Vector2(20, 20), 10.0, Color(accent.r, accent.g, accent.b, 0.85))
    draw_string(font, area.position + Vector2(17, 24), str(info.get("number", "?")), HORIZONTAL_ALIGNMENT_CENTER, 7, 9, Color(0.02, 0.03, 0.06, 1.0))
    draw_string(font, area.position + Vector2(38, 24), str(info.get("name", "")), HORIZONTAL_ALIGNMENT_LEFT, area.size.x - 50, 10, Color(0.78, 0.83, 0.87, 0.88))

    # Habitaciones como puntos en rejilla simple (barato)
    var room_total: int = _room_count_for_zone(zone_id)
    if room_total <= 0:
        return

    var cols: int = mini(4, room_total)
    var rows: int = ceili(float(room_total) / float(cols))
    var margin: Vector2 = Vector2(28, 48)
    var usable: Vector2 = area.size - margin - Vector2(16, 16)
    var step: Vector2 = Vector2(
        usable.x / maxf(float(cols - 1), 1.0),
        usable.y / maxf(float(rows - 1), 1.0)
    )
    if cols == 1:
        step.x = 0.0
    if rows == 1:
        step.y = 0.0

    var origin: Vector2 = area.position + margin
    for i in range(room_total):
        var col: int = i % cols
        var row: int = int(i / cols)
        var pos: Vector2 = origin + Vector2(step.x * col, step.y * row)
        var key: String = _room_id_for_zone(zone_id, i)
        var known: bool = visited_rooms.has(key) or (i == 0 and visited.has(zone_id))
        var active: bool = key == current_room

        if active:
            var pulse: float = 1.0 + 0.12 * sin(pulse_time * 3.5)
            draw_circle(pos, 11.0 * pulse, Color(accent.r, accent.g, accent.b, 0.14))
            draw_circle(pos, 7.0, Color(0.95, 1.0, 0.98, 0.95))
            draw_arc(pos, 9.0, 0.0, TAU, 16, Color(accent.r, accent.g, accent.b, 0.9), 1.5)
        elif known:
            draw_circle(pos, 6.5, Color(accent.r, accent.g, accent.b, 0.35))
            draw_circle(pos, 3.5, Color(0.90, 0.95, 1.0, 0.9))
        else:
            draw_circle(pos, 4.0, Color(0.22, 0.26, 0.30, 0.4))

func _known_room_count(zone_id: String) -> int:
    if zone_id.is_empty() or not ZONES.has(zone_id):
        return 0
    var total: int = 0
    var room_total: int = _room_count_for_zone(zone_id)
    for i in range(room_total):
        if visited_rooms.has(_room_id_for_zone(zone_id, i)) or (i == 0 and visited.has(zone_id)):
            total += 1
    return total

func _draw_title(font: Font) -> void:
    var center_x: float = 350.0
    draw_string(font, Vector2(42,55), "✦", HORIZONTAL_ALIGNMENT_LEFT, -1, 22, Color(0.80,0.66,0.38,0.85))
    draw_string(font, Vector2(42,88), "MAPA DEL CORAZÓN DEL MUNDO", HORIZONTAL_ALIGNMENT_LEFT, -1, 38, Color(0.91,0.86,0.72))
    draw_string(font, Vector2(center_x,88), "✦", HORIZONTAL_ALIGNMENT_LEFT, -1, 22, Color(0.80,0.66,0.38,0.85))
    draw_line(Vector2(48,101), Vector2(350,101), Color(0.76,0.63,0.38,0.58), 1.0)
    draw_line(Vector2(72,106), Vector2(326,106), Color(0.76,0.63,0.38,0.25), 1.0)
    draw_string(font, Vector2(50,128), "12 ZONAS  ·  CARTOGRAFÍA DEL MUNDO", HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color(0.53,0.58,0.59))

func _draw_vignette() -> void:
    # Viñeta barata: solo 2 bandas (arriba/abajo)
    var edge: float = 72.0
    draw_rect(Rect2(0, 0, size.x, edge), Color(0.0, 0.0, 0.0, 0.16), true)
    draw_rect(Rect2(0, size.y - edge, size.x, edge), Color(0.0, 0.0, 0.0, 0.20), true)

func _draw_ornate_frame() -> void:
    var c: Color = Color(0.62,0.50,0.29,0.52)
    var c2: Color = Color(0.78,0.67,0.42,0.30)
    draw_rect(Rect2(12,12,size.x-24,size.y-24), Color(0.0,0.0,0.0,0), false, 1.0)
    draw_rect(Rect2(20,20,size.x-40,size.y-40), Color(0.0,0.0,0.0,0), false, 1.0)
    for x in [18.0, size.x-18.0]:
        draw_circle(Vector2(x,18),4,c)
        draw_circle(Vector2(x, size.y-18),4,c)
    draw_line(Vector2(18,18),Vector2(120,18),c,1.0)
    draw_line(Vector2(size.x-120,18),Vector2(size.x-18,18),c,1.0)
    draw_line(Vector2(18,size.y-18),Vector2(120,size.y-18),c,1.0)
    draw_line(Vector2(size.x-120,size.y-18),Vector2(size.x-18,size.y-18),c,1.0)
    draw_line(Vector2(18,18),Vector2(18,120),c,1.0)
    draw_line(Vector2(size.x-18,18),Vector2(size.x-18,120),c,1.0)
    draw_line(Vector2(18,size.y-120),Vector2(18,size.y-18),c,1.0)
    draw_line(Vector2(size.x-18,size.y-120),Vector2(size.x-18,size.y-18),c,1.0)
    draw_line(Vector2(135,18),Vector2(190,18),c2,2.0)
    draw_line(Vector2(size.x-190,18),Vector2(size.x-135,18),c2,2.0)
    draw_line(Vector2(135,size.y-18),Vector2(190,size.y-18),c2,2.0)
    draw_line(Vector2(size.x-190,size.y-18),Vector2(size.x-135,size.y-18),c2,2.0)

func _draw_background_stars(mini: bool) -> void:
    # Estrellas cacheadas por tamaño de control (no recalcular cada frame)
    var count: int = 12 if mini else 36
    var alpha: float = 0.12 if mini else 0.18
    if _cached_stars.is_empty() or _cached_stars_size != size:
        _cached_stars = PackedVector2Array()
        _cached_stars_size = size
        for i in range(count):
            var x: float = fmod(float(i * 173 + 41), maxf(size.x, 1.0))
            var y: float = fmod(float(i * 97 + 73), maxf(size.y, 1.0))
            _cached_stars.append(Vector2(x, y))
    var r: float = 1.0 if mini else 1.3
    var col := Color(0.78, 0.74, 0.62, alpha)
    for p in _cached_stars:
        draw_circle(p, r, col)

func _draw_connections(mini: bool) -> void:
    for connection in CONNECTIONS:
        var a_id: String = str(connection[0])
        var b_id: String = str(connection[1])
        var tipo: String = str(connection[2])
        var pa: Vector2 = _zone_center(a_id)
        var pb: Vector2 = _zone_center(b_id)
        var known: bool = visited.has(a_id) and visited.has(b_id)
        var current_zone: String = _current_zone_id()
        var near_current: bool = a_id == current_zone or b_id == current_zone
        if mini and not known and not near_current:
            continue
        var mid: Vector2 = (pa + pb) * 0.5
        var bend_sign: float = 1.0 if (ZONES[a_id]["number"] + ZONES[b_id]["number"]) % 2 == 0 else -1.0
        var bend: Vector2 = Vector2(0, 30.0 * bend_sign) if abs(pb.x-pa.x) > abs(pb.y-pa.y) else Vector2(30.0 * bend_sign, 0)
        var route := PackedVector2Array([pa, mid + bend, pb])
        var alpha: float = 0.98 if near_current else (0.82 if known else 0.16)
        var width: float = 1.2 if mini else 2.2
        var color: Color = Color(0.92,0.90,0.78,alpha) if tipo == "principal" else Color(0.70,0.78,0.88,alpha)
        if tipo == "principal":
            draw_polyline(route, Color(0.02,0.03,0.06,alpha * 0.65), width + (3.0 if not mini else 1.5), false)
            draw_polyline(route, color, width, false)
        else:
            draw_dashed_line(pa, mid+bend, color, width, 9.0 if mini else 14.0)
            draw_dashed_line(mid+bend, pb, color, width, 9.0 if mini else 14.0)
        if known or near_current:
            draw_circle(mid+bend, 2.0 if mini else 3.2, Color(0.86,0.94,1.0,0.82))

func _draw_zone(id: String, mini: bool) -> void:
    var info: Dictionary = ZONES[id]
    var discovered: bool = visited.has(id)
    var active: bool = id == _current_zone_id()
    var accent: Color = info["color"]
    var poly: PackedVector2Array = _zone_polygon(id, 8.0 if active else 0.0)
    var fill_alpha: float = 0.003 if not discovered else 0.014
    if active:
        fill_alpha = 0.055
    if mini:
        fill_alpha *= 0.90
    draw_colored_polygon(poly,Color(accent.r,accent.g,accent.b,fill_alpha))
    var border_alpha: float = 0.05 if not discovered else 0.12
    if active:
        border_alpha = 0.42
    draw_polyline(poly,Color(accent.r,accent.g,accent.b,border_alpha),0.8 if mini else 1.4,true)
    # Zonas no descubiertas: solo silueta (mucho más barato)
    if discovered or active:
        _draw_zone_texture(id, poly, accent, mini, discovered)
        _draw_zone_mini_rooms(id, accent, mini, discovered)
    if not mini:
        var font: Font = ThemeDB.fallback_font
        var title_color: Color = Color(0.88,0.85,0.76) if discovered else Color(0.31,0.33,0.34)
        var center: Vector2 = _zone_center(id)
        var label_y: float = center.y - min(float(info["size"].y) * zoom * 0.42, 110.0)
        draw_string(font,Vector2(center.x-150,label_y),str(info["name"]) if discovered else "REGIÓN DESCONOCIDA",HORIZONTAL_ALIGNMENT_CENTER,300,13,title_color)
        if discovered:
            draw_string(font,Vector2(center.x-100,label_y+18),"REGIÓN %02d" % _zone_number(id),HORIZONTAL_ALIGNMENT_CENTER,200,9,Color(accent.r,accent.g,accent.b,0.85))
            _draw_room_features_in_zone(id,accent)
            _draw_world_markers(id, accent, false)

func _draw_zone_texture(id: String, poly: PackedVector2Array, accent: Color, mini: bool, discovered: bool) -> void:
    var info: Dictionary = ZONES[id]
    var center: Vector2 = _zone_center(id)
    var alpha: float = 0.045 if discovered else 0.012
    if mini:
        alpha *= 0.7
    match str(info["shape"]):
        "forest":
            for i in range(5):
                var p: Vector2 = center + Vector2((i-2)*38.0,-18.0+float((i%2)*34)) * zoom
                draw_line(p+Vector2(-8,16)*zoom,p+Vector2(0,-10)*zoom,Color(accent.r,accent.g,accent.b,alpha),1.2)
                draw_circle(p+Vector2(0,-15)*zoom,5.0*zoom,Color(accent.r,accent.g,accent.b,alpha))
        "cave":
            for i in range(6):
                var x: float = center.x + (float(i)-2.5)*28.0*zoom
                var top: float = center.y - 36.0*zoom
                draw_colored_polygon(PackedVector2Array([Vector2(x-7,top),Vector2(x+7,top),Vector2(x,top+26*zoom)]),Color(accent.r,accent.g,accent.b,alpha))
        "lake":
            for i in range(4):
                var yy: float = center.y + (float(i)-1.5)*15.0*zoom
                draw_arc(Vector2(center.x,yy),34.0*zoom,0.1,3.0,20,Color(accent.r,accent.g,accent.b,alpha),1.0)
        "temple":
            for i in range(4):
                var x2: float = center.x + (float(i)-1.5)*26.0*zoom
                draw_line(Vector2(x2,center.y+35*zoom),Vector2(x2,center.y-25*zoom),Color(accent.r,accent.g,accent.b,alpha),2.0)
                draw_arc(Vector2(x2,center.y-24*zoom),7.0*zoom,PI,TAU,12,Color(accent.r,accent.g,accent.b,alpha),1.5)
        "city":
            for i in range(6):
                var x3: float = center.x + (float(i)-2.5)*24.0*zoom
                var h: float = (20.0+float((i%3)*12))*zoom
                draw_rect(Rect2(x3-7*zoom,center.y+20*zoom-h,14*zoom,h),Color(accent.r,accent.g,accent.b,alpha),true)
        "swamp":
            for i in range(5):
                var p2: Vector2 = center + Vector2((i-2)*30.0,12.0*sin(float(i))) * zoom
                draw_line(p2,p2+Vector2(0,-30)*zoom,Color(accent.r,accent.g,accent.b,alpha),1.2)
                draw_circle(p2+Vector2(0,-32)*zoom,5*zoom,Color(accent.r,accent.g,accent.b,alpha))
        "tower":
            draw_line(center+Vector2(-12,35)*zoom,center+Vector2(-12,-55)*zoom,Color(accent.r,accent.g,accent.b,alpha),2.0)
            draw_line(center+Vector2(12,35)*zoom,center+Vector2(12,-55)*zoom,Color(accent.r,accent.g,accent.b,alpha),2.0)
            draw_colored_polygon(PackedVector2Array([center+Vector2(-24,-55)*zoom,center+Vector2(0,-78)*zoom,center+Vector2(24,-55)*zoom]),Color(accent.r,accent.g,accent.b,alpha))
        "mine":
            for i in range(4):
                var mx: float = center.x + (float(i)-1.5)*34.0*zoom
                draw_line(Vector2(mx,center.y+24*zoom),Vector2(mx,center.y-24*zoom),Color(accent.r,accent.g,accent.b,alpha),2.0)
                draw_line(Vector2(mx-10*zoom,center.y+18*zoom),Vector2(mx+10*zoom,center.y+18*zoom),Color(accent.r,accent.g,accent.b,alpha),1.2)
        "abyss":
            for i in range(5):
                var ax: float = center.x + (float(i)-2.0)*28.0*zoom
                draw_line(Vector2(ax,center.y-28*zoom),Vector2(ax+8*zoom,center.y+30*zoom),Color(accent.r,accent.g,accent.b,alpha),1.5)
        "heart":
            draw_colored_polygon(PackedVector2Array([center+Vector2(-24,-8)*zoom,center+Vector2(-10,-28)*zoom,center+Vector2(0,-14)*zoom,center+Vector2(10,-28)*zoom,center+Vector2(24,-8)*zoom,center+Vector2(0,34)*zoom]),Color(accent.r,accent.g,accent.b,alpha))
        "boss":
            draw_circle(center,34*zoom,Color(accent.r,accent.g,accent.b,alpha),false,2.0)
            draw_circle(center,17*zoom,Color(accent.r,accent.g,accent.b,alpha),false,1.2)

func _draw_zone_mini_rooms(id: String, accent: Color, mini: bool, discovered: bool) -> void:
    # La sala principal se descubre al entrar a la zona. Las 4 mini-salas
    # permanecen completamente ocultas hasta ser visitadas.
    if not discovered:
        return
    var info: Dictionary = ZONES[id]
    var centers: Array[Vector2] = []
    for i in range(5):
        centers.append(_room_center_inside_zone(id, i))

    # Grafo interno real de las mini-salas: Principal -> Pasaje;
    # Pasaje -> Secreta/Desafío; Desafío -> Recompensa.
    var room_edges: Array = [[0,1],[1,2],[1,3],[3,4]]
    for edge in room_edges:
        var ai: int = int(edge[0])
        var bi: int = int(edge[1])
        var room_a: String = _room_id_for_zone(id, ai)
        var room_b: String = _room_id_for_zone(id, bi)
        if not (visited_rooms.has(room_a) and visited_rooms.has(room_b)):
            continue
        var a: Vector2 = centers[ai]
        var b: Vector2 = centers[bi]
        var bend: Vector2 = Vector2(0, (18.0 if ai % 2 == 0 else -18.0) * zoom)
        if str(info["shape"]) == "tower":
            bend = Vector2((18.0 if ai % 2 == 0 else -18.0) * zoom, 0)
        var mid: Vector2 = (a + b) * 0.5 + bend
        var route := PackedVector2Array([a, mid, b])
        var outer_width: float = 12.0 if not mini else 4.0
        var inner_width: float = 4.0 if not mini else 1.6
        draw_polyline(route, Color(0.01,0.015,0.025,0.88), outer_width, false)
        draw_polyline(route, Color(accent.r,accent.g,accent.b,0.86), inner_width, false)
        draw_circle(mid, 2.0 if mini else 3.0, Color(0.90,0.96,1.0,0.82))

    var room_types: Array[String] = _room_labels_for_zone(id)
    for i in range(centers.size()):
        var center: Vector2 = centers[i]
        var room_key: String = _room_id_for_zone(id, i)
        var room_discovered: bool = visited_rooms.has(room_key) or (i == 0 and discovered)
        if not room_discovered:
            continue
        var room_size: Vector2 = Vector2(176.0, 70.0)
        if str(info["shape"]) == "tower":
            room_size = Vector2(104.0, 104.0)
        elif str(info["shape"]) == "lake":
            room_size = Vector2(204.0, 62.0)
        elif str(info["shape"]) == "boss":
            room_size = Vector2(198.0, 86.0)
        var fill_a: float = 0.22 if not mini else 0.16
        var border_a: float = 0.82 if not mini else 0.70
        if room_key == current_room:
            fill_a = 0.34
            border_a = 1.0
        var rp: PackedVector2Array = _room_chamber(center, room_size, i, str(info["shape"]))
        draw_colored_polygon(rp, Color(accent.r,accent.g,accent.b,fill_a))
        draw_polyline(rp, Color(accent.r,accent.g,accent.b,border_a), 1.2 if mini else 1.8, true)
        draw_circle(center, 3.0 if not mini else 1.5, Color(0.92,0.97,1.0,0.90))
        if not mini:
            var font: Font = ThemeDB.fallback_font
            var label: String = "%d  %s" % [i + 1, room_types[i]]
            draw_string(font, center + Vector2(-70,-room_size.y*zoom*0.18), label, HORIZONTAL_ALIGNMENT_CENTER, 140, 9, Color(0.86,0.91,0.96,0.84))
        if room_key == current_room and not mini:
            var pulse: float = 1.0 + 0.14 * sin(pulse_time * 4.0)
            draw_circle(center, 10.0 * pulse, Color(accent.r,accent.g,accent.b,0.11))
            draw_arc(center, 13.0 * pulse, 0.0, TAU, 12, Color(0.88,1.0,0.94,0.96), 1.4)

func _draw_room_notches(poly: PackedVector2Array, accent: Color, mini: bool, discovered: bool, index: int) -> void:
    if poly.is_empty():
        return
    var a: Vector2 = poly[0]
    var b: Vector2 = poly[1]
    var c: Vector2 = poly[2]
    var alpha: float = 0.46 if discovered else 0.10
    var width: float = 1.0 if mini else 1.7
    var p1: Vector2 = a.lerp(b, 0.38)
    var p2: Vector2 = a.lerp(b, 0.58)
    var inset: Vector2 = (c - a).normalized() * (4.0 if mini else 9.0)
    draw_line(p1, p1 + inset, Color(accent.r,accent.g,accent.b,alpha), width)
    draw_line(p2, p2 + inset, Color(accent.r,accent.g,accent.b,alpha), width)
    if index % 2 == 0:
        var edge: Vector2 = poly[3]
        var edge2: Vector2 = poly[4]
        var q1: Vector2 = edge.lerp(edge2,0.46)
        draw_circle(q1, 2.0 if mini else 3.5, Color(accent.r,accent.g,accent.b,alpha))

func _room_chamber(center: Vector2, room_size: Vector2, index: int, shape: String) -> PackedVector2Array:
    var w: float = room_size.x * zoom
    var h: float = room_size.y * zoom
    var k: float = float(index)
    if shape == "tower":
        return PackedVector2Array([
            center + Vector2(-w*0.30,-h*0.50), center + Vector2(w*0.08,-h*0.56),
            center + Vector2(w*0.48,-h*0.28), center + Vector2(w*0.40,h*0.20),
            center + Vector2(w*0.16,h*0.52), center + Vector2(-w*0.30,h*0.44),
            center + Vector2(-w*0.50,h*0.06), center + Vector2(-w*0.42,-h*0.28)
        ])
    var a: float = 0.04 * sin(k * 2.3)
    var b: float = 0.06 * cos(k * 1.4)
    return PackedVector2Array([
        center + Vector2(-w*0.50,-h*(0.05+b)),
        center + Vector2(-w*0.40,-h*0.40),
        center + Vector2(-w*0.14,-h*(0.53+a)),
        center + Vector2(w*0.16,-h*0.45),
        center + Vector2(w*0.43,-h*(0.22-b)),
        center + Vector2(w*0.51,h*0.08),
        center + Vector2(w*0.31,h*0.42),
        center + Vector2(-w*0.02,h*0.52),
        center + Vector2(-w*0.30,h*0.40),
        center + Vector2(-w*0.52,h*0.16)
    ])

func _draw_room_features_in_zone(id: String, accent: Color) -> void:
    if not ROOM_FEATURES.has(id):
        return
    var info: Dictionary = ZONES[id]
    var base: Vector2 = _map_to_screen(info["pos"] + info["size"] * Vector2(0.82,0.14))
    var features: Array = ROOM_FEATURES[id]
    for i in range(features.size()):
        _draw_feature_icon(base+Vector2(float(i%4)*18.0,float(i/4)*18.0),str(features[i]),1.0)

func _draw_world_markers(id: String, accent: Color, mini: bool = false) -> void:
    if not WORLD_MARKERS.has(id):
        return
    if not visited.has(id) and id != _current_zone_id():
        return

    var info: Dictionary = ZONES[id]
    var marker_info: Dictionary = WORLD_MARKERS[id]
    var center: Vector2 = _zone_center(id)
    var scale: float = 0.72 if mini else 1.0
    var base: Vector2 = center + Vector2(0, float(info["size"].y) * zoom * 0.08)
    var gap: float = 26.0 * scale
    var markers: Array[String] = []

    # Fragmento: solo se muestra como disponible si ya existe en el progreso.
    # Para las futuras zonas se muestra tenue cuando la zona fue descubierta.
    var fragment_id: String = str(marker_info.get("fragment", ""))
    if not fragment_id.is_empty():
        var obtenido: bool = GameState.tiene_fragmento_corazon(fragment_id)
        if obtenido or id == "bosque_entrada":
            markers.append("fragment_obtained" if obtenido else "fragment")

    if bool(marker_info.get("luma", false)):
        markers.append("luma")

    var guardian_id: String = str(marker_info.get("guardian", ""))
    if not guardian_id.is_empty():
        var derrotado: bool = GameState.jefe_derrotado(guardian_id)
        markers.append("guardian_defeated" if derrotado else "guardian")

    if bool(marker_info.get("secret", false)):
        markers.append("secret")

    var start_x: float = base.x - float(markers.size() - 1) * gap * 0.5
    for i in range(markers.size()):
        var point := Vector2(start_x + float(i) * gap, base.y)
        _draw_world_marker_icon(point, markers[i], scale)

func _draw_world_marker_icon(p: Vector2, marker: String, scale: float) -> void:
    var r: float = 9.0 * scale
    var pulse: float = 1.0 + 0.10 * sin(pulse_time * 3.0)
    match marker:
        "fragment":
            draw_circle(p, r * 1.7 * pulse, Color(0.30, 0.78, 1.0, 0.10))
            var heart := PackedVector2Array([p+Vector2(0,-r),p+Vector2(r*0.82,-r*0.15),p+Vector2(r*0.55,r*0.90),p,p-Vector2(r*0.55,-r*0.15)])
            draw_colored_polygon(heart, Color(0.45,0.92,1.0,0.96))
            draw_polyline(PackedVector2Array([heart[0],heart[1],heart[2],heart[3],heart[4],heart[0]]), Color(0.90,1.0,1.0,0.95), 1.2 * scale)
        "fragment_obtained":
            draw_circle(p, r, Color(0.40,0.92,1.0,0.18))
            draw_circle(p, r*0.55, Color(0.55,0.95,1.0,0.95))
            draw_line(p-Vector2(r*0.45,0),p+Vector2(r*0.45,0),Color(0.92,1.0,1.0,0.9),1.2*scale)
        "luma":
            draw_circle(p, r*1.35, Color(0.78,0.58,1.0,0.12))
            draw_circle(p, r, Color(0.80,0.64,1.0,0.95))
            draw_circle(p+Vector2(0,-r*0.25), r*0.43, Color(0.97,0.92,1.0,0.96))
            draw_line(p+Vector2(-r*0.65,r*0.55),p+Vector2(0,r*0.05),Color(0.92,0.80,1.0,0.9),1.5*scale)
            draw_line(p+Vector2(0,r*0.05),p+Vector2(r*0.65,r*0.55),Color(0.92,0.80,1.0,0.9),1.5*scale)
        "guardian":
            draw_circle(p, r*1.35, Color(0.96,0.18,0.20,0.10))
            draw_colored_polygon(PackedVector2Array([p+Vector2(0,-r),p+Vector2(r*0.78,-r*0.25),p+Vector2(r*0.58,r*0.78),p,p-Vector2(r*0.58,-r*0.25)]), Color(0.88,0.18,0.18,0.98))
            draw_circle(p, r*0.25, Color(0.98,0.80,0.42,0.98))
        "guardian_defeated":
            draw_circle(p, r, Color(0.50,0.58,0.62,0.45), false, 1.8*scale)
            draw_line(p-Vector2(r*0.45,r*0.45),p+Vector2(r*0.45,r*0.45),Color(0.75,0.84,0.86,0.85),1.5*scale)
            draw_line(p+Vector2(r*0.45,-r*0.45),p-Vector2(r*0.45,r*0.45),Color(0.75,0.84,0.86,0.85),1.5*scale)
        "secret":
            draw_rect(Rect2(p-Vector2(r*0.8,r*0.65),Vector2(r*1.6,r*1.3)),Color(0.96,0.68,0.26,0.95),true)
            draw_line(p-Vector2(r*0.8,0),p+Vector2(r*0.8,0),Color(0.28,0.17,0.06,0.95),1.2*scale)
            draw_circle(p+Vector2(0,r*0.02),r*0.16,Color(0.25,0.14,0.04,1.0))

func _zone_number(id: String) -> int:
    if ZONES.has(id):
        return int(ZONES[id]["number"])
    return 0

func _draw_zone_index(font: Font) -> void:
    var panel: Rect2 = Rect2(30,154,300,430)
    draw_style_box(_crear_box(Color(0.004,0.007,0.014,0.90),Color(0.30,0.42,0.60,0.42),1.0),panel)
    draw_string(font, panel.position + Vector2(18,26), "ZONAS DEL MUNDO", HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Color(0.82,0.88,0.96))
    var current_zone: String = _current_zone_id()
    var y: float = 58.0
    for id in ZONES.keys():
        var info: Dictionary = ZONES[id]
        var discovered: bool = visited.has(id)
        var active: bool = id == current_zone
        var accent: Color = info["color"]
        if active:
            draw_style_box(_crear_box(Color(accent.r,accent.g,accent.b,0.13),Color(accent.r,accent.g,accent.b,0.70),1.0),Rect2(panel.position + Vector2(9,y-15),Vector2(panel.size.x-18,28)))
        draw_circle(panel.position + Vector2(24,y-2),8.0,Color(accent.r,accent.g,accent.b,0.95 if discovered or active else 0.22))
        draw_string(font,panel.position+Vector2(20,y+2),str(info["number"]),HORIZONTAL_ALIGNMENT_CENTER,8,9,Color(0.02,0.03,0.06,1.0))
        var text_color: Color = Color(0.90,0.92,0.96) if discovered or active else Color(0.40,0.44,0.50)
        draw_string(font,panel.position+Vector2(42,y+2),str(info["name"]) if discovered or active else "Zona no descubierta",HORIZONTAL_ALIGNMENT_LEFT,230,11,text_color)
        y += 31.0

func _draw_progress(font: Font) -> void:
    var total_rooms: int = _total_cartography_rooms()
    var progress: float = float(mini(visited_rooms.size(), total_rooms))/float(maxi(total_rooms,1))
    var card: Rect2 = Rect2(size.x-350,24,305,74)
    draw_style_box(_crear_box(Color(0.004,0.006,0.010,0.94),Color(0.57,0.49,0.32,0.52),1.0),card)
    draw_string(font,card.position+Vector2(16,22),"EXPLORACIÓN  %d%%" % int(progress*100.0),HORIZONTAL_ALIGNMENT_LEFT,-1,16,Color(0.88,0.85,0.75))
    draw_rect(Rect2(card.position+Vector2(16,35),Vector2(270,6)),Color(0.05,0.07,0.08),true)
    draw_rect(Rect2(card.position+Vector2(16,35),Vector2(270*progress,6)),Color(0.42,0.75,0.48),true)
    draw_string(font,card.position+Vector2(16,58),"%d / %d habitaciones descubiertas" % [mini(visited_rooms.size(), total_rooms), total_rooms],HORIZONTAL_ALIGNMENT_LEFT,-1,10,Color(0.52,0.59,0.59))
    var fragmentos: int = GameState.cantidad_fragmentos_corazon()
    var guardianes: int = GameState.jefes_derrotados.size()
    draw_string(font,card.position+Vector2(168,22),"♥ %d/12" % fragmentos,HORIZONTAL_ALIGNMENT_LEFT,-1,10,Color(0.50,0.88,1.0,0.95))
    draw_string(font,card.position+Vector2(168,58),"◆ %d/12" % guardianes,HORIZONTAL_ALIGNMENT_LEFT,-1,10,Color(0.96,0.42,0.36,0.95))

func _draw_current_card(font: Font) -> void:
    var card: Rect2 = Rect2(size.x-330,100,245,72)
    draw_style_box(_crear_box(Color(0.004,0.006,0.010,0.94),Color(0.50,0.46,0.34,0.48),1.0),card)
    var current_zone: String = _current_zone_id()
    var nombre: String = str(ZONES[current_zone]["name"]) if ZONES.has(current_zone) else "SIN ZONA"
    draw_string(font,card.position+Vector2(14,21),"UBICACIÓN ACTUAL",HORIZONTAL_ALIGNMENT_LEFT,-1,10,Color(0.57,0.61,0.60))
    draw_string(font,card.position+Vector2(14,46),nombre,HORIZONTAL_ALIGNMENT_LEFT,card.size.x-34,15,Color(0.91,0.88,0.79))
    draw_circle(card.position+Vector2(card.size.x-18,34),5,Color(0.58,0.92,0.62,0.94))
    _draw_current_zone_room_summary(font)

func _draw_current_zone_room_summary(font: Font) -> void:
    var zone_id: String = _current_zone_id()
    if zone_id.is_empty() or not ZONES.has(zone_id):
        return
    var panel: Rect2 = Rect2(size.x-330,182,245,154)
    var accent: Color = ZONES[zone_id]["color"]
    draw_style_box(_crear_box(Color(0.004,0.006,0.010,0.94),Color(accent.r,accent.g,accent.b,0.34),1.0),panel)
    draw_string(font,panel.position+Vector2(14,22),"MAPA DE LA ZONA",HORIZONTAL_ALIGNMENT_LEFT,-1,10,Color(0.57,0.61,0.60))
    var total: int = 0
    var room_total: int = _room_count_for_zone(zone_id)
    for i in range(room_total):
        if visited_rooms.has(_room_id_for_zone(zone_id, i)) or (i == 0 and visited.has(zone_id)):
            total += 1
    draw_string(font,panel.position+Vector2(14,44),"%d / %d salas conocidas" % [total, room_total],HORIZONTAL_ALIGNMENT_LEFT,-1,13,Color(0.90,0.92,0.94))
    draw_rect(Rect2(panel.position+Vector2(14,51),Vector2(215,5)),Color(0.05,0.07,0.08,1.0),true)
    draw_rect(Rect2(panel.position+Vector2(14,51),Vector2(215.0*float(total)/float(maxi(room_total,1)),5)),Color(accent.r,accent.g,accent.b,0.78),true)
    var labels: Array[String] = _room_labels_for_zone(zone_id)
    for i in range(room_total):
        var known: bool = visited_rooms.has(_room_id_for_zone(zone_id, i)) or (i == 0 and visited.has(zone_id))
        var yy: float = 66.0 + float(i) * 16.0
        draw_circle(panel.position+Vector2(18,yy-3),3.0,Color(accent.r,accent.g,accent.b,0.92 if known else 0.16))
        draw_string(font,panel.position+Vector2(28,yy),labels[i],HORIZONTAL_ALIGNMENT_LEFT,-1,9,Color(0.78,0.82,0.86) if known else Color(0.34,0.38,0.42))

func _draw_legend(font: Font) -> void:
    var legend: Rect2 = Rect2(30,560,300,365)
    draw_style_box(_crear_box(Color(0.004,0.007,0.014,0.90),Color(0.30,0.42,0.60,0.42),1.0),legend)
    draw_string(font,legend.position+Vector2(18,26),"LEYENDA DEL MAPA",HORIZONTAL_ALIGNMENT_LEFT,-1,18,Color(0.82,0.88,0.96))
    var rows: Array = [
        ["Conexión principal","solid"],
        ["Camino secundario","dashed"],
        ["Conexión vertical","vertical"],
        ["Puerta / portal","door"],
        ["Atajo","shortcut"],
        ["Área inaccesible","locked"],
        ["Fragmento del Corazón","fragment"],
        ["Luma (NPC)","luma"],
        ["Guardián","guardian"],
        ["Secreto / cofre","secret"],
        ["Habitación / zona","room"]
    ]
    var y: float = 54.0
    for row in rows:
        var kind: String = str(row[1])
        var yy: float = legend.position.y + y
        if kind == "solid":
            draw_line(Vector2(legend.position.x+18,yy),Vector2(legend.position.x+58,yy),Color(0.90,0.92,0.94,0.95),2.0)
        elif kind == "dashed":
            draw_dashed_line(Vector2(legend.position.x+18,yy),Vector2(legend.position.x+58,yy),Color(0.70,0.78,0.88,0.95),1.5,7.0)
        elif kind == "vertical":
            draw_line(Vector2(legend.position.x+38,yy-9),Vector2(legend.position.x+38,yy+9),Color(0.62,0.86,0.98,0.95),1.5)
            draw_line(Vector2(legend.position.x+33,yy-5),Vector2(legend.position.x+38,yy-10),Color(0.62,0.86,0.98,0.95),1.5)
            draw_line(Vector2(legend.position.x+43,yy-5),Vector2(legend.position.x+38,yy-10),Color(0.62,0.86,0.98,0.95),1.5)
            draw_line(Vector2(legend.position.x+33,yy+5),Vector2(legend.position.x+38,yy+10),Color(0.62,0.86,0.98,0.95),1.5)
            draw_line(Vector2(legend.position.x+43,yy+5),Vector2(legend.position.x+38,yy+10),Color(0.62,0.86,0.98,0.95),1.5)
        elif kind == "door":
            draw_rect(Rect2(legend.position+Vector2(25,y-8),Vector2(18,16)),Color(0.86,0.78,0.52,0.95),false,1.5)
        elif kind == "shortcut":
            draw_dashed_line(legend.position+Vector2(18,y),legend.position+Vector2(58,y),Color(0.40,0.88,0.82,0.95),1.0,4.0)
        elif kind == "locked":
            draw_rect(Rect2(legend.position+Vector2(22,y-7),Vector2(32,14)),Color(0.72,0.76,0.82,0.55),false,1.0)
        elif kind == "fragment":
            _draw_world_marker_icon(legend.position+Vector2(38,y), "fragment", 0.72)
        elif kind == "luma":
            _draw_world_marker_icon(legend.position+Vector2(38,y), "luma", 0.72)
        elif kind == "guardian":
            _draw_world_marker_icon(legend.position+Vector2(38,y), "guardian", 0.72)
        elif kind == "secret":
            _draw_world_marker_icon(legend.position+Vector2(38,y), "secret", 0.72)
        else:
            draw_rect(Rect2(legend.position+Vector2(22,y-7),Vector2(32,14)),Color(0.60,0.70,0.80,0.65),false,1.0)
        draw_string(font,legend.position+Vector2(70,y+4),str(row[0]),HORIZONTAL_ALIGNMENT_LEFT,-1,11,Color(0.70,0.76,0.84))
        y += 28.0

func _draw_controls(font: Font) -> void:
    var bottom: Rect2 = Rect2(30,size.y-64,size.x-60,40)
    draw_style_box(_crear_box(Color(0.004,0.006,0.010,0.94),Color(0.45,0.40,0.30,0.42),1.0),bottom)
    draw_string(font,Vector2(48,size.y-38),"M  CERRAR   ·   RUEDA  ZOOM   ·   C  CENTRAR   ·   0  RESTABLECER   ·   CLIC  CENTRAR ZONA   ·   BOTÓN CENTRAL  MOVER",HORIZONTAL_ALIGNMENT_LEFT,-1,11,Color(0.62,0.66,0.65))

func _draw_compass(font: Font, mini: bool) -> void:
    var center: Vector2 = Vector2(size.x-62,size.y-74) if not mini else Vector2(size.x-26,61)
    var r: float = 28.0 if not mini else 9.0
    draw_circle(center,r,Color(0.002,0.004,0.008,0.86))
    draw_circle(center,r,Color(0.67,0.58,0.40,0.48),false,1.0)
    draw_colored_polygon(PackedVector2Array([center+Vector2(0,-r*0.72),center+Vector2(r*0.16,r*0.30),center,center+Vector2(-r*0.16,r*0.30)]),Color(0.90,0.86,0.72,0.84))
    draw_colored_polygon(PackedVector2Array([center+Vector2(0,r*0.72),center+Vector2(r*0.16,-r*0.30),center,center+Vector2(-r*0.16,-r*0.30)]),Color(0.34,0.38,0.38,0.88))
    draw_string(font,center+Vector2(-4,-r-5),"N",HORIZONTAL_ALIGNMENT_LEFT,-1,9 if mini else 11,Color(0.86,0.78,0.58,0.90))

func _room_count_for_zone(id: String) -> int:
    if not ZONES.has(id):
        return 0
    var rooms: Array = ZONES[id].get("rooms", [])
    return maxi(rooms.size(), 1)

func _room_labels_for_zone(id: String) -> Array[String]:
    if not ZONES.has(id):
        return ["Entrada"]
    var labels: Array[String] = []
    for value in ZONES[id].get("rooms", []):
        labels.append(str(value))
    return labels

func _total_cartography_rooms() -> int:
    var total: int = 0
    for id in ZONES.keys():
        total += _room_count_for_zone(str(id))
    return total

const FOREST_ROOM_IDS: Array[String] = [
    "bosque_entrada",
    "bosque_sendero",
    "bosque_entrada_pasaje",
    "bosque_entrada_secreta",
    "bosque_entrada_desafio",
    "bosque_entrada_recompensa",
    "bosque_entrada_claro_luma",
    "bosque_entrada_ruinas",
    "bosque_entrada_arboleda",
    "bosque_entrada_cascada",
    "bosque_entrada_raices_antiguas",
    "bosque_entrada_cueva_musgo",
    "bosque_entrada_mirador",
    "bosque_entrada_pasaje_corazon",
    "bosque_entrada_antesala",
    "bosque_entrada_secreto_raiz",
    "jefe_guardian"
]

func _room_id_for_zone(id: String, index: int) -> String:
    if id == "bosque_entrada" and index >= 0 and index < FOREST_ROOM_IDS.size():
        return FOREST_ROOM_IDS[index]
    var base: String = id
    if index <= 0:
        return base
    var info: Dictionary = ZONES.get(base, {})
    var labels: Array = info.get("rooms", [])
    if index < labels.size():
        var label_id: String = str(labels[index]).to_lower()
        label_id = label_id.replace("á","a").replace("é","e").replace("í","i").replace("ó","o").replace("ú","u").replace("ñ","n").replace(" ","_")
        label_id = label_id.replace("/", "_")
        return base + "_" + label_id
    return base + "_sala_%02d" % index

func _room_type_for_index(index: int) -> String:
    var names: Array[String] = ["Principal", "Pasaje", "Secreta", "Desafío", "Recompensa"]
    return names[clampi(index, 0, names.size() - 1)]

func _draw_blocked_routes(mini: bool) -> void:
    if blocked_doors.is_empty():
        return
    var font: Font = ThemeDB.fallback_font
    var y: float = 150.0 if not mini else 46.0
    var shown: int = 0
    for key in blocked_doors.keys():
        if shown >= (3 if mini else 8):
            break
        var habilidad: String = str(blocked_doors[key])
        var parts: PackedStringArray = str(key).split("->")
        var label: String = ""
        if parts.size() >= 2:
            label = parts[0] + " → " + parts[1]
        else:
            label = str(key)
        var text: String = "🔒 " + habilidad
        if not mini:
            draw_string(font,Vector2(48,y),text,HORIZONTAL_ALIGNMENT_LEFT,-1,10,Color(0.82,0.68,0.42,0.88))
            draw_string(font,Vector2(48,y+13),label,HORIZONTAL_ALIGNMENT_LEFT,250,8,Color(0.48,0.52,0.51,0.72))
            y += 31.0
        else:
            draw_circle(Vector2(size.x-16,y-3),4.0,Color(0.88,0.66,0.32,0.9))
            y += 12.0
        shown += 1

func _draw_feature_icon(p: Vector2, feature: String, z: float) -> void:
    var r: float = 5.5*z
    match feature:
        "spawn":
            draw_circle(p,r,Color(0.82,0.84,0.78,0.96))
            draw_circle(p,r*0.42,Color(0.06,0.08,0.08,1.0))
        "enemy": draw_circle(p,r,Color(0.86,0.24,0.20,0.96))
        "coins": draw_circle(p,r,Color(0.96,0.76,0.22,0.96))
        "crystal": draw_colored_polygon(PackedVector2Array([p+Vector2(0,-r),p+Vector2(r*0.7,0),p+Vector2(0,r),p-Vector2(r*0.7,0)]),Color(0.72,0.32,0.96,0.96))
        "double_jump":
            draw_circle(p,r,Color(0.28,0.76,1.0,0.96))
            draw_string(ThemeDB.fallback_font,p+Vector2(-3,3),"2",HORIZONTAL_ALIGNMENT_LEFT,-1,8,Color.WHITE)
        "mantis_claw":
            draw_circle(p,r,Color(0.44,0.94,0.62,0.96))
            draw_line(p-Vector2(r*0.55,r*0.8),p+Vector2(r*0.15,r*0.2),Color.WHITE,1.3)
            draw_line(p-Vector2(r*0.05,r*0.2),p+Vector2(r*0.65,r*0.8),Color.WHITE,1.3)
        "crystal_heart":
            draw_circle(p,r,Color(0.30,0.88,1.0,0.96))
            draw_colored_polygon(PackedVector2Array([p+Vector2(-r*0.8,-r*0.2),p+Vector2(-r*0.2,-r*0.8),p,p+Vector2(r*0.8,-r*0.2),p+Vector2(0,r*0.9)]),Color(0.76,1.0,1.0,0.96))
        "isma_tear":
            draw_colored_polygon(PackedVector2Array([p+Vector2(0,-r),p+Vector2(r*0.55,0),p+Vector2(0,r),p-Vector2(r*0.55,0)]),Color(0.45,0.82,1.0,0.96))
        "shade_cloak":
            draw_circle(p,r,Color(0.42,0.20,0.62,0.98))
            draw_circle(p,r*0.46,Color(0.08,0.04,0.13,1.0))
        "shop":
            draw_rect(Rect2(p-Vector2(r,r*0.72),Vector2(2*r,1.45*r)),Color(0.94,0.70,0.28,0.96),true)
        "checkpoint":
            draw_line(p+Vector2(-r,-2),p+Vector2(r,-2),Color(0.80,0.38,0.92,0.96),1.5)
            draw_line(p+Vector2(-r*0.7,-5),p+Vector2(-r*0.7,4),Color(0.80,0.38,0.92,0.96),1.5)
            draw_line(p+Vector2(r*0.7,-5),p+Vector2(r*0.7,4),Color(0.80,0.38,0.92,0.96),1.5)
        "chest":
            draw_rect(Rect2(p-Vector2(r,r*0.65),Vector2(2*r,1.3*r)),Color(0.92,0.62,0.22,0.96),true)
            draw_line(p-Vector2(r,0),p+Vector2(r,0),Color(0.28,0.16,0.05),1.2)
        "potion": draw_circle(p,r*0.8,Color(0.90,0.30,0.28,0.96))
        "life_fragment": draw_colored_polygon(PackedVector2Array([p+Vector2(0,-r),p+Vector2(r*0.7,0),p,p+Vector2(-r*0.7,0)]),Color(0.98,0.26,0.36,0.96))
        "boss":
            draw_circle(p,r,Color(0.84,0.18,0.12,0.98),false,1.8)
            draw_circle(p,r*0.38,Color(0.92,0.72,0.42,0.98))
        "goal": draw_circle(p,r,Color(0.96,0.88,0.48,0.98))

func _crear_box(fill: Color, border: Color, width: float) -> StyleBoxFlat:
    var box: StyleBoxFlat = StyleBoxFlat.new()
    box.bg_color = fill
    box.border_color = border
    box.set_border_width_all(int(width))
    box.corner_radius_top_left = 7
    box.corner_radius_top_right = 7
    box.corner_radius_bottom_left = 7
    box.corner_radius_bottom_right = 7
    return box
