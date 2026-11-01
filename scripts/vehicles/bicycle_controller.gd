extends CharacterBody3D
class_name BicycleController

@export var max_speed: float = 12.0
@export var acceleration: float = 8.0
@export var friction: float = 4.0
@export var steer_speed: float = 2.5

@onready var mount_point: Node3D = $MountPoint
@onready var bell_player: AudioStreamPlayer3D = $BellPlayer

var is_mounted: bool = false
var current_rider: VaderPlayer = null

func _ready() -> void:
	add_to_group("vehicles")

func _physics_process(delta: float) -> void:
	if not is_mounted:
		# Apply friction to rest
		velocity.x = move_toward(velocity.x, 0, friction * delta)
		velocity.z = move_toward(velocity.z, 0, friction * delta)
		move_and_slide()
		return
		
	var steer_input = Input.get_axis("move_right", "move_left")
	var throttle_input = Input.get_axis("move_backward", "move_forward")
	
	rotation.y += steer_input * steer_speed * delta
	
	var forward_dir = -transform.basis.z
	if throttle_input > 0:
		velocity = velocity.move_toward(forward_dir * max_speed, acceleration * delta)
	elif throttle_input < 0:
		velocity = velocity.move_toward(-forward_dir * (max_speed * 0.4), acceleration * delta)
	else:
		velocity = velocity.move_toward(Vector3.ZERO, friction * delta)
		
	move_and_slide()
	
	if Input.is_action_just_pressed("ring_bell"):
		ring_bell()
		
	if Input.is_action_just_pressed("interact"):
		dismount()

func mount(rider: VaderPlayer) -> void:
	is_mounted = true
	current_rider = rider
	rider.current_vehicle = self
	rider.state_machine.transition_to(PlayerStateMachine.State.RIDING_BIKE)
	print("[Bicycle] Vader mounted the bicycle. Ride around Pelagia-Prime! Press R to ring bell, E to dismount.")

func dismount() -> void:
	if current_rider:
		current_rider.current_vehicle = null
		current_rider.global_position = global_position + transform.basis.x * 1.2
		current_rider.state_machine.transition_to(PlayerStateMachine.State.ON_FOOT)
		current_rider = null
	is_mounted = false

func ring_bell() -> void:
	if bell_player:
		var stream = load("res://assets/audio/sfx/bike_bell.wav")
		if stream:
			bell_player.stream = stream
			bell_player.play()
			print("[Bicycle] *Ring Ring!*")
