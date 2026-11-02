extends Node3D

@onready var bgm_player: AudioStreamPlayer = $BGMPlayer

func _ready() -> void:
	var stream = load("res://assets/audio/music/star_wars_force_theme.mp3")
	if stream and bgm_player:
		bgm_player.stream = stream
		bgm_player.play()
	print("[VaderBedroom] Stepping outside into Pelagia-Prime Sanctuary...")
	# Seamless transition to the full open world sanctuary
	get_tree().change_scene_to_file("res://scenes/world/world.tscn")

func _on_exit_door_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		print("[VaderBedroom] Stepping outside into the open world...")
		get_tree().change_scene_to_file("res://scenes/world/world.tscn")
