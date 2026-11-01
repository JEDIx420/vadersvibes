extends Area3D
class_name OrbitalBarrier

@export var barrier_radius: float = 250.0

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _physics_process(_delta: float) -> void:
	var spaceships = get_tree().get_nodes_in_group("spacecraft")
	for ship in spaceships:
		var dist = ship.global_position.length()
		if dist > barrier_radius:
			# Gentle push back into the sanctuary safe zone
			var dir_to_center = -ship.global_position.normalized()
			if ship.has_method("apply_barrier_repulsion"):
				ship.apply_barrier_repulsion(dir_to_center * (dist - barrier_radius) * 2.0)

func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("player") or body.is_in_group("spacecraft"):
		print("[OrbitalBarrier] Approaching Pelagia-Prime planetary defense perimeter. Galactic wars cannot cross.")
