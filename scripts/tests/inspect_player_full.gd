extends SceneTree

func _init():
	var world = load("res://scenes/world/world.tscn").instantiate()
	var player = world.find_child("VaderPlayer", true, false)
	print("=== VADER PLAYER NODES & MESHES ===")
	_dump(player, 0)
	quit()

func _dump(node, depth):
	var indent = "  ".repeat(depth)
	var extra = ""
	if node is MeshInstance3D and node.mesh:
		extra = " [Mesh: " + str(node.mesh.resource_name) + " AABB: " + str(node.get_aabb()) + "]"
	print(indent + node.name + " (" + node.get_class() + ")" + extra)
	for c in node.get_children():
		_dump(c, depth + 1)
