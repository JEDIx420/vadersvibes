extends Node

var timer: float = 0.0
var step: int = 0
var world: Node3D
var player: VaderPlayer
var test_cam: Camera3D
var step_initialized: bool = false

func _ready() -> void:
	world = get_tree().current_scene
	player = world.find_child("VaderPlayer", true, false)
	test_cam = Camera3D.new()
	world.call_deferred("add_child", test_cam)
	await get_tree().process_frame
	await get_tree().process_frame
	test_cam.make_current()

func _process(delta: float) -> void:
	if not test_cam or not test_cam.is_inside_tree() or not player:
		return
	timer += delta
	
	match step:
		0:
			if not step_initialized:
				step_initialized = true
				player.global_position = Vector3(12.0, 0.5, 5.0)
				player.rotation.y = deg_to_rad(180.0)
				if not player.is_holding_guitar:
					player._toggle_guitar() # equip guitar
				player._play_anim("Idle_Casual")
				
				# Adjust hand guitar directly in runner to find optimal framing
				if player.hand_guitar:
					player.hand_guitar.position = Vector3(0.02, 0.12, 0.30)
					player.hand_guitar.rotation = Vector3(deg_to_rad(10), 0, deg_to_rad(55))
					player.hand_guitar.scale = Vector3(1.2, 1.2, 1.2)
				
				# Camera in front of Vader showing upper body, hands, and the guitar
				test_cam.global_position = Vector3(12.0, 1.25, 3.2)
				test_cam.look_at(Vector3(12.0, 1.05, 5.0))
			
			if timer > 0.8:
				_capture("02_vader_holding_new_lego_guitar")
				step = 1
				timer = 0.0
				step_initialized = false
		1:
			if not step_initialized:
				step_initialized = true
				if player.is_holding_guitar:
					player._toggle_guitar() # holster guitar to back
				player._play_anim("Idle_Casual")
				
				# Camera behind Vader looking at the guitar slung diagonally across back
				test_cam.global_position = Vector3(12.0, 1.35, 7.3)
				test_cam.look_at(Vector3(12.0, 1.0, 5.0))
			
			if timer > 0.8:
				_capture("03_vader_guitar_slung_on_back")
				get_tree().quit(0)

func _capture(label: String) -> void:
	var img = get_viewport().get_texture().get_image()
	if img:
		var dir = "/Users/vincyvincent/.gemini/antigravity/scratch/lego-vader-openworld/test_screenshots"
		var file_path = "%s/%s.png" % [dir, label]
		img.save_png(file_path)
		var art_path = "/Users/vincyvincent/.gemini/antigravity/brain/268fde55-74bf-4b2f-9858-d5e0b58902f0/%s.png" % label
		img.save_png(art_path)
		print("[Screenshot Saved] " + file_path)
