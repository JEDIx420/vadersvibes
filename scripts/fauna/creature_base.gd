extends CharacterBody3D
class_name CreatureBase

enum CreatureType {
	MASSIFF,      # Plains / Dunes
	LOTH_WOLF,    # Canopy Forest
	FROST_WAMPA,  # Snowy Peaks
	GUNDARK       # Coastal Waters
}

@export var creature_type: CreatureType = CreatureType.MASSIFF
@export var creature_name: String = "Dune Massiff"
@export var speed: float = 3.5
@export var is_threatening_village: bool = false

@onready var growl_sound: AudioStreamPlayer3D = $GrowlSound if has_node("GrowlSound") else null

var roam_target: Vector3
var is_pacified: bool = false
var wander_timer: float = 0.0

signal pacified(creature: CreatureBase)

func _ready() -> void:
	add_to_group("creatures")
	_pick_new_roam_target()

func _physics_process(delta: float) -> void:
	if is_pacified:
		# Scurry back into the wilderness safely
		var escape_dir = (roam_target - global_position)
		escape_dir.y = 0
		if escape_dir.length() > 1.0:
			var target_yaw = atan2(-escape_dir.x, -escape_dir.z)
			rotation.y = lerp_angle(rotation.y, target_yaw, 8.0 * delta)
			velocity = escape_dir.normalized() * (speed * 1.6)
		else:
			velocity = Vector3.ZERO
		move_and_slide()
		return
		
	wander_timer -= delta
	if wander_timer <= 0:
		_pick_new_roam_target()
		
	var dir = (roam_target - global_position)
	dir.y = 0
	if dir.length() > 1.0:
		velocity = dir.normalized() * speed
		var target_yaw = atan2(-dir.x, -dir.z)
		rotation.y = lerp_angle(rotation.y, target_yaw, 4.0 * delta)
	else:
		velocity = Vector3.ZERO
		
	move_and_slide()

func _pick_new_roam_target() -> void:
	wander_timer = randf_range(4.0, 8.0)
	var rand_offset = Vector3(randf_range(-18.0, 18.0), 0, randf_range(-18.0, 18.0))
	roam_target = global_position + rand_offset
	if growl_sound and not growl_sound.playing and randf() < 0.2:
		growl_sound.play()

func pacify_creature() -> void:
	if is_pacified:
		return
	is_pacified = true
	is_threatening_village = false
	roam_target = global_position + Vector3(randf_range(-60.0, 60.0), 0, randf_range(-60.0, 60.0))
	pacified.emit(self)
	print("[Fauna] %s was pacified by Vader and scurried safely back to the wild!" % creature_name)
