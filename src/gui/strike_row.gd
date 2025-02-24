class_name StrikelRow extends PanelContainer

# Hardcoded Scene Import
static var scene : PackedScene = preload("res://src/gui/strike_row.tscn")

static var dice_textures : Array[CompressedTexture2D] = [preload("res://data/ui/die1.png"),
													preload("res://data/ui/die2.png"),
													preload("res://data/ui/die3.png"),
													preload("res://data/ui/die4.png"),
													preload("res://data/ui/die5.png"),
													preload("res://data/ui/die6.png")]

func set_sum_message(strike_rolls: Array[int], sum : int, hit_cutoff : int) -> void:
	%ToHitLabel.text = "Rally " + str(hit_cutoff) + "+"

	for i : int in range(len(strike_rolls)):
		var dice_texture : TextureRect = TextureRect.new()
		dice_texture.custom_minimum_size = Vector2(30, 30)
		dice_texture.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL

		%DieContainer.add_child(dice_texture)

		DuelRow.play_roll_animation(strike_rolls[i], dice_texture, Utils.BLUE if sum >= hit_cutoff else Color.WHITE)

	var count : int = 0
	for roll : int in strike_rolls:
		if roll >= hit_cutoff:
			count += 1

	if sum >= hit_cutoff:
		%CountLabel.text = str(sum) + ">=" + str(hit_cutoff) + " (" + str(count) + ")"
	else:
		%CountLabel.text = str(sum) + "<" + str(hit_cutoff) + " (" + str(count) + ")"


func set_cutoff_message(strike_rolls: Array[int], hit_cutoff : int) -> void:	
	%ToHitLabel.text = "Strike " + str(hit_cutoff) + "+"

	for i : int in range(len(strike_rolls)):
		var dice_texture : TextureRect = TextureRect.new()
		dice_texture.custom_minimum_size = Vector2(30, 30)
		dice_texture.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL

		%DieContainer.add_child(dice_texture)
		DuelRow.play_roll_animation(strike_rolls[i], dice_texture, Utils.BLUE if strike_rolls[i] >= hit_cutoff else Color.WHITE)

	var count : int = 0
	for roll : int in strike_rolls:
		if roll >= hit_cutoff:
			count += 1

	%CountLabel.text = str(count) + "/" + str(strike_rolls.size())


