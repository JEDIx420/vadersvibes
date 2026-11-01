extends CharacterBody3D
class_name SpaceshipController

@export var max_flight_speed: float = 40.0
@export var pitch_speed: float = 1.8
@export var yaw_speed: float = 1.8

@onready var engine_sound: AudioStreamPlayer3D = $EngineSound if has_node("EngineSound") else null

var is_piloted: bool = false
var pilot: VaderPlayer = null
var mount_cooldown: float = 0.0

func _ready() -> void:
	add_to_group("spacecraft")

func _physics_process(delta: float) -> void:
	if mount_cooldown > 0:
		mount_cooldown -= delta
		
	if not is_piloted:
		return
		
	var pitch = 0.0
	if Input.is_key_pressed(KEY_W): pitch += 1.0
	if Input.is_key_pressed(KEY_S): pitch -= 1.0
	
	var yaw = 0.0
	if Input.is_key_pressed(KEY_A): yaw += 1.0
	if Input.is_key_pressed(KEY_D): yaw -= 1.0
	
	rotate_object_local(Vector3.RIGHT, pitch * pitch_speed * delta)
	rotate_y(yaw * yaw_speed * delta)
	
	var thrust = 0.0
	if Input.is_key_pressed(KEY_SPACE) or Input.is_action_pressed("jump"):
		thrust = 1.0
	elif Input.is_key_pressed(KEY_SHIFT):
		thrust = -0.5
		
	var forward = -transform.basis.z
	velocity = velocity.move_toward(forward * (thrust * max_flight_speed), 14.0 * delta)
	move_and_slide()
	
	if thrust != 0.0:
		if engine_sound and not engine_sound.playing:
			engine_sound.play()
	else:
		if engine_sound and engine_sound.playing:
			engine_sound.stop()
			
	if mount_cooldown <= 0 and (Input.is_key_pressed(KEY_E) or Input.is_action_just_pressed("interact")) and global_position.y < 8.0:
		dismount_ship()

func apply_barrier_repulsion(repulsion_force: Vector3) -> void:
	velocity += repulsion_force
	print("[Spaceship] Planetary barrier energy field detected! Repelling ship back safely toward Pelagia-Prime.")

func board_ship(p_pilot: VaderPlayer) -> void:
	is_piloted = true
	mount_cooldown = 0.6
	pilot = p_pilot
	p_pilot.current_vehicle = self
	p_pilot.state_machine.transition_to(PlayerStateMachine.State.SPACE_FLIGHT)
	print("[Spaceship] Vader boarded starship shuttle. Press SPACE for ion thrusters, WASD to steer, E near ground to land.")

func dismount_ship() -> void:
	if pilot:
		pilot.current_vehicle = null
		pilot.global_position = global_position + Vector3(0, 0, 4.0)
		pilot.state_machine.transition_to(PlayerStateMachine.State.ON_FOOT)
		pilot = null
	if engine_sound and engine_sound.playing:
		engine_sound.stop()
	is_piloted = false
