extends Node

var step: int = 0
var timer: float = 0.0
var world: Node3D
var player: VaderPlayer
var test_cam: Camera3D

func _ready() -> void:
	print("=== CAPTURING ENHANCED WALK & WORLD VALIDATION SCREENSHOTS ===")
	world = get_tree().current_scene
	player = world.find_child("VaderPlayer", true, false)
	
	test_cam = Camera3D.new()
	test_cam.name = "ValidationCamera"
	world.call_deferred("add_child", test_cam)
	await get_tree().process_frame
	await get_tree().process_frame
	test_cam.make_current()

func _process(delta: float) -> void:
	if not test_cam or not test_cam.is_inside_tree():
		return
		
	timer += delta
	match step:
		0:
			# Screenshot 1: Cozy Cabin Interior with floor furniture & Vader looking out door
			test_cam.global_position = Vector3(2.6, 2.3, -2.8)
			test_cam.look_at(Vector3(2.6, 1.8, 1.0))
			player.global_position = Vector3(2.6, 1.58, -0.6)
			player.rotation.y = 0.0 # Facing South toward doorway
			player._play_anim("Idle_Casual")
			if timer > 0.6:
				_capture("01_sanctuary_cabin_interior")
				step = 1
				timer = 0.0
		1:
			# Screenshot 2: Vader Walking Forward outside on the sunlit path (W gait)
			player.global_position = Vector3(0.0, 0.45, 2.0)
			player.rotation.y = deg_to_rad(45.0) # Walking down path
			player._play_anim("Walk_Minifig")
			player.animation_player.seek(0.35, true) # Mid-stride pose showing alternating legs & arms
			
			# Position camera behind Vader at 3rd-person angle
			test_cam.global_position = Vector3(-1.8, 1.8, 0.2)
			test_cam.look_at(Vector3(0.0, 1.2, 2.0))
			if timer > 0.5:
				_capture("02_vader_walking_stride_forward")
				step = 2
				timer = 0.0
		2:
			# Screenshot 3: Vader Sprinting (Shift + W)
			player._play_anim("Run_Minifig")
			player.animation_player.seek(0.2, true) # High-energy sprint pose with forward lean
			if timer > 0.4:
				_capture("03_vader_sprinting_forward")
				step = 3
				timer = 0.0
		3:
			# Screenshot 4: Speeder Bike on Landing Pad with Vader & Ocean
			player.global_position = Vector3(-2.6, 0.45, -3.2)
			player.rotation.y = deg_to_rad(-90.0) # Facing speeder bike
			player._play_anim("Idle_Casual")
			
			test_cam.global_position = Vector3(-1.2, 2.0, -5.5)
			test_cam.look_at(Vector3(-3.8, 0.9, -3.2))
			if timer > 0.5:
				_capture("04_speeder_bike_landing_pad")
				step = 4
				timer = 0.0
		4:
			# Screenshot 5: Expansive Wide View of Studded Baseplate Open World & Pier
			test_cam.global_position = Vector3(-16.0, 12.0, -18.0)
			test_cam.look_at(Vector3(5.0, 1.0, 5.0))
			if timer > 0.5:
				_capture("05_wide_studded_openworld")
				print("=== All 5 Enhanced Validation Screenshots Captured! ===")
				get_tree().quit(0)

func _capture(label: String) -> void:
	var img = get_viewport().get_texture().get_image()
	if img:
		var dir = "/Users/vincyvincent/.gemini/antigravity/scratch/lego-vader-openworld/test_screenshots"
		DirAccess.make_dir_absolute(dir)
		var file_path = "%s/%s.png" % [dir, label]
		img.save_png(file_path)
		print("[Screenshot Saved] " + file_path)
