extends SceneTree

func _init():
	var scene = load("res://assets/characters/vader_rigged.glb").instantiate()
	var skel: Skeleton3D = scene.find_child("Skeleton3D", true, false)
	print("Bone count: ", skel.get_bone_count())
	for i in range(skel.get_bone_count()):
		print("Bone ", i, ": ", skel.get_bone_name(i), " rest pose: ", skel.get_bone_rest(i).origin)
	quit()
