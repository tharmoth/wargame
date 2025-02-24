class_name DuelRow extends PanelContainer

# Hardcoded Scene Import
static var scene : PackedScene = preload("res://src/gui/duel_row.tscn")

static var dice_textures : Array[CompressedTexture2D] = [preload("res://data/ui/die1.png"),
													preload("res://data/ui/die2.png"),
													preload("res://data/ui/die3.png"),
													preload("res://data/ui/die4.png"),
													preload("res://data/ui/die5.png"),
													preload("res://data/ui/die6.png")]

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
			play_roll_animation(team1[i], team1_dice[i], team1_highlight_color if i == team1_highlight_index else Color.WHITE)
		else:
			team1_dice[i].texture = null

		if i < team2.size():
			play_roll_animation(team2[i], team2_dice[i], team2_highlight_color if i == team2_highlight_index else Color.WHITE)
		else:
			team2_dice[i].texture = null

	%WinnerLabel.text = winner

static func play_roll_animation(roll : int, dice_texture : TextureRect, highlight_color : Color) -> void:
		
		var tween : Tween = dice_texture.create_tween()
		tween.tween_callback(func() -> void:
			dice_texture.texture = dice_textures[randi_range(0, 5)]
			)
		tween.tween_interval(.1)
		tween.tween_callback(func() -> void:
			dice_texture.texture = dice_textures[randi_range(0, 5)]
			)
		tween.tween_callback(func() -> void:
			GUI.play_audio(GUI.Sound.ROLL)
		)
		tween.tween_interval(.1)
		tween.tween_callback(func() -> void:
			dice_texture.texture = dice_textures[randi_range(0, 5)]
			)
		tween.tween_interval(.1)
		tween.tween_callback(func() -> void:
			dice_texture.texture = dice_textures[randi_range(0, 5)]
			)
		tween.tween_interval(.1)
		tween.tween_callback(func() -> void:
			dice_texture.texture = dice_textures[roll - 1]
			dice_texture.self_modulate = highlight_color
		)
