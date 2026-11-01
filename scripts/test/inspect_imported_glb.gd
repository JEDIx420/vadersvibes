@tool
extends SceneTree

func _init() -> void:
	print("--- Inspecting imported lego_coastal_sanctuary.glb ---")
	var glb_res = load("res://assets/test_pipeline/lego_coastal_sanctuary.glb")
	if not glb_res:
		printerr("Failed to load lego_coastal_sanctuary.glb")
		quit(1)
		return
	var inst = glb_res.instantiate()
	print("Root node name:", inst.name, "Class:", inst.get_class())
	
	# Find AnimationPlayer
	var anim_players = inst.find_children("", "AnimationPlayer", true, false)
	print("Animation players found:", anim_players.size())
	for ap in anim_players:
		var p: AnimationPlayer = ap
		print("  Player:", p.name, "Animations:", p.get_animation_list())
		
	# Find Meshes & Colliders
	var mesh_instances = inst.find_children("", "MeshInstance3D", true, false)
	var static_bodies = inst.find_children("", "StaticBody3D", true, false)
	print("Total MeshInstance3D nodes:", mesh_instances.size())
	print("Total StaticBody3D nodes:", static_bodies.size())
	
	for sb in static_bodies:
		print("  StaticBody3D:", sb.name, "CollisionShapes:", sb.get_child_count())
		
	inst.queue_free()
	print("--- Inspection Complete ---")
	quit(0)
