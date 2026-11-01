extends SceneTree

func _init():
	var scene = load("res://scenes/rooms/vaders_bedroom.tscn").instantiate()
	root.add_child(scene)
	print("--- VADER'S BEDROOM HIERARCHY ---")
	_dump(scene, 0)
	quit()

func _dump(node, depth):
	var indent = "  ".repeat(depth)
	var pos = ""
	if node is Node3D:
		pos = " pos=" + str(node.position)
	print(indent + node.name + " (" + node.get_class() + ")" + pos)
	for c in node.get_children():
		_dump(c, depth + 1)
