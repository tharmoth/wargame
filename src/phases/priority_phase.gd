class_name PriorityPhase extends BasePhase

var _phases : Array = ["show", "roll", "end"]
var _current_phase : String = "duel"

func start_phase() -> void:
	_current_phase = "show"
	GUI.show_button("[Space] Roll for Priority")
	
func can_end_phase() -> bool:
	return _current_phase == "end"
	
func button_pressed() -> void:
	if _current_phase == "show":
		GUI.show_fight_gui([], [])
		_current_phase = "roll"
	elif _current_phase == "roll":
		var roll : int = Utils.roll_dice("1d6")
		GUI.show_cutoff_row([roll], 4)
		TurnManager.Instance.player1_priority = roll > 3
		_current_phase = "end"
	else:
		GUI.hide_fight_gui()
		TurnManager.end_phase()
		pass
