extends SceneTree

# Visual verification screenshot generator
var root_node: Node3D = null
var player: VaderPlayer = null
var current_shot: int = 0
var shot_timer: float = 0.0

func _init() -> void:
	var world_scene = load("res://scenes/world/world.tscn")
	root_node = world_scene.instantiate()
	root.add_child(root_node)
	player = root_node.get_node_or_null("VaderPlayer") as VaderPlayer

func _process(delta: float) -> bool:
	shot_timer += delta
	
	match current_shot:
		0:
			# Shot 0: Bedroom & Veranda Door Walkout
			if shot_timer > 0.4:
				player.global_position = Vector3(2.62, 1.6, -1.9)
				var cam = root.get_camera_3d()
				if cam:
					cam.global_position = Vector3(2.62, 2.6, 1.2)
					cam.look_at(Vector3(2.62, 1.6, -4.0), Vector3.UP)
				_capture_screen("01_bedroom_veranda_walkout.png")
				current_shot = 1
				shot_timer = 0.0
		1:
			# Shot 1: Vader holding the new LEGO Acoustic Guitar
			if shot_timer > 0.3:
				player.global_position = Vector3(0.0, 0.4, 0.0)
				player._toggle_guitar()
				var cam = root.get_camera_3d()
				if cam:
					cam.global_position = Vector3(0.0, 1.4, -2.4)
					cam.look_at(player.global_position + Vector3(0, 1.0, 0), Vector3.UP)
				_capture_screen("02_vader_holding_new_lego_guitar.png")
				current_shot = 2
				shot_timer = 0.0
		2:
			# Shot 2: Vader with guitar slung on back, hands free
			if shot_timer > 0.3:
				player._toggle_guitar() # holsters to back
				var cam = root.get_camera_3d()
				if cam:
					cam.global_position = Vector3(0.0, 1.4, 2.4)
					cam.look_at(player.global_position + Vector3(0, 1.0, 0), Vector3.UP)
				_capture_screen("03_vader_holstered_guitar_on_back.png")
				current_shot = 3
				shot_timer = 0.0
		3:
			# Shot 3: Pier with Barnaby the Fisherman & Skiff Boat
			if shot_timer > 0.3:
				player.global_position = Vector3(-5.0, 0.35, 3.8)
				var cam = root.get_camera_3d()
				if cam:
					cam.global_position = Vector3(-3.0, 1.8, 2.0)
					cam.look_at(Vector3(-6.2, 0.8, 3.5), Vector3.UP)
				_capture_screen("04_vader_with_villager_barnaby.png")
				current_shot = 4
				shot_timer = 0.0
		4:
			# Shot 4: Speeder Bike Landing Pad with Jax the Mechanic
			if shot_timer > 0.3:
				player.global_position = Vector3(-2.8, 0.35, -3.2)
				var cam = root.get_camera_3d()
				if cam:
					cam.global_position = Vector3(-1.0, 1.8, -1.0)
					cam.look_at(Vector3(-3.0, 0.8, -3.2), Vector3.UP)
				_capture_screen("05_vader_with_villager_jax_speeder.png")
				current_shot = 5
				shot_timer = 0.0
		5:
			# Shot 5: Village Campfire with Corin, Greenhouse, and Gonk Droid
			if shot_timer > 0.3:
				player.global_position = Vector3(26.0, 0.2, 8.0)
				var cam = root.get_camera_3d()
				if cam:
					cam.global_position = Vector3(23.0, 2.5, 5.0)
					cam.look_at(Vector3(28.0, 1.0, 8.0), Vector3.UP)
				_capture_screen("06_vader_village_campfire_corin.png")
				current_shot = 6
				shot_timer = 0.0
		6:
			# Shot 6: Wildlife Peaceful Pacification in Savannah
			if shot_timer > 0.3:
				var massiff = root_node.get_node_or_null("Creature_Massiff")
				if massiff:
					player.global_position = massiff.global_position + Vector3(2.5, 0, 0)
					player._toggle_lightsaber()
					var cam = root.get_camera_3d()
					if cam:
						cam.global_position = massiff.global_position + Vector3(0.0, 2.2, -4.5)
						cam.look_at(massiff.global_position + Vector3(0, 0.6, 0), Vector3.UP)
				_capture_screen("07_vader_pacifying_massiff.png")
				current_shot = 7
				shot_timer = 0.0
		7:
			print("All 7 gameplay visual verification screenshots captured!")
			quit(0)
			return false

	return false

func _capture_screen(filename: String) -> void:
	var img = root.get_viewport().get_texture().get_image()
	if img:
		var path = "/Users/vincyvincent/.gemini/antigravity/scratch/lego-vader-openworld/test_screenshots/" + filename
		img.save_png(path)
		var art_path = "/Users/vincyvincent/.gemini/antigravity/brain/268fde55-74bf-4b2f-9858-d5e0b58902f0/" + filename
		img.save_png(art_path)
		print("Saved screenshot: ", path)
