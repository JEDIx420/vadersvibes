extends CharacterBody3D
class_name VillagerNPC

@export var villager_name: String = "Barnaby"
@export var role: String = "Pelagian Fisherman"
@export var dialogues: Array[String] = [
	"Peace is good, isn't it? Much better than all those galactic wars.",
	"The waters are teeming with Pelagian Bluefin fish today! Press [C] on the pier to fish.",
	"Whenever you ride that Speeder Bike across the coast, the sound of the repulsors is music to our ears."
]

@onready var clean_hud: CleanHUD = null

var dialogue_idx: int = 0
var is_player_nearby: bool = false

func _ready() -> void:
	add_to_group("villagers")
	add_to_group("interactables")
	
func _process(delta: float) -> void:
	var player = get_tree().get_first_node_in_group("player") if (is_inside_tree() and get_tree()) else null
	if not player:
		return
		
	var dist = global_position.distance_to(player.global_position)
	if dist < 3.2:
		is_player_nearby = true
		# Turn gently to look at player
		var look_dir = (player.global_position - global_position)
		look_dir.y = 0
		if look_dir.length() > 0.2:
			var target_yaw = atan2(look_dir.x, look_dir.z)
			rotation.y = lerp_angle(rotation.y, target_yaw, 3.0 * delta)
	else:
		is_player_nearby = false

func interact(player: CharacterBody3D) -> void:
	if not is_player_nearby:
		return
		
	var hud = player.get_node_or_null("CleanHUD")
	if not hud:
		var root_hud = get_tree().get_first_node_in_group("hud")
		if root_hud is CleanHUD:
			hud = root_hud
			
	var message = ""
	if player.get("is_holding_guitar"):
		message = "♫ %s: 'Play that chord, Vader! There's nothing sweeter than acoustic music in paradise!' [Keys 1-6 to Strum]" % villager_name
	elif dialogues.size() > 0:
		message = "💬 %s: '%s'" % [villager_name, dialogues[dialogue_idx]]
		dialogue_idx = (dialogue_idx + 1) % dialogues.size()
	else:
		message = "💬 %s: 'Good day, friend Vader!'" % villager_name
		
	print("[Villager] %s spoke to Vader." % villager_name)
	if hud and hud.has_method("show_interaction_prompt"):
		hud.show_interaction_prompt(message)
		var timer = get_tree().create_timer(4.5)
		timer.timeout.connect(func():
			if is_player_nearby and hud:
				hud.show_interaction_prompt("[E] Talk to %s (%s)" % [villager_name, role])
		)
