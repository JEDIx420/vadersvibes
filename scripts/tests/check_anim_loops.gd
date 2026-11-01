extends SceneTree

func _init():
	var scene = load("res://assets/characters/vader_rigged.glb").instantiate()
	var anim: AnimationPlayer = scene.find_child("AnimationPlayer", true, false)
	print("Animation list: ", anim.get_animation_list())
	for a_name in anim.get_animation_list():
		var a = anim.get_animation(a_name)
		print(a_name, " loop_mode: ", a.loop_mode, " length: ", a.length)
	quit()
