extends Control

@onready var boton_continuar: Button = $MenuButtons/Continuar
@onready var boton_jugar: Button = $MenuButtons/Jugar
@onready var boton_controles: Button = $MenuButtons/Controles
@onready var boton_opciones: Button = $MenuButtons/Opciones
@onready var boton_salir: Button = $MenuButtons/Salir
@onready var panel_controles: Control = $ControlsPanel

var botones_menu: Array[Button] = []
var tweens_hover: Dictionary = {}
var particulas_ambiente: Array[Dictionary] = []
var tiempo_animacion: float = 0.0
var rng: RandomNumberGenerator = RandomNumberGenerator.new()

var audio_hover: AudioStreamPlayer
var audio_click: AudioStreamPlayer
var audio_open: AudioStreamPlayer
var audio_close: AudioStreamPlayer
var audio_start: AudioStreamPlayer

var popup_opciones: AcceptDialog
var slider_volumen: HSlider
var check_pantalla_completa: CheckButton

const ROJO: Color = Color(0.95, 0.08, 0.07, 1.0)
const ROJO_BRILLO: Color = Color(1.0, 0.34, 0.22, 1.0)
const BLANCO: Color = Color(1.0, 0.96, 0.92, 1.0)
const VOLUMEN_BUS: StringName = &"Master"

func _ready() -> void:
    preparar_fondo()
    panel_controles.visible = false
    inicializar_particulas()
    configurar_audio()
    configurar_controles()
    configurar_menu_visual()
    configurar_navegacion()
    configurar_opciones()
    iniciar_animacion_menu()

    boton_continuar.disabled = SaveManager == null or not SaveManager.existe_guardado()
    if boton_continuar.disabled:
        boton_jugar.grab_focus()
    else:
        boton_continuar.grab_focus()

func preparar_fondo() -> void:
    var fondo = get_node_or_null("Background")
    var textura = get_node_or_null("TextureRect")
    var titulo = get_node_or_null("Title")

    if fondo is Control:
        fondo.mouse_filter = Control.MOUSE_FILTER_IGNORE
    if textura is Control:
        textura.mouse_filter = Control.MOUSE_FILTER_IGNORE
    if titulo is Control:
        titulo.mouse_filter = Control.MOUSE_FILTER_IGNORE

func _input(event: InputEvent) -> void:
    if not event is InputEventKey:
        return

    var tecla: InputEventKey = event
    if not tecla.pressed or tecla.echo:
        return

    if panel_controles.visible:
        if tecla.keycode == KEY_ESCAPE or tecla.physical_keycode == KEY_ESCAPE:
            cerrar_controles()
            get_viewport().set_input_as_handled()
        elif tecla.keycode == KEY_ENTER or tecla.keycode == KEY_KP_ENTER or tecla.keycode == KEY_SPACE:
            var foco_controles = get_viewport().gui_get_focus_owner()
            if foco_controles is Button and foco_controles == $ControlsPanel/Close:
                cerrar_controles()
                get_viewport().set_input_as_handled()
        return

    if tecla.keycode == KEY_UP or tecla.keycode == KEY_W or tecla.physical_keycode == KEY_UP or tecla.physical_keycode == KEY_W:
        mover_foco(-1)
        get_viewport().set_input_as_handled()
        return

    if tecla.keycode == KEY_DOWN or tecla.keycode == KEY_S or tecla.physical_keycode == KEY_DOWN or tecla.physical_keycode == KEY_S:
        mover_foco(1)
        get_viewport().set_input_as_handled()
        return

    if tecla.keycode == KEY_ENTER or tecla.keycode == KEY_KP_ENTER or tecla.keycode == KEY_SPACE:
        var foco = get_viewport().gui_get_focus_owner()
        if foco is Button and foco in botones_menu and not foco.disabled:
            foco.emit_signal("pressed")
            get_viewport().set_input_as_handled()
        return

    if tecla.keycode == KEY_ESCAPE or tecla.physical_keycode == KEY_ESCAPE:
        get_tree().quit()
        get_viewport().set_input_as_handled()

