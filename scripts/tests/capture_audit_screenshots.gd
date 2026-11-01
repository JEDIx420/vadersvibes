extends SceneTree

var frame_count: int = 0
var world: Node3D
var player: VaderPlayer
var cam: Camera3D

func _init():
	print("[Audit Capture] Initializing screenshot capture...")

func _process(delta: float) -> bool:
	frame_count += 1
	if frame_count == 1:
		var scene = load("res://scenes/world/world.tscn").instantiate()
		root.add_child(scene)
		world = scene
		player = world.find_child("VaderPlayer", true, false)
		return false
		
	# Wait for shaders and textures to settle
	if frame_count == 15:
		# Disable player camera
		var cam_mount = player.find_child("CameraMount", true, false)
		if cam_mount:
			cam_mount.set_process(false)
			var old_cam = cam_mount.find_child("Camera3D", true, false)
			if old_cam:
				old_cam.current = false
				
		cam = Camera3D.new()
		cam.name = "AuditCamera"
		cam.current = true
		root.add_child(cam)
		
		# 1. Vader Close-up: position camera in front of Vader looking at his face/torso
		cam.global_position = player.global_position + Vector3(0.0, 1.3, 1.8)
		cam.look_at(player.global_position + Vector3(0.0, 1.0, 0.0), Vector3.UP)
		return false
		
	if frame_count == 25:
		_save("audit_01_vader_closeup.png")
		# 2. Normal Third-Person Exploration View (behind Vader looking forward)
		cam.global_position = player.global_position + Vector3(0.0, 2.0, -3.2)
		cam.look_at(player.global_position + Vector3(0.0, 1.2, 2.0), Vector3.UP)
		return false
		
	if frame_count == 35:
		_save("audit_02_thirdperson_exploration.png")
		# 3. Wide Environment View (high vantage looking over the cottage, landing pad, terrain)
		cam.global_position = Vector3(15.0, 20.0, -25.0)
		cam.look_at(Vector3(0.0, 2.0, 10.0), Vector3.UP)
		return false
		
	if frame_count == 45:
		_save("audit_03_wide_environment.png")
		# 4. Representative Interaction: Speeder Bike mounting on landing pad
		var speeder = world.find_child("SpeederBike", true, false)
		if speeder and player:
			player.global_position = speeder.global_position + Vector3(0.0, 0.0, 1.4)
			player._update_proximity_hud()
		cam.global_position = speeder.global_position + Vector3(2.5, 1.8, 2.8)
		cam.look_at(speeder.global_position + Vector3(0.0, 0.6, 0.0), Vector3.UP)
		return false
		
	if frame_count == 55:
		_save("audit_04_interaction_speeder.png")
		print("[Audit Capture] All 4 audit screenshots successfully captured!")
		quit()
		return true
		
	return false

func _save(filename: String) -> void:
	var img = root.get_viewport().get_texture().get_image()
	if img:
		var dir = "/Users/vincyvincent/.gemini/antigravity/scratch/lego-vader-openworld/test_screenshots"
		var path = dir + "/" + filename
		img.save_png(path)
		print("[Audit Capture] Saved:", path)
		# Also copy to artifact directory directly
		var art_path = "/Users/vincyvincent/.gemini/antigravity/brain/268fde55-74bf-4b2f-9858-d5e0b58902f0/" + filename
		img.save_png(art_path)
		print("[Audit Capture] Copied to artifact dir:", art_path)
