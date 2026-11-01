extends Node
class_name VillageDefenseEvent

@export var village_center: Vector3 = Vector3(0, 0, 0)
@export var alert_radius: float = 25.0

signal beast_incursion_started(creature: CreatureBase)
signal village_saved()

var active_threat: CreatureBase = null

func trigger_threat(creature: CreatureBase) -> void:
	active_threat = creature
	creature.is_threatening_village = true
	creature.roam_target = village_center + Vector3(randf_range(-5, 5), 0, randf_range(-5, 5))
	creature.pacified.connect(_on_threat_resolved)
	beast_incursion_started.emit(creature)
	print("[VillageDefense] Alert! A %s is approaching the village! Vader to the rescue!" % creature.creature_name)

func _on_threat_resolved(_creature: CreatureBase) -> void:
	active_threat = null
	village_saved.emit()
	print("[VillageDefense] The village is saved! Villagers celebrate and gift Vader fresh blue milk and crops!")