func configurar_navegacion() -> void:
    botones_menu = [boton_continuar, boton_jugar, boton_opciones, boton_controles, boton_salir]

    for i in range(botones_menu.size()):
        var boton: Button = botones_menu[i]
        boton.focus_mode = Control.FOCUS_ALL
        boton.focus_neighbor_top = botones_menu[(i - 1 + botones_menu.size()) % botones_menu.size()].get_path()
        boton.focus_neighbor_bottom = botones_menu[(i + 1) % botones_menu.size()].get_path()
        boton.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND

func mover_foco(direccion: int) -> void:
    if botones_menu.is_empty():
        return

    var actual = get_viewport().gui_get_focus_owner()
    var indice: int = botones_menu.find(actual)

    if indice < 0:
        if boton_continuar.disabled:
            boton_jugar.grab_focus()
        else:
            boton_continuar.grab_focus()
        return

    var siguiente: int = indice
    for _i in range(botones_menu.size()):
        siguiente += direccion
        if siguiente < 0:
            siguiente = botones_menu.size() - 1
        elif siguiente >= botones_menu.size():
            siguiente = 0

        if not botones_menu[siguiente].disabled:
            botones_menu[siguiente].grab_focus()
            return

func _process(delta: float) -> void:
    tiempo_animacion += delta
    actualizar_fondo()
    actualizar_particulas(delta)
    queue_redraw()

func actualizar_fondo() -> void:
    var textura = get_node_or_null("TextureRect")
    if textura is CanvasItem:
        var intensidad: float = 0.975 + sin(tiempo_animacion * 1.35) * 0.02
        textura.modulate = Color(intensidad, intensidad, intensidad, 1.0)

func actualizar_particulas(delta: float) -> void:
    for particula in particulas_ambiente:
        var posicion: Vector2 = particula["pos"]
        var velocidad: Vector2 = particula["vel"]
        var oscilacion: float = particula["oscilacion"]
        var fase: float = particula["fase"]

        posicion += velocidad * delta
        posicion.y -= sin(tiempo_animacion * oscilacion + fase) * 0.12

        if posicion.y < -30.0:
            posicion.y = 1100.0 + rng.randf_range(0.0, 80.0)
            posicion.x = rng.randf_range(690.0, 1910.0)

        if posicion.x < 650.0 or posicion.x > 1940.0:
            posicion.x = rng.randf_range(690.0, 1910.0)

        particula["pos"] = posicion

func _draw() -> void:
    var pulso: float = 0.5 + 0.5 * sin(tiempo_animacion * 1.15)
    var aura_alpha: float = 0.035 + pulso * 0.025

    draw_circle(Vector2(1260.0, 180.0), 270.0, Color(1.0, 0.05, 0.02, aura_alpha))
    draw_circle(Vector2(1260.0, 180.0), 165.0, Color(1.0, 0.12, 0.05, aura_alpha * 1.35))

    for particula in particulas_ambiente:
        var posicion: Vector2 = particula["pos"]
        var radio: float = particula["radio"]
        var alpha: float = particula["alpha"] * (0.72 + pulso * 0.28)
        draw_circle(posicion, radio * 2.8, Color(1.0, 0.08, 0.02, alpha * 0.10))
        draw_circle(posicion, radio, Color(1.0, 0.30, 0.12, alpha))

func inicializar_particulas() -> void:
    rng.seed = 9142026
    particulas_ambiente.clear()

    for _i in range(32):
        particulas_ambiente.append({
            "pos": Vector2(rng.randf_range(690.0, 1910.0), rng.randf_range(0.0, 1080.0)),
            "vel": Vector2(rng.randf_range(-4.0, 4.0), rng.randf_range(-22.0, -7.0)),
            "radio": rng.randf_range(1.0, 2.8),
            "alpha": rng.randf_range(0.22, 0.72),
            "oscilacion": rng.randf_range(0.6, 1.8),
            "fase": rng.randf_range(0.0, TAU)
        })

