extends Node3D

@onready var bgm_player: AudioStreamPlayer = $BGMPlayer
@onready var defense_event: VillageDefenseEvent = $VillageDefenseEvent
@onready var speeder_bike: SpeederBikeController = $SpeederBike if has_node("SpeederBike") else null
@onready var skiff_boat: BoatController = $SkiffBoat if has_node("SkiffBoat") else null
@onready var starship: SpaceshipController = $MountainPlateau/StarshipShuttle if has_node("MountainPlateau/StarshipShuttle") else null
@onready var massiff: CreatureBase = $Creature_Massiff if has_node("Creature_Massiff") else null
@onready var lothwolf: CreatureBase = $Creature_LothWolf if has_node("Creature_LothWolf") else null

var event_timer: float = 25.0

func _ready() -> void:
	var stream = load("res://assets/audio/music/star_wars_force_theme.mp3")
	if stream and bgm_player:
		bgm_player.stream = stream
		bgm_player.play()
	print("[PelagiaPrime] Open world initialized. Welcome home, Darth Vader!")
	
	if defense_event:
		defense_event.beast_incursion_started.connect(_on_beast_incursion)
		defense_event.village_saved.connect(_on_village_saved)
		
	# Welcome prompt on startup
	var timer = get_tree().create_timer(1.2)
	timer.timeout.connect(func():
		var player = get_tree().get_first_node_in_group("player")
		if player and player.get("clean_hud") and player.clean_hud:
			player.clean_hud.show_interaction_prompt("🌿 Welcome to Pelagia-Prime! Walk [W] to step onto the veranda.")
	)

func _process(delta: float) -> void:
	event_timer -= delta
	if event_timer <= 0:
		event_timer = randf_range(40.0, 80.0)
		_trigger_random_wildlife_event()

func _trigger_random_wildlife_event() -> void:
	if not defense_event:
		return
	var candidate = massiff if (massiff and not massiff.is_pacified) else (lothwolf if (lothwolf and not lothwolf.is_pacified) else null)
	if candidate:
		defense_event.trigger_threat(candidate)

func _on_beast_incursion(creature: CreatureBase) -> void:
	var player = get_tree().get_first_node_in_group("player")
	if player and player.get("clean_hud") and player.clean_hud:
		player.clean_hud.show_interaction_prompt("⚠️ A wild %s is approaching the village! Use Lightsaber [F] or Force Calm [E]!" % creature.creature_name)

func _on_village_saved() -> void:
	var player = get_tree().get_first_node_in_group("player")
	if player and player.get("clean_hud") and player.clean_hud:
		player.clean_hud.show_interaction_prompt("🎉 The wild creature was pacified peacefully! The villagers celebrate!")
