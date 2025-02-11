class_name DuelRow extends PanelContainer

# Hardcoded Scene Import
static var scene : PackedScene = preload("res://src/gui/duel_row.tscn")

func set_message(team1: Array[int], team2 : Array[int], winner : String, team1_highlight_index : int, team2_highlight_index : int) -> void:	
	var team1_highlight_color : Color
	var team2_highlight_color : Color
	if winner == "player1":
		team1_highlight_color = Utils.BLUE
		team2_highlight_color = Utils.RED
	elif winner == "player2":
		team1_highlight_color = Utils.RED
		team2_highlight_color = Utils.BLUE
	else:
		team1_highlight_color = Utils.BLUE
		team2_highlight_color = Utils.BLUE

	var team1_dice : Array[TextureRect] = [%Die1, %Die2, %Die3, %Die4, %Die5]
	var team2_dice : Array[TextureRect] = [%Die1_2, %Die2_2, %Die3_2, %Die4_2, %Die5_2]

	for i : int in range(5):
		if i < team1.size():
			team1_dice[i].texture = load("res://data/ui/die" + str(team1[i]) + ".png")
			if i == team1_highlight_index:
				team1_dice[i].modulate = team1_highlight_color
			else:
				team1_dice[i].modulate = Color.WHITE
		else:
			team1_dice[i].texture = null

		if i < team2.size():
			team2_dice[i].texture = load("res://data/ui/die" + str(team2[i]) + ".png")
			if i == team2_highlight_index:
				team2_dice[i].modulate = team2_highlight_color
			else:
				team2_dice[i].modulate = Color.WHITE
		else:
			team2_dice[i].texture = null

	%WinnerLabel.text = winner