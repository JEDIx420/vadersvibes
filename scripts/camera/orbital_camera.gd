extends Node3D
class_name CameraController

@export var target: Node3D
@export var mouse_sensitivity: float = 0.0025
@export var min_pitch: float = -55.0
@export var max_pitch: float = 35.0

@onready var spring_arm: SpringArm3D = $SpringArm3D

var _pitch: float = -12.0
var _yaw: float = 0.0

func _ready() -> void:
	set_as_top_level(true)
	_pitch = deg_to_rad(-12.0)
	_yaw = deg_to_rad(180.0)
	rotation.y = _yaw
	if spring_arm:
		spring_arm.rotation.x = _pitch

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		_yaw -= event.relative.x * mouse_sensitivity
		_pitch -= event.relative.y * mouse_sensitivity
		_pitch = clamp(_pitch, deg_to_rad(min_pitch), deg_to_rad(max_pitch))
		
		rotation.y = _yaw
		if spring_arm:
			spring_arm.rotation.x = _pitch

func _process(delta: float) -> void:
	if target:
		global_position = global_position.lerp(target.global_position + Vector3(0, 1.3, 0), 25.0 * delta)
		rotation.y = _yaw
		if spring_arm:
			spring_arm.rotation.x = _pitch
	elif get_parent() is CharacterBody3D:
		target = get_parent()
