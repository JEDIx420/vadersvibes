extends CharacterBody3D
class_name BoatController

@export var max_speed: float = 12.0
@export var turn_speed: float = 2.2
@export var water_level: float = 0.2

@onready var splash_sound: AudioStreamPlayer3D = $SplashSound if has_node("SplashSound") else null

var is_piloted: bool = false
var pilot: VaderPlayer = null
var mount_cooldown: float = 0.0

func _ready() -> void:
	add_to_group("boats")

func _physics_process(delta: float) -> void:
	if mount_cooldown > 0:
		mount_cooldown -= delta
		
	# Gentle wave bobbing
	var wave_bob = sin(Time.get_ticks_msec() * 0.002) * 0.08
	global_position.y = water_level + wave_bob
	
	if not is_piloted:
		velocity = velocity.move_toward(Vector3.ZERO, 2.0 * delta)
		move_and_slide()
		return
		
	var steer = 0.0
	if Input.is_key_pressed(KEY_A): steer += 1.0
	if Input.is_key_pressed(KEY_D): steer -= 1.0
	
	var throttle = 0.0
	if Input.is_key_pressed(KEY_W): throttle += 1.0
	if Input.is_key_pressed(KEY_S): throttle -= 1.0
	
	rotation.y += steer * turn_speed * delta
	var forward = -transform.basis.z
	velocity = forward * (throttle * max_speed)
	move_and_slide()
	
	if throttle != 0.0 and splash_sound and not splash_sound.playing:
		splash_sound.play()
		
	if mount_cooldown <= 0 and (Input.is_key_pressed(KEY_E) or Input.is_action_just_pressed("interact")):
		dismount_boat()

func disembark() -> void:
	dismount_boat()

func board_boat(p_pilot: VaderPlayer) -> void:
	is_piloted = true
	mount_cooldown = 0.5
	pilot = p_pilot
	p_pilot.current_vehicle = self
	p_pilot.state_machine.transition_to(PlayerStateMachine.State.BOATING)
	print("[Boat] Vader boarded the coastal skiff. Cruise the lagoons of Pelagia-Prime!")

func dismount_boat() -> void:
	if pilot:
		pilot.current_vehicle = null
		pilot.global_position = global_position + Vector3(2.0, 1.0, 0)
		pilot.state_machine.transition_to(PlayerStateMachine.State.ON_FOOT)
		pilot = null
	is_piloted = false
