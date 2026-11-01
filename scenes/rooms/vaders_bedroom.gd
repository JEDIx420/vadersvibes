extends Node3D

@onready var bgm_player: AudioStreamPlayer = $BGMPlayer

func _ready() -> void:
	var stream = load("res://assets/audio/music/lofi_binary_sunset_acoustic.wav")
	if stream and bgm_player:
		bgm_player.stream = stream
		bgm_player.play()
	print("[VaderBedroom] Welcome home to your peaceful sanctuary on Pelagia-Prime.")

func _on_exit_door_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		print("[VaderBedroom] Stepping outside into the open world...")
		get_tree().change_scene_to_file("res://scenes/world/world.tscn")
