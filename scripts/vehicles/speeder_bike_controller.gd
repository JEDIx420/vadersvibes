extends CharacterBody3D
class_name SpeederBikeController

@export var max_speed: float = 24.0
@export var boost_speed: float = 40.0
@export var acceleration: float = 22.0
@export var friction: float = 6.0
@export var steer_speed: float = 2.8
@export var hover_height: float = 0.65

@onready var mount_point: Node3D = $MountPoint
@onready var engine_sound: AudioStreamPlayer3D = $EngineSound
@onready var blaster_sound: AudioStreamPlayer3D = $BlasterSound
@onready var laser_flash_l: OmniLight3D = $LaserFlashL if has_node("LaserFlashL") else null
@onready var laser_flash_r: OmniLight3D = $LaserFlashR if has_node("LaserFlashR") else null

var is_mounted: bool = false
var current_rider: VaderPlayer = null
var current_lean: float = 0.0
var mount_cooldown: float = 0.0
var flash_timer: float = 0.0

func _ready() -> void:
	add_to_group("vehicles")
	if laser_flash_l: laser_flash_l.visible = false
	if laser_flash_r: laser_flash_r.visible = false

func _physics_process(delta: float) -> void:
	if mount_cooldown > 0:
		mount_cooldown -= delta
		
	if flash_timer > 0:
		flash_timer -= delta
		if flash_timer <= 0:
			if laser_flash_l: laser_flash_l.visible = false
			if laser_flash_r: laser_flash_r.visible = false
			
	# Hover raycast simulation
	var hover_bob = sin(Time.get_ticks_msec() * 0.005) * 0.05
	global_position.y = move_toward(global_position.y, hover_height + hover_bob, 2.0 * delta)
	
	if not is_mounted:
		velocity.x = move_toward(velocity.x, 0, friction * delta)
		velocity.z = move_toward(velocity.z, 0, friction * delta)
		move_and_slide()
		return
		
	var steer_input = 0.0
	if Input.is_key_pressed(KEY_A): steer_input += 1.0
	if Input.is_key_pressed(KEY_D): steer_input -= 1.0
	
	var throttle_input = 0.0
	if Input.is_key_pressed(KEY_W): throttle_input += 1.0
	if Input.is_key_pressed(KEY_S): throttle_input -= 1.0
	
	var is_boosting = Input.is_key_pressed(KEY_SHIFT) or Input.is_physical_key_pressed(KEY_SHIFT)
	var target_max_speed = boost_speed if is_boosting else max_speed
	
	# Turning and banking lean
	rotation.y += steer_input * steer_speed * delta
	current_lean = lerp(current_lean, steer_input * 0.35, 8.0 * delta)
	rotation.z = current_lean
	
	var forward_dir = -transform.basis.z
	if throttle_input > 0:
		velocity = velocity.move_toward(forward_dir * target_max_speed, acceleration * delta)
	elif throttle_input < 0:
		velocity = velocity.move_toward(-forward_dir * (max_speed * 0.3), acceleration * delta)
	else:
		velocity = velocity.move_toward(Vector3.ZERO, friction * delta)
		
	move_and_slide()
	
	# Blaster cannon fire (Left Mouse or Space or Enter)
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) or Input.is_key_pressed(KEY_SPACE):
		fire_blasters()
		
	if mount_cooldown <= 0 and (Input.is_key_pressed(KEY_E) or Input.is_action_just_pressed("interact")):
		dismount()

func mount(rider: VaderPlayer) -> void:
	is_mounted = true
	mount_cooldown = 0.5
	current_rider = rider
	rider.current_vehicle = self
	rider.state_machine.transition_to(PlayerStateMachine.State.RIDING_BIKE)
	if engine_sound and not engine_sound.playing:
		engine_sound.play()
	print("[SpeederBike] Vader mounted 74-Z Speeder Bike. WASD to pilot, Shift for repulsor boost, Left-Click for blasters, E to dismount.")

func dismount() -> void:
	if current_rider:
		current_rider.current_vehicle = null
		current_rider.global_position = global_position + transform.basis.x * 1.5
		current_rider.state_machine.transition_to(PlayerStateMachine.State.ON_FOOT)
		current_rider = null
	if engine_sound and engine_sound.playing:
		engine_sound.stop()
	is_mounted = false

func fire_blasters() -> void:
	if blaster_sound and not blaster_sound.playing:
		blaster_sound.play()
		flash_timer = 0.08
		if laser_flash_l: laser_flash_l.visible = true
		if laser_flash_r: laser_flash_r.visible = true
		print("[SpeederBike] *Pew-Pew!* Twin blaster cannons fired!")
