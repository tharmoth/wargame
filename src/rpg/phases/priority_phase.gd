class_name PriorityPhase extends BasePhase

var _phases : Array = ["show", "roll", "end"]
var _current_phase : String = "show"

func start_phase() -> void:
	_current_phase = "show"
	GUI.show_button("[Space] Roll for Priority")
	
func can_end_phase() -> bool:
	return _current_phase == "end"
	
func button_pressed() -> void:
	if _current_phase == "show":
		GUI.set_fight_gui_title("Priority Roll")
		GUI.show_button("[Space] Roll")
		GUI.show_fight_gui([], [])
		_current_phase = "roll"
	elif _current_phase == "roll":
		var player1_roll : int = Utils.roll_dice("1d6")
		var player2_roll : int = Utils.roll_dice("1d6")

		var winner : String = "player1" if player1_roll >= player2_roll else "player2"

		GUI.show_duel_row([player1_roll], [player2_roll], winner, "Priority")

		TurnManager.Instance.player1_priority = player1_roll >= player2_roll
		_current_phase = "end"
	else:
		GUI.hide_fight_gui()
		TurnManager.end_phase()
		pass
