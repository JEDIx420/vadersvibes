extends CharacterBody3D
class_name VaderPlayer

@export var walk_speed: float = 5.0
@export var sprint_speed: float = 8.5
@export var jump_velocity: float = 6.0
@export var rotation_speed: float = 12.0

@onready var animation_player: AnimationPlayer = $vader_rigged/AnimationPlayer if has_node("vader_rigged/AnimationPlayer") else null
@onready var state_machine: PlayerStateMachine = $PlayerStateMachine
@onready var guitar_player: GuitarAudioPlayer = $GuitarAudioPlayer
@onready var sfx_player: AudioStreamPlayer3D = $SFXPlayer
@onready var footstep_player: AudioStreamPlayer3D = $FootstepPlayer if has_node("FootstepPlayer") else null
@onready var clean_hud: CleanHUD = $CleanHUD if has_node("CleanHUD") else null

# Dynamic equipment nodes
@onready var hand_lightsaber: Node3D = $EquipmentHand/LightsaberHand
@onready var hand_guitar: Node3D = $EquipmentHand/GuitarHand
@onready var hip_lightsaber: Node3D = $EquipmentHip/LightsaberHip
@onready var back_guitar: Node3D = $EquipmentBack/GuitarBack

var gravity: float = 14.0
var is_lightsaber_drawn: bool = false
var is_holding_guitar: bool = false
var is_fishing: bool = false
var current_vehicle: Node3D = null

# Footstep sound system
var footstep_distance_accumulator: float = 0.0
const STEP_DISTANCE_WALK: float = 0.72
const STEP_DISTANCE_RUN: float = 0.52
var _footstep_sounds: Array[AudioStream] = []
var _footstep_wood_sounds: Array[AudioStream] = []
var _footstep_index: int = 0

func _ready() -> void:
	add_to_group("player")
	if state_machine:
		state_machine.init(self)
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	_setup_bone_attachments()
	_configure_animation_loops()
	_update_equipment_visuals()
	_play_anim("Idle_Casual")
	
	# Preload footstep sounds for responsive instant playback
	for i in range(1, 5):
		var p = "res://assets/audio/sfx/lego_step_%d.wav" % i
		if ResourceLoader.exists(p):
			_footstep_sounds.append(load(p))
	for i in range(1, 3):
		var p = "res://assets/audio/sfx/lego_step_wood_%d.wav" % i
		if ResourceLoader.exists(p):
			_footstep_wood_sounds.append(load(p))

func _configure_animation_loops() -> void:
	if not animation_player:
		return
	var looping_anims = ["Idle_Casual", "Walk_Minifig", "Run_Minifig", "Guitar_Strum", "Bike_Ride_Pose"]
	for a_name in looping_anims:
		if animation_player.has_animation(a_name):
			var anim = animation_player.get_animation(a_name)
			if anim:
				anim.loop_mode = Animation.LOOP_LINEAR

func _setup_bone_attachments() -> void:
	var skeleton: Skeleton3D = get_node_or_null("vader_rigged/Armature_Vader/Skeleton3D")
	if not skeleton:
		return
		
	# 1. Lightsaber Hand Socket
	var bone_hand_r = skeleton.find_bone("Socket_Hand_R")
	if bone_hand_r != -1 and hand_lightsaber:
		var attach_hand = BoneAttachment3D.new()
		attach_hand.name = "AttachHandR"
		attach_hand.bone_name = "Socket_Hand_R"
		skeleton.add_child(attach_hand)
		hand_lightsaber.reparent(attach_hand)
		hand_lightsaber.position = Vector3(0, 0, 0)
		hand_lightsaber.rotation = Vector3(0, 0, 0)
		hand_lightsaber.scale = Vector3(1.0, 1.0, 1.0)
		
	# 2. Lightsaber Hip Holster Socket (vertical sleek clip at left belt)
	var bone_hips = skeleton.find_bone("Hips")
	if bone_hips != -1 and hip_lightsaber:
		var attach_hips = BoneAttachment3D.new()
		attach_hips.name = "AttachHips"
		attach_hips.bone_name = "Hips"
		skeleton.add_child(attach_hips)
		hip_lightsaber.reparent(attach_hips)
		hip_lightsaber.position = Vector3(-0.25, -0.05, 0.0)
		hip_lightsaber.rotation = Vector3(0, 0, deg_to_rad(5))
		hip_lightsaber.scale = Vector3(1.0, 1.0, 1.0)
		
	# 3. Acoustic Guitar Back Socket (slung diagonally across back)
	var bone_back = skeleton.find_bone("Socket_Back")
	if bone_back != -1 and back_guitar:
		var attach_back = BoneAttachment3D.new()
		attach_back.name = "AttachBack"
		attach_back.bone_name = "Socket_Back"
		skeleton.add_child(attach_back)
		back_guitar.reparent(attach_back)
		back_guitar.position = Vector3(0.04, 0.10, -0.48)
		back_guitar.rotation = Vector3(deg_to_rad(6), deg_to_rad(180), deg_to_rad(-24))
		back_guitar.scale = Vector3(1.15, 1.15, 1.15)
		
	# 4. Acoustic Guitar Hand (Equipped across chest for strumming)
	var bone_torso = skeleton.find_bone("Torso")
	if bone_torso != -1 and hand_guitar:
		var attach_guitar = BoneAttachment3D.new()
		attach_guitar.name = "AttachGuitarTorso"
		attach_guitar.bone_name = "Torso"
		skeleton.add_child(attach_guitar)
		hand_guitar.reparent(attach_guitar)
		hand_guitar.position = Vector3(0.02, 0.0, 0.30)
		var b_x = Vector3(0.707, -0.707, 0.0)
		var b_y = Vector3(0.0, 0.15, 0.988).normalized()
		var b_z = b_x.cross(b_y).normalized()
		hand_guitar.transform.basis = Basis(b_x, b_y, b_z).orthonormalized()
		hand_guitar.scale = Vector3(1.15, 1.15, 1.15)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") or (event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			
	# Weapon / Prop Switching
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_F:
			_toggle_lightsaber()
		elif event.keycode == KEY_G:
			_toggle_guitar()
		elif event.keycode == KEY_0:
			_holster_all()
		elif event.keycode == KEY_C:
			_try_fishing()
			
	# Guitar strumming on keys 1-6 when guitar is active
	if is_holding_guitar:
		if event is InputEventKey and event.pressed and not event.echo:
			if event.keycode >= KEY_1 and event.keycode <= KEY_6:
				play_guitar_chord(event.keycode - KEY_1)
				
	# Context interaction (Mount vehicle / talk to neighbors)
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_E:
		_check_context_interaction()

