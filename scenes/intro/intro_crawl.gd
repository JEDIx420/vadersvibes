extends Node3D

@onready var crawl_text_3d: Label3D = $CrawlOrigin/CrawlLabel3D
@onready var intro_blue_label: Label = $CanvasLayer/BlueIntroLabel
@onready var audio_player: AudioStreamPlayer = $AudioStreamPlayer
@onready var camera: Camera3D = $Camera3D

var crawl_speed: float = 0.85
var elapsed: float = 0.0
var has_started_fanfare: bool = false

var crawl_story = """EPISODE X

A VADER'S PEACE

The dark path had barely begun when DARTH VADER looked into the galactic abyss and chose another destiny.

Turning his back on EMPEROR PALPATINE and the destructive civil war, the former Sith apprentice fled into uncharted space aboard a prototype starfighter.

Seeking sanctuary from endless conflict, he arrived on PELAGIA-PRIME—a hidden paradise planet shielded by an ancient orbital barrier that keeps all galactic wars at bay.

Here, in a tranquil haven of diverse biomes and eccentric LEGO friends, Vader has traded conquest for an acoustic guitar, finding joy in simple days: riding speeder bikes through sunlit canyons, fishing crystal coastal waters, and living at peace with his neighbors..."""

func _ready() -> void:
	if crawl_text_3d:
		crawl_text_3d.text = crawl_story
		crawl_text_3d.position.y = -4.0
		crawl_text_3d.visible = false
	if intro_blue_label:
		intro_blue_label.visible = true
		intro_blue_label.modulate.a = 0.0

func _process(delta: float) -> void:
	elapsed += delta
	
	if Input.is_key_pressed(KEY_SPACE) or Input.is_key_pressed(KEY_ENTER) or Input.is_action_just_pressed("ui_accept"):
		transition_to_world()
		return
		
	if elapsed < 3.5:
		if intro_blue_label:
			if elapsed < 1.0:
				intro_blue_label.modulate.a = elapsed
			elif elapsed > 2.5:
				intro_blue_label.modulate.a = max(0.0, (3.5 - elapsed))
	else:
		if intro_blue_label and intro_blue_label.visible:
			intro_blue_label.visible = false
			
		if not has_started_fanfare:
			has_started_fanfare = true
			if crawl_text_3d:
				crawl_text_3d.visible = true
			var stream = load("res://assets/audio/music/intro_crawl_fanfare.wav")
			if stream and audio_player:
				audio_player.stream = stream
				audio_player.play()
				
		if crawl_text_3d:
			crawl_text_3d.position.y += crawl_speed * delta
			
		if elapsed > 24.0:
			transition_to_world()

func transition_to_world() -> void:
	set_process(false)
	var tween = create_tween()
	if audio_player:
		tween.tween_property(audio_player, "volume_db", -35.0, 0.8)
	tween.tween_callback(func():
		get_tree().change_scene_to_file("res://scenes/world/world.tscn")
	)
