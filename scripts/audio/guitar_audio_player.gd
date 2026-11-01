extends Node
class_name GuitarAudioPlayer

var chords: Dictionary = {}
var chord_names = ["chord_E", "chord_A", "chord_D", "chord_G", "chord_B", "chord_Em"]

func _ready() -> void:
	for c in chord_names:
		var path = "res://assets/audio/guitar_notes/" + c + ".wav"
		var s = load(path)
		if s:
			chords[c] = s

func play_chord_index(idx: int) -> void:
	if idx >= 0 and idx < chord_names.size():
		play_chord(chord_names[idx])

func play_chord(chord_name: String) -> void:
	if chords.has(chord_name):
		var p = AudioStreamPlayer.new()
		add_child(p)
		p.stream = chords[chord_name]
		p.volume_db = -3.0
		p.finished.connect(p.queue_free)
		p.play()
