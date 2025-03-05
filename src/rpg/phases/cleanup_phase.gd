class_name CleanupPhase extends BasePhase

var is_complete : bool = false

func can_end_phase() -> bool:
	return not is_complete

func end_phase() -> void:
	for unit : Unit in WargameUtils.get_units():
		unit.activated()

# Check for if either army has 25% or less of their units left
func start_phase() -> void:
	var player_1_starting_units : int = TurnManager.Instance.battle.player_1_starting_count
	var player_2_starting_units : int = TurnManager.Instance.battle.player_2_starting_count
	var player_1_current_units : int = WargameUtils.get_units("player1").size()
	var player_2_current_units : int = WargameUtils.get_units("player2").size()

	TurnManager.Instance.battle.player_1_broken = player_1_current_units <= player_1_starting_units * 0.5
	TurnManager.Instance.battle.player_2_broken = player_2_current_units <= player_2_starting_units * 0.5

	if player_1_current_units <= player_1_starting_units * 0.25:
		is_complete = true
		TurnManager.end_battle()
	elif player_2_current_units <= player_2_starting_units * 0.25:
		is_complete = true
		TurnManager.end_battle()
	else:
		TurnManager.end_phase()
	
