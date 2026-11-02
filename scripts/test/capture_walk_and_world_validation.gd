extends Node

var step: int = 0
var timer: float = 0.0
var world: Node3D
var player: VaderPlayer
var test_cam: Camera3D

func _ready() -> void:
	print("=== CAPTURING COMPLETE OPEN-WORLD & GUITAR VALIDATION SCREENSHOTS ===")
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
			# Screenshot 1: Sanctuary Cabin Doorway & Veranda Walkout
			# Vader stepping right out through the open sliding doors onto the veranda
			player.global_position = Vector3(2.62, 1.58, -1.8)
			player.rotation.y = deg_to_rad(180.0) # Walking out toward veranda
			player._play_anim("Walk_Minifig")
			player.animation_player.seek(0.35, true)
			
			test_cam.global_position = Vector3(1.2, 2.3, -3.8)
			test_cam.look_at(Vector3(2.62, 1.8, -1.0))
			if timer > 0.6:
				_capture("01_sanctuary_cabin_doorway")
				step = 1
				timer = 0.0
		1:
			# Screenshot 2: Vader holding the new authentic LEGO Acoustic Guitar (Close-up)
			player.global_position = Vector3(0.0, 0.45, 0.0)
			player.rotation.y = deg_to_rad(15.0)
			player._toggle_guitar() # equips guitar across chest
			player._play_anim("Guitar_Strum")
			player.animation_player.seek(0.4, true)
			
			test_cam.global_position = Vector3(0.3, 1.3, -1.6)
			test_cam.look_at(Vector3(0.0, 1.0, 0.0))
			if timer > 0.6:
				_capture("02_vader_holding_new_lego_guitar")
				step = 2
				timer = 0.0
		2:
			# Screenshot 3: Vader with guitar slung on back, hands free
			player._toggle_guitar() # holsters to back
			player._play_anim("Idle_Casual")
			
			test_cam.global_position = Vector3(-0.4, 1.3, 1.8)
			test_cam.look_at(Vector3(0.0, 1.0, 0.0))
			if timer > 0.6:
				_capture("03_vader_guitar_slung_on_back")
				step = 3
				timer = 0.0
		3:
			# Screenshot 4: Speeder Bike Landing Pad with Villager Jax
			player.global_position = Vector3(-2.8, 0.45, -3.2)
			player.rotation.y = deg_to_rad(-90.0)
			
			test_cam.global_position = Vector3(-0.8, 1.8, -1.8)
			test_cam.look_at(Vector3(-3.2, 0.9, -3.2))
			if timer > 0.6:
				_capture("04_speeder_bike_and_jax_mechanic")
				step = 4
				timer = 0.0
		4:
			# Screenshot 5: Coastal Dock with Skiff Boat and Villager Barnaby
			player.global_position = Vector3(-5.2, 0.45, 3.8)
			player.rotation.y = deg_to_rad(45.0)
			
			test_cam.global_position = Vector3(-3.0, 2.0, 1.8)
			test_cam.look_at(Vector3(-6.2, 0.8, 3.8))
			if timer > 0.6:
				_capture("05_dock_skiff_and_barnaby_fisherman")
				step = 5
				timer = 0.0
		5:
			# Screenshot 6: Village Sanctuary Campfire with Villager Corin, Greenhouse, and Gonk Droid
			player.global_position = Vector3(26.5, 0.35, 8.0)
			player.rotation.y = deg_to_rad(90.0)
			
			test_cam.global_position = Vector3(22.0, 2.6, 5.0)
			test_cam.look_at(Vector3(28.5, 1.0, 8.0))
			if timer > 0.6:
				_capture("06_village_campfire_and_corin_elder")
				step = 6
				timer = 0.0
		6:
			# Screenshot 7: Peaceful Non-Lethal Pacification of Dune Massiff
			var massiff = world.find_child("Creature_Massiff", true, false)
			if massiff:
				player.global_position = massiff.global_position + Vector3(2.2, 0, 0)
				player.rotation.y = deg_to_rad(-90.0)
				player._toggle_lightsaber()
				massiff.pacify_creature()
				
				test_cam.global_position = massiff.global_position + Vector3(0.5, 2.2, -4.2)
				test_cam.look_at(massiff.global_position + Vector3(0, 0.6, 0))
			if timer > 0.6:
				_capture("07_pacifying_massiff_creature")
				print("=== All 7 Enhanced Validation Screenshots Captured! ===")
				get_tree().quit(0)

func _capture(label: String) -> void:
	var img = get_viewport().get_texture().get_image()
	if img:
		var dir = "/Users/vincyvincent/.gemini/antigravity/scratch/lego-vader-openworld/test_screenshots"
		DirAccess.make_dir_absolute(dir)
		var file_path = "%s/%s.png" % [dir, label]
		img.save_png(file_path)
		
		# Also copy directly to artifacts
		var art_path = "/Users/vincyvincent/.gemini/antigravity/brain/268fde55-74bf-4b2f-9858-d5e0b58902f0/%s.png" % label
		img.save_png(art_path)
		print("[Screenshot Saved] " + file_path)
