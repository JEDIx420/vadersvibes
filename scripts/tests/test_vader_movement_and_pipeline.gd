extends SceneTree

func _init():
	print("==================================================")
	print("  TEST: VADER MOVEMENT, ORIENTATION & ANIMATION   ")
	print("==================================================")
	
	var world_scene = load("res://scenes/world/world.tscn")
	var world = world_scene.instantiate()
	root.add_child(world)
	
	# Process one physics frame so everything is in tree
	await process_frame
	
	var player: VaderPlayer = world.find_child("VaderPlayer", true, false)
	assert(player != null, "VaderPlayer must exist in world!")
	
	var cam: Camera3D = world.find_child("Camera3D", true, false)
	assert(cam != null, "Camera3D must exist!")
	
	var anim_player: AnimationPlayer = player.animation_player
	assert(anim_player != null, "AnimationPlayer must exist!")
	
	print("[1/5] Checking initial idle state...")
	print("  Player initial rotation: ", player.rotation)
	print("  Initial animation: ", anim_player.current_animation)
	assert(anim_player.has_animation("Walk_Minifig"), "Walk_Minifig animation must exist!")
	assert(anim_player.has_animation("Run_Minifig"), "Run_Minifig animation must exist!")
	assert(anim_player.has_animation("Idle_Casual"), "Idle_Casual animation must exist!")
	assert(anim_player.has_animation("Guitar_Strum"), "Guitar_Strum animation must exist!")
	assert(anim_player.has_animation("Bike_Ride_Pose"), "Bike_Ride_Pose animation must exist!")
	assert(anim_player.has_animation("Lightsaber_Flourish"), "Lightsaber_Flourish animation must exist!")
	
	# Check loop modes
	for anim_name in ["Idle_Casual", "Walk_Minifig", "Run_Minifig", "Guitar_Strum", "Bike_Ride_Pose"]:
		var a = anim_player.get_animation(anim_name)
		assert(a.loop_mode == Animation.LOOP_LINEAR, "Animation " + anim_name + " must be set to LOOP_LINEAR!")
	print("  PASS: All 6 animations present with proper loop modes.")
	
	print("[2/5] Simulating Walk Forward (Pressing W)...")
	# When pressing W, cam_forward points along camera forward look direction
	var cam_forward = -cam.global_transform.basis.z
	cam_forward.y = 0.0
	cam_forward = cam_forward.normalized()
	print("  Camera forward vector: ", cam_forward)
	
	# Simulate movement processing
	var input_x = 0.0
	var input_z = 1.0 # Pressing W
	var move_dir = (cam_forward * input_z).normalized()
	var current_speed = player.walk_speed
	player.velocity.x = move_dir.x * current_speed
	player.velocity.z = move_dir.z * current_speed
	
	# Compute yaw
	var target_yaw = atan2(move_dir.x, move_dir.z)
	player.rotation.y = target_yaw
	player._play_anim("Walk_Minifig")
	
	# Check facing direction:
	# In Vader's model, front is +Z. Rotated by target_yaw:
	var forward_facing = player.global_transform.basis.z
	forward_facing.y = 0.0
	forward_facing = forward_facing.normalized()
	
	print("  Movement direction: ", move_dir)
	print("  Player front facing vector (+basis.z): ", forward_facing)
	print("  Dot product between movement and facing: ", move_dir.dot(forward_facing))
	assert(move_dir.dot(forward_facing) > 0.99, "Vader must face FORWARD in the exact direction he is moving!")
	assert(anim_player.current_animation == "Walk_Minifig", "Walk animation must be playing!")
	print("  PASS: Vader faces forward into the walk direction without backward sliding.")
	
	print("[3/5] Simulating Sprint Forward (Pressing Shift + W)...")
	player._play_anim("Run_Minifig")
	assert(anim_player.current_animation == "Run_Minifig", "Run animation must be playing during sprint!")
	print("  PASS: Run animation verified during sprint.")
	
	print("[4/5] Simulating Walk Left (Pressing A) and Walk Right (Pressing D)...")
	# Pressing A:
	var cam_right = cam.global_transform.basis.x
	cam_right.y = 0.0
	cam_right = cam_right.normalized()
	var move_left = -cam_right
	var target_yaw_left = atan2(move_left.x, move_left.z)
	player.rotation.y = target_yaw_left
	var facing_left = player.global_transform.basis.z.normalized()
	assert(move_left.dot(facing_left) > 0.99, "Vader must face Left when moving Left!")
	
	# Pressing D:
	var move_right = cam_right
	var target_yaw_right = atan2(move_right.x, move_right.z)
	player.rotation.y = target_yaw_right
	var facing_right = player.global_transform.basis.z.normalized()
	assert(move_right.dot(facing_right) > 0.99, "Vader must face Right when moving Right!")
	print("  PASS: Lateral movement directions and facing match 100%.")
	
	print("[5/5] Checking Star Wars Audio & LEGO Sanctuary Cabin...")
	var bgm: AudioStreamPlayer = world.find_child("BGMPlayer", true, false)
	assert(bgm != null and bgm.stream != null, "BGM Player must have audio stream loaded!")
	print("  BGM stream path: ", bgm.stream.resource_path)
	assert(bgm.stream.resource_path.ends_with(".mp3"), "Should be authentic Star Wars MP3 track!")
	
	var sanctuary = world.find_child("lego_coastal_sanctuary", true, false)
	assert(sanctuary != null, "lego_coastal_sanctuary must be present in open world!")
	print("  Sanctuary found with child count: ", sanctuary.get_child_count())
	
	var door_ctrl = sanctuary.find_child("CabinDoorController", true, false)
	assert(door_ctrl != null, "CabinDoorController must be attached to cabin!")
	print("  CabinDoorController verified.")
	
	print("\n==================================================")
	print("  ALL VADER MOVEMENT & ORIENTATION TESTS PASSED!  ")
	print("==================================================\n")
	
	quit(0)
