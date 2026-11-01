extends Node
class_name PlayerStateMachine

enum State {
	ON_FOOT,
	RIDING_BIKE,
	BOATING,
	SPACE_FLIGHT,
	PLAYING_GUITAR,
	FISHING,
	COMBAT
}

var current_state: State = State.ON_FOOT
var player: CharacterBody3D

signal state_changed(new_state: State)

func init(p_player: CharacterBody3D) -> void:
	player = p_player

func transition_to(new_state: State) -> void:
	if current_state == new_state:
		return
	current_state = new_state
	state_changed.emit(current_state)
