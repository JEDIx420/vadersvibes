extends Node3D
class_name CabinDoorController

@export var door_anim_player: AnimationPlayer
var is_open: bool = false

func _ready() -> void:
	if not door_anim_player:
		door_anim_player = get_parent().find_child("AnimationPlayer", true, false)

func _process(_delta: float) -> void:
	var player = get_tree().get_first_node_in_group("player") if (is_inside_tree() and get_tree()) else null
	if not player or not door_anim_player:
		return
	var dist = global_position.distance_to(player.global_position)
	if dist < 3.2 and not is_open:
		is_open = true
		if door_anim_player.has_animation("door_swing_001"):
			door_anim_player.play("door_swing_001")
	elif dist > 4.5 and is_open:
		is_open = false
		if door_anim_player.has_animation("door_swing_001"):
			door_anim_player.play_backwards("door_swing_001")
