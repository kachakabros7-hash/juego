extends Area2D

## HEART OF THE WORLD — Guardiana Luma
## Primera NPC principal. Entrega la misión "Ecos del Bosque".

@export var nombre_npc: String = "Luma"
@export var distancia_interaccion: float = 150.0

var jugador: Node2D = null
var puede_hablar: bool = false
var dialogo_abierto: bool = false
var mostrar_eleccion_pendiente: bool = false
var panel_eleccion: CanvasLayer = null

@onready var prompt: Label = $Prompt

const DIALOGO_INICIAL: Array[String] = [
	"Ah... has despertado. Por un instante creí que el bosque había olvidado cómo hacerlo.",
	"Me llamo Luma. No temas a las raíces: antes sostenían nuestros hogares y guardaban nuestros recuerdos.",
	"Ahora el Corazón del Mundo late cada vez más despacio. Cuando su pulso se apaga, hasta los nombres desaparecen.",
	"No sé si eres quien puede salvarlo, Misha. Y no voy a pedirte que me creas solo porque lo digo.",
	"Escucha a las criaturas que encuentres. Algunas atacan por miedo; otras ya no recuerdan otra forma de vivir.",
	"Empieza por las tres criaturas que rondan las raíces. Si puedes, observa por qué están aquí. Después, vuelve y hablaremos."
]

const DIALOGO_ACTIVA: Array[String] = [
	"Las raíces siguen temblando. ¿Has encontrado a las criaturas?",
	"No confundas sobrevivir con ser cruel, Misha. Pero tampoco olvides protegerte.",
	"Cuando hayas terminado, regresa. Quiero saber qué viste, no solo qué derrotaste."
]

const DIALOGO_COMPLETA: Array[String] = [
	"El bosque ha recuperado un poco de su voz. Lo escucho en las hojas... hacía mucho que no sonaban así.",
	"No sé qué ocurrió ahí fuera. Solo tú lo sabes. Ojalá recuerdes también lo que sentiste.",
	"Toma esta poción. No puede reparar un corazón, pero puede ayudarte a seguir adelante."
]

const DIALOGO_FINAL: Array[String] = [
	"Las raíces profundas conducen a lugares que el mapa no sabe nombrar.",
	"Si encuentras recuerdos, no los fuerces. A veces una verdad duele antes de tener sentido.",
	"Y si alguien te pregunta quién eres... quizá puedas responder con lo que decidas hacer."
]

func _ready() -> void:
	var zona := get_node_or_null("Area2D") as Area2D
	if zona != null:
		zona.body_entered.connect(_on_body_entered)
		zona.body_exited.connect(_on_body_exited)
	if is_instance_valid(prompt):
		prompt.visible = false
		prompt.text = "E - HABLAR"

func _process(_delta: float) -> void:
	if jugador != null and is_instance_valid(jugador):
		puede_hablar = global_position.distance_to(jugador.global_position) <= distancia_interaccion
		if is_instance_valid(prompt):
			prompt.visible = puede_hablar and not dialogo_abierto
	else:
		puede_hablar = false
		if is_instance_valid(prompt):
			prompt.visible = false

func _unhandled_input(event: InputEvent) -> void:
	if dialogo_abierto or not puede_hablar:
		return
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_E:
		abrir_dialogo()
		get_viewport().set_input_as_handled()

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		jugador = body

func _on_body_exited(body: Node2D) -> void:
	if body == jugador:
		jugador = null

