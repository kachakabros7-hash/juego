extends Node

## Audio Manager global — música, SFX y volúmenes.
## Coloca archivos en res://assets/audio/sfx/ cuando los tengas.
## Mientras tanto usa sonidos de menú como fallback suave.

signal volumen_cambiado(bus: String, valor_db: float)

const BUS_MASTER := "Master"
const BUS_MUSIC := "Music"
const BUS_SFX := "SFX"

var _sfx_players: Array[AudioStreamPlayer] = []
var _music_player: AudioStreamPlayer
var _pool_size: int = 8

# Rutas opcionales (si no existen, el SFX se omite sin error)
const SFX_PATHS := {
	"hit": "res://assets/audio/sfx/hit.wav",
	"hurt": "res://assets/audio/sfx/hurt.wav",
	"dash": "res://assets/audio/sfx/dash.wav",
	"jump": "res://assets/audio/sfx/jump.wav",
	"parry": "res://assets/audio/sfx/parry.wav",
	"pickup": "res://assets/audio/sfx/pickup.wav",
	"ui_click": "res://assets/audio/menu/menu_click.wav",
	"ui_hover": "res://assets/audio/menu/menu_hover.wav",
	"ability": "res://assets/audio/menu/menu_open.wav",
}

var _cache: Dictionary = {}


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_ensure_buses()
	_music_player = AudioStreamPlayer.new()
	_music_player.name = "MusicPlayer"
	_music_player.bus = BUS_MUSIC
	add_child(_music_player)
	for i in _pool_size:
		var p := AudioStreamPlayer.new()
		p.name = "SFX_%d" % i
		p.bus = BUS_SFX
		add_child(p)
		_sfx_players.append(p)


func _ensure_buses() -> void:
	# V105 puede no tener buses propios. Los creamos para que
	# el sistema de volumen funcione sin romper el proyecto.
	if AudioServer.get_bus_index(BUS_MUSIC) < 0:
		AudioServer.add_bus()
		var music_idx := AudioServer.bus_count - 1
		AudioServer.set_bus_name(music_idx, BUS_MUSIC)
		AudioServer.set_bus_send(music_idx, BUS_MASTER)

	if AudioServer.get_bus_index(BUS_SFX) < 0:
		AudioServer.add_bus()
		var sfx_idx := AudioServer.bus_count - 1
		AudioServer.set_bus_name(sfx_idx, BUS_SFX)
		AudioServer.set_bus_send(sfx_idx, BUS_MASTER)


func set_master_volume_linear(v: float) -> void:
	_set_bus_linear(BUS_MASTER, v)


func set_music_volume_linear(v: float) -> void:
	_set_bus_linear(BUS_MUSIC, v)


func set_sfx_volume_linear(v: float) -> void:
	_set_bus_linear(BUS_SFX, v)


func _set_bus_linear(bus_name: String, v: float) -> void:
	var idx := AudioServer.get_bus_index(bus_name)
	if idx < 0:
		idx = AudioServer.get_bus_index(BUS_MASTER)
	v = clampf(v, 0.0, 1.0)
	var db := linear_to_db(v) if v > 0.001 else -80.0
	AudioServer.set_bus_volume_db(idx, db)
	volumen_cambiado.emit(bus_name, db)


func play_sfx(id: String, pitch_scale: float = 1.0, volume_db: float = 0.0) -> void:
	var stream := _get_stream(id)
	if stream == null:
		return
	for p in _sfx_players:
		if not p.playing:
			p.stream = stream
			p.pitch_scale = pitch_scale
			p.volume_db = volume_db
			p.play()
			return
	# Todos ocupados: reutiliza el primero
	var p0 := _sfx_players[0]
	p0.stream = stream
	p0.pitch_scale = pitch_scale
	p0.volume_db = volume_db
	p0.play()


func play_music(path: String, fade_in: float = 0.4) -> void:
	if not ResourceLoader.exists(path):
		return
	var stream: AudioStream = load(path)
	if stream == null:
		return
	_music_player.stream = stream
	_music_player.volume_db = -20.0
	_music_player.play()
	if fade_in > 0.0:
		var t := create_tween()
		t.tween_property(_music_player, "volume_db", 0.0, fade_in)


func stop_music(fade_out: float = 0.3) -> void:
	if not _music_player.playing:
		return
	if fade_out <= 0.0:
		_music_player.stop()
		return
	var t := create_tween()
	t.tween_property(_music_player, "volume_db", -40.0, fade_out)
	t.tween_callback(_music_player.stop)


func _get_stream(id: String) -> AudioStream:
	if _cache.has(id):
		return _cache[id]
	var path: String = str(SFX_PATHS.get(id, ""))
	if path.is_empty() or not ResourceLoader.exists(path):
		_cache[id] = null
		return null
	var stream: AudioStream = load(path)
	_cache[id] = stream
	return stream