func configurar_menu_visual() -> void:
    var textos: Array[String] = ["CONTINUAR", "JUGAR", "OPCIONES", "CONTROLES", "SALIR"]

    for i in range(botones_menu.size()):
        var boton: Button = botones_menu[i]
        boton.text = textos[i]
        boton.flat = false
        boton.custom_minimum_size = Vector2(540, 82)
        boton.pivot_offset = Vector2(270, 41)
        boton.add_theme_font_size_override("font_size", 42)
        boton.add_theme_color_override("font_color", BLANCO)
        boton.add_theme_color_override("font_hover_color", Color.WHITE)
        boton.add_theme_color_override("font_pressed_color", Color.WHITE)
        boton.add_theme_color_override("font_focus_color", BLANCO)
        boton.add_theme_color_override("font_outline_color", Color(0.12, 0.0, 0.0, 1.0))
        boton.add_theme_constant_override("outline_size", 7)
        boton.add_theme_stylebox_override("normal", crear_boton(false))
        boton.add_theme_stylebox_override("hover", crear_boton(true))
        boton.add_theme_stylebox_override("pressed", crear_boton(true))
        boton.add_theme_stylebox_override("focus", crear_boton(true))
        boton.add_theme_stylebox_override("disabled", crear_boton_desactivado())
        boton.mouse_entered.connect(al_entrar_boton.bind(boton))
        boton.mouse_exited.connect(al_salir_boton.bind(boton))
        boton.focus_entered.connect(al_enfocar_boton.bind(boton))
        boton.focus_exited.connect(al_desenfocar_boton.bind(boton))

func iniciar_animacion_menu() -> void:
    for i in range(botones_menu.size()):
        var boton: Button = botones_menu[i]
        boton.modulate = Color(1.0, 1.0, 1.0, 0.0)
        boton.scale = Vector2(0.94, 0.94)

        var tween: Tween = create_tween()
        tween.set_trans(Tween.TRANS_QUAD)
        tween.set_ease(Tween.EASE_OUT)
        tween.tween_interval(0.08 * i)
        tween.tween_property(boton, "modulate:a", 1.0, 0.28)
        tween.parallel().tween_property(boton, "scale", Vector2.ONE, 0.34)

func al_entrar_boton(boton: Button) -> void:
    animar_hover(boton, true)
    reproducir(audio_hover)

func al_salir_boton(boton: Button) -> void:
    animar_hover(boton, false)

func al_enfocar_boton(boton: Button) -> void:
    animar_hover(boton, true)
    reproducir(audio_hover)

func al_desenfocar_boton(boton: Button) -> void:
    if not boton.is_hovered():
        animar_hover(boton, false)

func animar_hover(boton: Button, activo: bool) -> void:
    if tweens_hover.has(boton):
        var anterior = tweens_hover[boton]
        if anterior is Tween and is_instance_valid(anterior):
            anterior.kill()

    var destino: Vector2 = Vector2(1.035, 1.035)
    if not activo:
        destino = Vector2.ONE

    var tween: Tween = create_tween()
    tweens_hover[boton] = tween
    tween.set_trans(Tween.TRANS_QUAD)
    tween.set_ease(Tween.EASE_OUT)
    tween.tween_property(boton, "scale", destino, 0.14)

func crear_boton(hover: bool) -> StyleBoxFlat:
    var caja: StyleBoxFlat = StyleBoxFlat.new()
    if hover:
        caja.bg_color = Color(0.22, 0.015, 0.018, 0.97)
        caja.border_color = ROJO_BRILLO
        caja.set_border_width_all(5)
        caja.shadow_color = Color(0.65, 0.0, 0.0, 0.55)
        caja.shadow_size = 18
    else:
        caja.bg_color = Color(0.07, 0.008, 0.012, 0.92)
        caja.border_color = ROJO
        caja.set_border_width_all(4)
        caja.shadow_color = Color(0.65, 0.0, 0.0, 0.35)
        caja.shadow_size = 12

    caja.corner_radius_top_left = 16
    caja.corner_radius_top_right = 16
    caja.corner_radius_bottom_left = 16
    caja.corner_radius_bottom_right = 16
    caja.shadow_offset = Vector2(0, 5)
    caja.content_margin_left = 24
    caja.content_margin_right = 24
    return caja

func crear_boton_desactivado() -> StyleBoxFlat:
    var caja: StyleBoxFlat = StyleBoxFlat.new()
    caja.bg_color = Color(0.035, 0.03, 0.03, 0.78)
    caja.border_color = Color(0.32, 0.16, 0.16, 0.75)
    caja.set_border_width_all(3)
    caja.corner_radius_top_left = 16
    caja.corner_radius_top_right = 16
    caja.corner_radius_bottom_left = 16
    caja.corner_radius_bottom_right = 16
    return caja

