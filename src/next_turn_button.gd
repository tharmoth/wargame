class_name TurnManager extends Button

var current_phase : String = ""
var phases : Array[String]  = ["Player 1 Movement", "Player 2 Movement", "Pair Off", "Fight"]

static var Instance : TurnManager
func _enter_tree() -> void:
	Instance = self
	
static func get_current_phase() -> String:
	return Instance.current_phase

func _pressed() -> void:
	var units = get_tree().get_nodes_in_group("unit")
	for unit : Unit in units:
		unit.end_phase()
		
	var current_index : int = phases.find(current_phase)
	if current_index == len(phases) - 1:
		current_index = 0
	else:
		current_index += 1
	current_phase = phases[current_index]
	
	if current_phase == "Player 1 Movement" or current_phase == "":
		for unit : Unit in units:
			if unit.team == "player1":
				unit.start_movement()
	elif current_phase == "Player 2 Movement":
		for unit : Unit in units:
			if unit.team == "player2":
				unit.start_movement()
	elif current_phase == "Pair Off":
		for unit : Unit in units:
			if unit.team == "player1":
				unit.pair_off()
	elif current_phase == "Fight":
		for unit : Unit in units:
			unit.start_fight()
	
	%PhaseLabel.text = current_phase
