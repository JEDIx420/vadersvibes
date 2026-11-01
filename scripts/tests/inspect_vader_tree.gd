extends SceneTree

func _init():
	var scene = load("res://assets/characters/vader_rigged.glb").instantiate()
	var helmet = scene.find_child("Mesh_Vader_Helmet", true, false)
	if helmet:
		var aabb = helmet.get_aabb()
		print("Helmet AABB position:", aabb.position, "size:", aabb.size)
		print("Helmet transform:", helmet.transform)
	var anim_player = scene.find_child("AnimationPlayer", true, false)
	if anim_player:
		print("Animations:", anim_player.get_animation_list())
	quit()