func configurar_audio() -> void:
    audio_hover = crear_reproductor("MenuHover", "res://assets/audio/menu/menu_hover.wav", -10.0)
    audio_click = crear_reproductor("MenuClick", "res://assets/audio/menu/menu_click.wav", -7.0)
    audio_open = crear_reproductor("MenuOpen", "res://assets/audio/menu/menu_open.wav", -8.0)
    audio_close = crear_reproductor("MenuClose", "res://assets/audio/menu/menu_close.wav", -8.0)
    audio_start = crear_reproductor("MenuStart", "res://assets/audio/menu/menu_start.wav", -8.0)

func crear_reproductor(nombre: String, ruta: String, volumen_db: float) -> AudioStreamPlayer:
    var player: AudioStreamPlayer = AudioStreamPlayer.new()
    player.name = nombre
    player.stream = load(ruta)
    player.volume_db = volumen_db
    add_child(player)
    return player

func reproducir(player: AudioStreamPlayer) -> void:
    if player != null and player.stream != null:
        player.stop()
        player.play()

func configurar_controles() -> void:
    var rows: VBoxContainer = $ControlsPanel/Rows
    var datos: Array = [
        ["Movimiento", "A / D", "Mover a izquierda y derecha"],
        ["Saltar", "ESPACIO", "Salto normal y doble salto"],
        ["Atacar", "J", "Ataque cuerpo a cuerpo"],
        ["Mapa", "M", "Abrir mapa mundial"],
        ["Pausa", "ESC", "Abrir pausa / menú"],
        ["Dash", "SHIFT", "Impulso rápido horizontal"],
        ["Garra Trepadora", "ESPACIO", "Rebote desde paredes"],
        ["Corazón de Cristal", "G", "Cargar y lanzar el impulso"],
        ["Capa Sombría", "C", "Cruzar brevemente en sombra"],
        ["Impulso de Raíz", "V", "Impulso vertical desde el suelo"],
        ["Parry", "L", "Bloqueo y contraataque"],
        ["Ataque a distancia", "K", "Proyectil a distancia"],
        ["Habilidad anterior", "Q", "Cambiar habilidad"],
        ["Habilidad siguiente", "E", "Cambiar habilidad"],
        ["Ataque especial", "R", "Usar ataque especial"]
    ]

    for child in rows.get_children():
        child.queue_free()

    for dato in datos:
        var fila: HBoxContainer = HBoxContainer.new()
        fila.custom_minimum_size = Vector2(0, 39)
        fila.add_theme_constant_override("separation", 10)
        rows.add_child(fila)

        var accion: Label = Label.new()
        accion.custom_minimum_size = Vector2(210, 0)
        accion.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
        accion.add_theme_font_size_override("font_size", 18)
        accion.text = str(dato[0])
        accion.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
        fila.add_child(accion)

        var tecla: Label = Label.new()
        tecla.custom_minimum_size = Vector2(140, 34)
        tecla.add_theme_font_size_override("font_size", 18)
        tecla.add_theme_color_override("font_color", Color(1, 0.92, 0.9, 1))
        tecla.add_theme_stylebox_override("normal", crear_caja_tecla())
        tecla.text = str(dato[1])
        tecla.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
        tecla.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
        fila.add_child(tecla)

        var desc: Label = Label.new()
        desc.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        desc.add_theme_font_size_override("font_size", 13)
        desc.add_theme_color_override("font_color", Color(0.95, 0.7, 0.7, 1))
        desc.text = str(dato[2])
        desc.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
        fila.add_child(desc)

func crear_caja_tecla() -> StyleBoxFlat:
    var caja: StyleBoxFlat = StyleBoxFlat.new()
    caja.bg_color = Color(0.08, 0.01, 0.015, 0.95)
    caja.border_color = Color(0.75, 0.12, 0.08, 0.95)
    caja.set_border_width_all(2)
    caja.corner_radius_top_left = 6
    caja.corner_radius_top_right = 6
    caja.corner_radius_bottom_left = 6
    caja.corner_radius_bottom_right = 6
    return caja