func abrir_dialogo() -> void:
	if dialogo_abierto:
		return
	if not has_node("/root/MissionManager"):
		return

	dialogo_abierto = true
	if is_instance_valid(prompt):
		prompt.visible = false

	var dialogo_scene := preload("res://scenes/DialogueUI.tscn")
	var dialogo = dialogo_scene.instantiate()
	get_tree().root.add_child(dialogo)

	var lineas: Array[String]
	var callback := Callable()

	if MissionManager.estado_actual == MissionManager.NO_INICIADA:
		lineas = DIALOGO_INICIAL
		callback = Callable(self, "_iniciar_mision")
	elif MissionManager.estado_actual == MissionManager.ACTIVA:
		lineas = DIALOGO_ACTIVA.duplicate()
		if GameState.decision_luma == "escuchar":
			lineas.append("Elegiste escuchar antes de juzgar. Recuerda esa paciencia cuando las raíces te muestren su pasado.")
		elif GameState.decision_luma == "proteger":
			lineas.append("Elegiste proteger el bosque. A veces hay que detener el peligro; procura no olvidar qué lo provocó.")
	elif MissionManager.estado_actual == MissionManager.COMPLETADA and MissionManager.recompensa_pendiente:
		lineas = DIALOGO_COMPLETA
		callback = Callable(self, "_entregar_recompensa")
	else:
		lineas = DIALOGO_FINAL

	if dialogo.has_method("iniciar"):
		dialogo.iniciar(nombre_npc, lineas, callback, Callable(self, "_dialogo_terminado"))

func _iniciar_mision() -> void:
	if MissionManager.iniciar_mision("ecos_del_bosque"):
		mostrar_eleccion_pendiente = true
		_mostrar_aviso("MISIÓN ACEPTADA: ECOS DEL BOSQUE")

func _entregar_recompensa() -> void:
	if MissionManager.entregar_recompensa():
		_mostrar_aviso("RECOMPENSA: +1 POCIÓN")

func _dialogo_terminado() -> void:
	dialogo_abierto = false
	if is_instance_valid(prompt):
		prompt.visible = puede_hablar
	if mostrar_eleccion_pendiente:
		mostrar_eleccion_pendiente = false
		call_deferred("_mostrar_eleccion")

func _mostrar_aviso(texto: String) -> void:
	var player = get_tree().get_first_node_in_group("player")
	if player != null:
		var sistemas = player.get_node_or_null("GameplaySystems")
		if sistemas != null and sistemas.has_method("mostrar_mensaje"):
			sistemas.mostrar_mensaje(texto)


func _mostrar_eleccion() -> void:
	if not is_inside_tree() or is_instance_valid(panel_eleccion):
		return
	panel_eleccion = CanvasLayer.new()
	panel_eleccion.name = "DecisionLuma"
	panel_eleccion.process_mode = Node.PROCESS_MODE_ALWAYS
	panel_eleccion.layer = 30
	get_tree().root.add_child(panel_eleccion)
	var fondo := ColorRect.new()
	fondo.color = Color(0.015, 0.025, 0.04, 0.78)
	fondo.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	panel_eleccion.add_child(fondo)
	var centro := CenterContainer.new()
	centro.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	fondo.add_child(centro)
	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(620, 260)
	centro.add_child(panel)
	var columna := VBoxContainer.new()
	columna.add_theme_constant_override("separation", 14)
	panel.add_child(columna)
	var titulo := Label.new()
	titulo.text = "¿QUÉ LE PROMETES A LUMA?"
	titulo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	titulo.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	columna.add_child(titulo)
	var detalle := Label.new()
	detalle.text = "Tu respuesta cambiará cómo Luma interpreta tus acciones."
	detalle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	detalle.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	columna.add_child(detalle)
	var escuchar := Button.new()
	escuchar.text = "Escuchar a las criaturas antes de juzgarlas"
	escuchar.custom_minimum_size.y = 48
	escuchar.pressed.connect(_elegir_decision.bind("escuchar"))
	columna.add_child(escuchar)
	var proteger := Button.new()
	proteger.text = "Proteger el bosque aunque tenga que luchar"
	proteger.custom_minimum_size.y = 48
	proteger.pressed.connect(_elegir_decision.bind("proteger"))
	columna.add_child(proteger)
	get_tree().paused = true
	escuchar.grab_focus()

func _elegir_decision(decision: String) -> void:
	GameState.registrar_decision_luma(decision)
	if has_node("/root/SaveManager"):
		SaveManager.guardar_partida()
	if decision == "escuchar":
		_mostrar_aviso("PROMESA: ESCUCHAR ANTES DE JUZGAR")
	else:
		_mostrar_aviso("PROMESA: PROTEGER EL BOSQUE")
	get_tree().paused = false
	if is_instance_valid(panel_eleccion):
		panel_eleccion.queue_free()
	panel_eleccion = null
