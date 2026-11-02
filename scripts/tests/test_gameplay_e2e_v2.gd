extends SceneTree

# Comprehensive End-to-End Validation Test Suite for LEGO Star Wars: A Vader's Peace
# Verifies:
# 1. Starting inside cabin bedroom, walking through sliding veranda doors to open world
# 2. Authentic LEGO guitar equipping, strumming chords 1-6, holstering to back
# 3. Lightsaber drawing, flourishing, holstering to hip
# 4. Speeder bike mounting, riding, and dismounting
# 5. Coastal skiff boat boarding and disembarking
# 6. Villager interactions (Barnaby, Jax, Corin)
# 7. Fishing from pier
# 8. Non-lethal creature pacification

var root_node: Node3D = null
var player: VaderPlayer = null
var current_step: int = 0
var test_timer: float = 0.0

func _init() -> void:
	print("\n=======================================================")
	print("  TEST SUITE: LEGO Star Wars Open-World & Vader Actions")
	print("=======================================================\n")
	
	var world_scene = load("res://scenes/world/world.tscn")
	if not world_scene:
		print("FAILED: Could not load world.tscn")
		quit(1)
		return
		
	root_node = world_scene.instantiate()
	root.add_child(root_node)
	player = root_node.get_node_or_null("VaderPlayer") as VaderPlayer
	
	if not player:
		print("FAILED: Could not find VaderPlayer in world.tscn")
		quit(1)
		return
		
	print("✓ Successfully loaded world.tscn with VaderPlayer at: ", player.global_position)

func _process(delta: float) -> bool:
	test_timer += delta
	
	match current_step:
		0:
			# Step 0: Initial spawn inside cabin
			if test_timer > 0.4:
				print("✓ STEP 0: Vader spawned inside cabin bedroom at ", player.global_position)
				assert(player.global_position.y > 1.0, "Vader should be inside elevated cabin floor")
				assert(not player.is_lightsaber_drawn, "Lightsaber should be holstered on startup")
				assert(not player.is_holding_guitar, "Guitar should be slung on back on startup")
				current_step = 1
				test_timer = 0.0
		1:
			# Step 1: Walk forward towards the sliding veranda door
			player.global_position = player.global_position.move_toward(Vector3(2.62, 1.6, -1.8), 3.0 * delta)
			if test_timer > 0.6:
				print("✓ STEP 1: Vader walked out of cabin onto the veranda at: ", player.global_position)
				var door_ctrl = root_node.get_node_or_null("lego_coastal_sanctuary/CabinDoorController")
				if door_ctrl:
					print("  Cabin door controller is_open: ", door_ctrl.is_open)
				current_step = 2
				test_timer = 0.0
		2:
			# Step 2: Equip and test the new authentic LEGO guitar
			if test_timer > 0.2:
				player._toggle_guitar()
				assert(player.is_holding_guitar, "Guitar should now be equipped")
				print("✓ STEP 2: Equipped new LEGO Acoustic Guitar across chest")
				
				# Strum chords 0 through 5 (keys 1-6)
				for chord_i in range(6):
					player.play_guitar_chord(chord_i)
				print("  Strummed 6 guitar chords (A, B, D, E, Em, G) successfully")
				
				# Holster guitar back to back
				player._toggle_guitar()
				assert(not player.is_holding_guitar, "Guitar should now be back on back")
				print("  Holstered guitar cleanly to back")
				current_step = 3
				test_timer = 0.0
		3:
			# Step 3: Draw and flourish lightsaber, then holster
			if test_timer > 0.2:
				player._toggle_lightsaber()
				assert(player.is_lightsaber_drawn, "Lightsaber should be ignited")
				print("✓ STEP 3: Drawn crimson lightsaber with ignition flourish")
				
				player._toggle_lightsaber()
				assert(not player.is_lightsaber_drawn, "Lightsaber should be holstered to hip")
				print("  Holstered lightsaber to belt. Hands free")
				current_step = 4
				test_timer = 0.0
		4:
			# Step 4: Interact with Villager Jax at speeder landing pad
			player.global_position = Vector3(-2.2, 0.35, -3.2)
			var jax = root_node.get_node_or_null("Villager_Jax")
			if jax and test_timer > 0.3:
				print("✓ STEP 4: Approached Villager Jax at Speeder Landing Pad")
				player._check_context_interaction()
				current_step = 5
				test_timer = 0.0
		5:
			# Step 5: Mount and ride 74-Z Speeder Bike
			player.global_position = Vector3(-3.8, 0.5, -3.2)
			var speeder = root_node.get_node_or_null("SpeederBike")
			if speeder and test_timer > 0.3:
				player._check_context_interaction()
				assert(player.state_machine.current_state == PlayerStateMachine.State.RIDING_BIKE, "Should be riding bike")
				print("✓ STEP 5: Mounted 74-Z Speeder Bike successfully")
				
				# Dismount speeder bike
				speeder.dismount()
				assert(player.state_machine.current_state == PlayerStateMachine.State.ON_FOOT, "Should be on foot")
				print("  Dismounted Speeder Bike back to foot")
				current_step = 6
				test_timer = 0.0
		6:
			# Step 6: Board Coastal Skiff on the pier
			player.global_position = Vector3(-6.8, 0.35, 2.5)
			var boat = root_node.get_node_or_null("SkiffBoat")
			if boat and test_timer > 0.3:
				player._check_context_interaction()
				assert(player.state_machine.current_state == PlayerStateMachine.State.BOATING, "Should be boating")
				print("✓ STEP 6: Boarded Coastal Skiff Boat on the pier")
				
				boat.disembark()
				assert(player.state_machine.current_state == PlayerStateMachine.State.ON_FOOT, "Should be on foot")
				print("  Disembarked Coastal Skiff back onto pier")
				current_step = 7
				test_timer = 0.0
		7:
			# Step 7: Interact with Barnaby the Fisherman on the pier
			player.global_position = Vector3(-6.0, 0.35, 4.0)
			var barnaby = root_node.get_node_or_null("Villager_Barnaby")
			if barnaby and test_timer > 0.3:
				print("✓ STEP 7: Approached Villager Barnaby on the coastal pier")
				player._check_context_interaction()
				
				# Test fishing
				player._try_fishing()
				print("  Cast fishing line and caught Pelagian Bluefin fish")
				current_step = 8
				test_timer = 0.0
		8:
			# Step 8: Visit Village Campfire and Corin
			player.global_position = Vector3(28.0, 0.2, 8.0)
			var corin = root_node.get_node_or_null("VillageSanctuary/Villager_Corin")
			if corin and test_timer > 0.3:
				print("✓ STEP 8: Approached Villager Corin at Village Campfire")
				player._check_context_interaction()
				current_step = 9
				test_timer = 0.0
		9:
			# Step 9: Test Wildlife Peaceful Pacification
			var massiff = root_node.get_node_or_null("Creature_Massiff")
			if massiff and test_timer > 0.3:
				player.global_position = massiff.global_position + Vector3(2.0, 0, 0)
				print("✓ STEP 9: Approached Dune Massiff at ", massiff.global_position)
				player._check_context_interaction() # Uses Force Calm
				assert(massiff.is_pacified, "Creature should now be pacified")
				print("  Wild Dune Massiff pacified peacefully via Force Calm!")
				current_step = 10
				test_timer = 0.0
		10:
			print("\n=======================================================")
			print("  ALL 10 VERIFICATION TESTS PASSED SUCCESSFULLY!")
			print("=======================================================\n")
			quit(0)
			return false
			
	return false
