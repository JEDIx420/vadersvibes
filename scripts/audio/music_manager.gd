extends Node
class_name MusicManager

@onready var bgm_player: AudioStreamPlayer = AudioStreamPlayer.new()
@onready var sfx_player: AudioStreamPlayer = AudioStreamPlayer.new()

var tracks = {
	"intro": "res://assets/audio/music/star_wars_main_theme.mp3",
	"peaceful": "res://assets/audio/music/star_wars_force_theme.mp3"
}

func _ready() -> void:
	add_child(bgm_player)
	add_child(sfx_player)
	bgm_player.bus = "Master"
	sfx_player.bus = "Master"

func play_bgm(track_name: String, loop: bool = true) -> void:
	if tracks.has(track_name):
		var stream = load(tracks[track_name])
		if stream:
			bgm_player.stream = stream
			bgm_player.play()

func stop_bgm(fade_duration: float = 1.0) -> void:
	var tween = create_tween()
	tween.tween_property(bgm_player, "volume_db", -80.0, fade_duration)
	tween.tween_callback(Callable(bgm_player, "stop"))

func play_sfx(path: String) -> void:
	var stream = load(path)
	if stream:
		sfx_player.stream = stream
		sfx_player.play()