func configurar_opciones() -> void:
    popup_opciones = AcceptDialog.new()
    popup_opciones.title = "OPCIONES"
    popup_opciones.ok_button_text = "CERRAR"
    popup_opciones.min_size = Vector2(620, 330)
    popup_opciones.confirmed.connect(cerrar_opciones)
    add_child(popup_opciones)

    var contenedor: VBoxContainer = VBoxContainer.new()
    contenedor.add_theme_constant_override("separation", 18)
    popup_opciones.add_child(contenedor)

    var titulo: Label = Label.new()
    titulo.text = "CONFIGURACIÓN"
    titulo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    titulo.add_theme_font_size_override("font_size", 26)
    contenedor.add_child(titulo)

    var etiqueta: Label = Label.new()
    etiqueta.text = "Volumen general"
    etiqueta.add_theme_font_size_override("font_size", 18)
    contenedor.add_child(etiqueta)

    slider_volumen = HSlider.new()
    slider_volumen.min_value = -40.0
    slider_volumen.max_value = 0.0
    slider_volumen.step = 1.0
    slider_volumen.custom_minimum_size = Vector2(520, 34)
    slider_volumen.value = obtener_volumen()
    slider_volumen.value_changed.connect(_on_volumen_changed)
    contenedor.add_child(slider_volumen)

    check_pantalla_completa = CheckButton.new()
    check_pantalla_completa.text = "Pantalla completa"
    check_pantalla_completa.button_pressed = DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN
    check_pantalla_completa.toggled.connect(_on_pantalla_completa_toggled)
    contenedor.add_child(check_pantalla_completa)

    var ayuda: Label = Label.new()
    ayuda.text = "ESC cierra menús. W/S o flechas navegan. Enter o Espacio seleccionan."
    ayuda.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    ayuda.add_theme_color_override("font_color", Color(0.8, 0.65, 0.65, 1))
    contenedor.add_child(ayuda)

func obtener_volumen() -> float:
    var indice: int = AudioServer.get_bus_index(VOLUMEN_BUS)
    if indice < 0:
        return -8.0
    return AudioServer.get_bus_volume_db(indice)

func _on_volumen_changed(valor: float) -> void:
    var indice: int = AudioServer.get_bus_index(VOLUMEN_BUS)
    if indice >= 0:
        AudioServer.set_bus_volume_db(indice, valor)

func _on_pantalla_completa_toggled(activo: bool) -> void:
    if activo:
        DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
    else:
        DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)

func cerrar_opciones() -> void:
    if popup_opciones != null and popup_opciones.visible:
        popup_opciones.hide()
    boton_opciones.grab_focus()

func _on_jugar_pressed() -> void:
    reproducir(audio_start)
    if SaveManager != null:
        SaveManager.nueva_partida()
    get_tree().change_scene_to_file("res://scenes/rooms/bosque/bosque_entrada.tscn")

func _on_continuar_pressed() -> void:
    if SaveManager != null and SaveManager.cargar_partida():
        return

func _on_opciones_pressed() -> void:
    reproducir(audio_click)
    slider_volumen.value = obtener_volumen()
    check_pantalla_completa.button_pressed = DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN
    popup_opciones.popup_centered()

func _on_controles_pressed() -> void:
    reproducir(audio_open)
    panel_controles.visible = true
    panel_controles.modulate.a = 0.0
    panel_controles.scale = Vector2(0.97, 0.97)
    panel_controles.pivot_offset = Vector2(360, 485)

    var tween: Tween = create_tween()
    tween.set_trans(Tween.TRANS_QUAD)
    tween.set_ease(Tween.EASE_OUT)
    tween.parallel().tween_property(panel_controles, "modulate:a", 1.0, 0.22)
    tween.parallel().tween_property(panel_controles, "scale", Vector2.ONE, 0.25)
    $ControlsPanel/Close.grab_focus()

func cerrar_controles() -> void:
    if not panel_controles.visible:
        return

    reproducir(audio_close)
    var tween: Tween = create_tween()
    tween.set_trans(Tween.TRANS_QUAD)
    tween.set_ease(Tween.EASE_IN)
    tween.parallel().tween_property(panel_controles, "modulate:a", 0.0, 0.16)
    tween.parallel().tween_property(panel_controles, "scale", Vector2(0.97, 0.97), 0.16)
    tween.tween_callback(finalizar_cierre_controles)

func finalizar_cierre_controles() -> void:
    panel_controles.visible = false
    boton_controles.grab_focus()

func _on_salir_pressed() -> void:
    get_tree().quit()