func _physics_process(delta: float) -> void:
	if not is_inside_tree():
		return
		
	# Infinite void protection / kill plane
	if global_position.y < -5.0:
		global_position = Vector3(0.0, 1.0, 0.0)
		velocity = Vector3.ZERO
		
	if state_machine and state_machine.current_state == PlayerStateMachine.State.RIDING_BIKE:
		_process_riding_vehicle(delta, "Bike_Ride_Pose")
		if clean_hud:
			clean_hud.show_interaction_prompt("[WASD] Steer Speeder | [Shift] Repulsor Boost | [L-Click] Blasters | [E] Dismount")
		return
	elif state_machine and state_machine.current_state == PlayerStateMachine.State.SPACE_FLIGHT:
		_process_riding_vehicle(delta, "Bike_Ride_Pose")
		if clean_hud:
			clean_hud.show_interaction_prompt("[WASD] Pitch & Yaw | [Space] Thrusters | [E near ground] Land")
		return
	elif state_machine and state_machine.current_state == PlayerStateMachine.State.BOATING:
		_process_riding_vehicle(delta, "Idle_Casual")
		if clean_hud:
			clean_hud.show_interaction_prompt("[WASD] Cruise Waters | [E] Disembark Skiff")
		return

	_process_on_foot(delta)
	_update_proximity_hud()

