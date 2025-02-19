extends Label

@export var player : PlayerNumber = PlayerNumber.player1
enum PlayerNumber { player1, player2 }

func _process(delta: float) -> void:
	var starting_count : int = 0
	var current_count : int = 0
	var percent_remaining : float = 0.0
	var info_text : String = ""

	if player == PlayerNumber.player1:
		info_text = "Player 1: "
		starting_count = TurnManager.Instance.battle.player_1_starting_count
		current_count = WargameUtils.get_units("player1").size()
		percent_remaining = current_count / float(starting_count)
	else:
		info_text = "Player 2: "
		starting_count = TurnManager.Instance.battle.player_2_starting_count
		current_count = WargameUtils.get_units("player2").size()
		percent_remaining = current_count / float(starting_count)

	info_text += str(current_count) + "/" + str(starting_count) + " " + str(round(percent_remaining * 100)) + "%"

	if percent_remaining <= 0.25:
		info_text += " - Quartered!"
		add_theme_color_override("font_color", Utils.BLOOD)
	elif percent_remaining <= 0.5:
		info_text += " - Broken!"
		add_theme_color_override("font_color", Color.YELLOW)
	else:
		add_theme_color_override("font_color", Utils.BLUE)


	text = info_text
