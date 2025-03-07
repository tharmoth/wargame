class_name DuelRow extends PanelContainer

# Hardcoded Scene Import
static var scene : PackedScene = preload("res://src/gui/duel_row.tscn")

static var dice_textures : Array[CompressedTexture2D] = [preload("res://data/ui/die1.png"),
													preload("res://data/ui/die2.png"),
													preload("res://data/ui/die3.png"),
													preload("res://data/ui/die4.png"),
													preload("res://data/ui/die5.png"),
													preload("res://data/ui/die6.png")]

var _team1: Array[int]
var _team2 : Array[int]

func reroll(reroll_index : int, reroll_value : int, reroll_team : String, winner : String) -> void:
	var team1_dice : Array[TextureRect] = [%Die1, %Die2, %Die3, %Die4, %Die5]
	var team2_dice : Array[TextureRect] = [%Die1_2, %Die2_2, %Die3_2, %Die4_2, %Die5_2]
	
	if reroll_team == "player1":
		play_roll_animation(reroll_value, team1_dice[reroll_index])
		_team1[reroll_index] = reroll_value
	else:
		play_roll_animation(reroll_value, team2_dice[reroll_index])
		_team2[reroll_index] = reroll_value

	color_dice(winner)
	%WinnerLabel.text = winner
		
func set_message(team1: Array[int], team2 : Array[int], winner : String, text : String) -> void:
	var team1_dice : Array[TextureRect] = [%Die1, %Die2, %Die3, %Die4, %Die5]
	var team2_dice : Array[TextureRect] = [%Die1_2, %Die2_2, %Die3_2, %Die4_2, %Die5_2]

	_team1 = team1
	_team2 = team2

	for i : int in range(team1_dice.size()):
		if i < team1.size():
			play_roll_animation(team1[i], team1_dice[i])
		else:
			team1_dice[i].texture = null

		if i < team2.size():
			play_roll_animation(team2[i], team2_dice[i])
		else:
			team2_dice[i].texture = null

	color_dice(winner)
	%WinnerLabel.text = winner
	%ActionLabel.text = text

func color_dice(winner : String) -> void:
	var team1_dice : Array[TextureRect] = [%Die1, %Die2, %Die3, %Die4, %Die5]
	var team2_dice : Array[TextureRect] = [%Die1_2, %Die2_2, %Die3_2, %Die4_2, %Die5_2]

	var team1_highlight_index : int = _team1.find(_get_max_roll(_team1))
	var team2_highlight_index : int = _team2.find(_get_max_roll(_team2))
	
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

	for i : int in range(team1_dice.size()):
		if i < _team1.size():
			team1_dice[i].self_modulate = Color.WHITE
			delay_recolor(team1_dice[i], team1_highlight_color if i == team1_highlight_index else Color.WHITE)
		if i < _team2.size():
			team2_dice[i].self_modulate = Color.WHITE
			delay_recolor(team2_dice[i], team2_highlight_color if i == team2_highlight_index else Color.WHITE)

static func play_roll_animation(roll : int, dice_texture : TextureRect, color : Color = Color.CHARTREUSE) -> void:
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
			if color != Color.CHARTREUSE:
				dice_texture.self_modulate = color
		)

static func delay_recolor(dice_texture : TextureRect, color : Color) -> void:
	var tween : Tween = dice_texture.create_tween()
	tween.tween_interval(.41)
	tween.tween_callback(func() -> void:
		dice_texture.self_modulate = color
		)
	

static func _get_max_roll(rolls : Array[int]) -> int:
	var max_roll : int = -1
	for roll : int in rolls:
		max_roll = max(max_roll, roll)
	return max_roll