func _process_on_foot(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= gravity * delta
	else:
		if velocity.y < 0:
			velocity.y = -0.1
			
	var jump_pressed = Input.is_key_pressed(KEY_SPACE) or Input.is_physical_key_pressed(KEY_SPACE) or Input.is_action_just_pressed("jump")
	if jump_pressed and is_on_floor():
		velocity.y = jump_velocity
		
	var input_x = 0.0
	var input_z = 0.0
	
	if Input.is_key_pressed(KEY_W) or Input.is_physical_key_pressed(KEY_W) or Input.is_action_pressed("move_forward"):
		input_z += 1.0
	if Input.is_key_pressed(KEY_S) or Input.is_physical_key_pressed(KEY_S) or Input.is_action_pressed("move_backward"):
		input_z -= 1.0
	if Input.is_key_pressed(KEY_D) or Input.is_physical_key_pressed(KEY_D) or Input.is_action_pressed("move_right"):
		input_x += 1.0
	if Input.is_key_pressed(KEY_A) or Input.is_physical_key_pressed(KEY_A) or Input.is_action_pressed("move_left"):
		input_x -= 1.0
		
	var cam = get_viewport().get_camera_3d() if (is_inside_tree() and get_viewport()) else null
	var move_dir = Vector3.ZERO
	if cam:
		var cam_forward = -cam.global_transform.basis.z
		cam_forward.y = 0.0
		cam_forward = cam_forward.normalized()
		var cam_right = cam.global_transform.basis.x
		cam_right.y = 0.0
		cam_right = cam_right.normalized()
		move_dir = (cam_right * input_x + cam_forward * input_z).normalized()
	else:
		move_dir = Vector3(input_x, 0, -input_z).normalized()
		
	var is_sprinting = Input.is_key_pressed(KEY_SHIFT) or Input.is_physical_key_pressed(KEY_SHIFT)
	var current_speed = sprint_speed if is_sprinting else walk_speed
	
	if move_dir.length() > 0.1:
		velocity.x = move_dir.x * current_speed
		velocity.z = move_dir.z * current_speed
		
		# Vader's model front faces +Z in local coordinates.
		# To align +Z with move_dir, rotation.y is atan2(move_dir.x, move_dir.z)
		var target_yaw = atan2(move_dir.x, move_dir.z)
		rotation.y = lerp_angle(rotation.y, target_yaw, rotation_speed * delta)
		
		# Footstep sound calculation
		if is_on_floor():
			var horiz_vel = Vector2(velocity.x, velocity.z).length()
			footstep_distance_accumulator += horiz_vel * delta
			var threshold = STEP_DISTANCE_RUN if is_sprinting else STEP_DISTANCE_WALK
			if footstep_distance_accumulator >= threshold:
				footstep_distance_accumulator = 0.0
				_play_footstep()
				
		if is_on_floor() and not is_holding_guitar:
			if is_sprinting:
				_play_anim("Run_Minifig")
			else:
				_play_anim("Walk_Minifig")
	else:
		velocity.x = move_toward(velocity.x, 0, current_speed * 4.0 * delta)
		velocity.z = move_toward(velocity.z, 0, current_speed * 4.0 * delta)
		footstep_distance_accumulator = 0.0
		if is_on_floor() and not is_holding_guitar:
			_play_anim("Idle_Casual")
			
	var was_in_air = !is_on_floor()
	move_and_slide()
	if was_in_air and is_on_floor() and velocity.y <= 0:
		_play_footstep()

func _play_footstep() -> void:
	if not footstep_player:
		return
	var sounds = _footstep_sounds
	# If on dock / pier or wooden veranda
	if (global_position.x < -10.0 and global_position.z > 0.0) or (global_position.x > 0.0 and global_position.x < 5.0 and global_position.z < 0.0):
		if not _footstep_wood_sounds.is_empty():
			sounds = _footstep_wood_sounds
	if sounds.is_empty():
		return
	var stream = sounds[_footstep_index % sounds.size()]
	_footstep_index += 1
	footstep_player.stream = stream
	footstep_player.pitch_scale = randf_range(0.96, 1.04)
	footstep_player.volume_db = 0.0
	footstep_player.play()

func _get_nearby_interactions() -> Array[Dictionary]:
	var results: Array[Dictionary] = []
	if not is_inside_tree() or not get_tree():
		return results
		
	# Vehicles
	for v in get_tree().get_nodes_in_group("vehicles"):
		var d = global_position.distance_to(v.global_position)
		if d < 3.8 and v.has_method("mount"):
			results.append({
				"dist": d,
				"prompt": "[E] Mount 74-Z Speeder Bike",
				"action": func(): v.mount(self)
			})
			
	# Boats
	for b in get_tree().get_nodes_in_group("boats"):
		var d = global_position.distance_to(b.global_position)
		if d < 4.5 and b.has_method("board_boat"):
			results.append({
				"dist": d,
				"prompt": "[E] Board Coastal Skiff",
				"action": func(): b.board_boat(self)
			})
			
	# Spacecraft
	for s in get_tree().get_nodes_in_group("spacecraft"):
		var d = global_position.distance_to(s.global_position)
		if d < 6.0 and s.has_method("board_ship"):
			results.append({
				"dist": d,
				"prompt": "[E] Pilot Starship Shuttle",
				"action": func(): s.board_ship(self)
			})
			
	# Villagers
	for vi in get_tree().get_nodes_in_group("villagers"):
		var d = global_position.distance_to(vi.global_position)
		if d < 3.2 and vi.has_method("interact"):
			var v_name = vi.get("villager_name") if vi.get("villager_name") else "Neighbor"
			var v_role = vi.get("role") if vi.get("role") else "Villager"
			results.append({
				"dist": d,
				"prompt": "[E] Talk to %s (%s)" % [v_name, v_role],
				"action": func(): vi.interact(self)
			})
			
	# Creatures
	for c in get_tree().get_nodes_in_group("creatures"):
		if c is CreatureBase and not c.is_pacified:
			var d = global_position.distance_to(c.global_position)
			if d < 6.0:
				results.append({
					"dist": d,
					"prompt": "[E] Use Force Calm on %s | [F] Lightsaber" % c.creature_name,
					"action": func():
						c.pacify_creature()
						_play_sfx("res://assets/audio/sfx/lego_snap.wav")
						if clean_hud:
							clean_hud.show_interaction_prompt("✨ Vader used the Force to pacify the %s peacefully!" % c.creature_name)
				})
				
	results.sort_custom(func(a, b): return a["dist"] < b["dist"])
	return results

func _update_proximity_hud() -> void:
	if not clean_hud:
		return
		
	var nearby = _get_nearby_interactions()
	if nearby.size() > 0:
		clean_hud.show_interaction_prompt(nearby[0]["prompt"])
		return
			
	# Check if near coastline/dock for fishing
	if global_position.x < -20.0 and global_position.y < 2.5:
		clean_hud.show_interaction_prompt("[C] Cast Fishing Line into Crystal Waters")
		return
		
	clean_hud.hide_interaction_prompt()

func _process_riding_vehicle(_delta: float, pose_anim: String) -> void:
	if current_vehicle:
		global_position = current_vehicle.global_position
		global_rotation = current_vehicle.global_rotation
		_play_anim(pose_anim)

func _check_context_interaction() -> void:
	var nearby = _get_nearby_interactions()
	if nearby.size() > 0:
		nearby[0]["action"].call()

func _try_fishing() -> void:
	if global_position.x < -25.0:
		_play_sfx("res://assets/audio/sfx/fishing_cast.wav")
		print("[Vader] Cast fishing line into Pelagia-Prime ocean...")
		if clean_hud:
			clean_hud.show_interaction_prompt("🎣 You caught a shimmering Pelagian Bluefin Fish!")
		var timer = get_tree().create_timer(2.5)
		timer.timeout.connect(func():
			if clean_hud:
				clean_hud.hide_interaction_prompt()
		)
	else:
		print("[Vader] Head to the coastal docks to cast your fishing line!")

func _toggle_lightsaber() -> void:
	is_lightsaber_drawn = !is_lightsaber_drawn
	is_holding_guitar = false
	_update_equipment_visuals()
	
	if is_lightsaber_drawn:
		_play_anim("Lightsaber_Flourish")
		_play_sfx("res://assets/audio/sfx/lightsaber_ignite.wav")
		print("[Vader] Drawn crimson lightsaber. Hands armed. Press F to holster.")
		if is_inside_tree() and get_tree():
			var creatures = get_tree().get_nodes_in_group("creatures")
			for c in creatures:
				if c is CreatureBase and global_position.distance_to(c.global_position) < 7.0:
					c.pacify_creature()
					_play_sfx("res://assets/audio/sfx/lego_snap.wav")
					if clean_hud:
						clean_hud.show_interaction_prompt("✨ Wild %s Pacified Non-Lethally with Lightsaber!" % c.creature_name)
	else:
		_play_anim("Idle_Casual")
		print("[Vader] Holstered lightsaber. Hands free.")

func _toggle_guitar() -> void:
	is_holding_guitar = !is_holding_guitar
	is_lightsaber_drawn = false
	_update_equipment_visuals()
	
	if is_holding_guitar:
		if state_machine:
			state_machine.transition_to(PlayerStateMachine.State.PLAYING_GUITAR)
		_play_anim("Guitar_Strum")
		print("[Vader] Equipped acoustic guitar. Press 1-6 to strum chords, G to holster.")
	else:
		if state_machine:
			state_machine.transition_to(PlayerStateMachine.State.ON_FOOT)
		_play_anim("Idle_Casual")
		print("[Vader] Holstered acoustic guitar to back. Hands free.")

func _holster_all() -> void:
	is_lightsaber_drawn = false
	is_holding_guitar = false
	_update_equipment_visuals()
	if state_machine:
		state_machine.transition_to(PlayerStateMachine.State.ON_FOOT)
	_play_anim("Idle_Casual")
	print("[Vader] Holstered all gear. Hands free.")

func _update_equipment_visuals() -> void:
	if hand_lightsaber:
		hand_lightsaber.visible = is_lightsaber_drawn
	if hip_lightsaber:
		hip_lightsaber.visible = !is_lightsaber_drawn
		
	if hand_guitar:
		hand_guitar.visible = is_holding_guitar
	if back_guitar:
		back_guitar.visible = !is_holding_guitar
		
	if clean_hud:
		clean_hud.update_gear_display(is_lightsaber_drawn, is_holding_guitar)

func play_guitar_chord(chord_idx: int) -> void:
	if guitar_player:
		guitar_player.play_chord_index(chord_idx)
	if animation_player and animation_player.has_animation("Guitar_Strum"):
		animation_player.seek(0.05, true)
		animation_player.play("Guitar_Strum")

func _play_anim(anim_name: String) -> void:
	if animation_player and animation_player.has_animation(anim_name):
		if animation_player.current_animation != anim_name:
			animation_player.play(anim_name)

func _play_sfx(path: String) -> void:
	if sfx_player:
		var stream = load(path)
		if stream:
			sfx_player.stream = stream
			sfx_player.play()
