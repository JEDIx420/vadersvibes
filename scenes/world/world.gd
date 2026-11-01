extends Node3D

@onready var bgm_player: AudioStreamPlayer = $BGMPlayer
@onready var defense_event: VillageDefenseEvent = $VillageDefenseEvent
@onready var speeder_bike: SpeederBikeController = $SpeederBike if has_node("SpeederBike") else null
@onready var skiff_boat: BoatController = $SkiffBoat if has_node("SkiffBoat") else null
@onready var starship: SpaceshipController = $MountainPlateau/StarshipShuttle if has_node("MountainPlateau/StarshipShuttle") else null
@onready var massiff: CreatureBase = $Creature_Massiff if has_node("Creature_Massiff") else null

var event_timer: float = 30.0

func _ready() -> void:
	var stream = load("res://assets/audio/music/lofi_binary_sunset_acoustic.wav")
	if stream and bgm_player:
		bgm_player.stream = stream
		bgm_player.play()
	print("[PelagiaPrime] Open world initialized. Welcome home, Darth Vader!")

func _process(delta: float) -> void:
	event_timer -= delta
	if event_timer <= 0:
		event_timer = randf_range(45.0, 90.0)
		_trigger_random_wildlife_event()

func _trigger_random_wildlife_event() -> void:
	if defense_event and massiff and not massiff.is_pacified:
		defense_event.trigger_threat(massiff)
