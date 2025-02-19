class_name StrikelRow extends PanelContainer

# Hardcoded Scene Import
static var scene : PackedScene = preload("res://src/gui/strike_row.tscn")

func set_sum_message(strike_rolls: Array[int], sum : int, hit_cutoff : int) -> void:
	%ToHitLabel.text = "Rally " + str(hit_cutoff) + "+"

	for i : int in range(len(strike_rolls)):
		var dice_texture : TextureRect = TextureRect.new()
		dice_texture.custom_minimum_size = Vector2(30, 30)
		dice_texture.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
		dice_texture.texture = load("res://data/ui/die" + str(strike_rolls[i]) + ".png")
		if sum >= hit_cutoff:
			dice_texture.self_modulate = Utils.BLUE
		else:
			dice_texture.self_modulate = Color.WHITE
		%DieContainer.add_child(dice_texture)

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
		dice_texture.texture = load("res://data/ui/die" + str(strike_rolls[i]) + ".png")
		if strike_rolls[i] >= hit_cutoff:
			dice_texture.self_modulate = Utils.BLUE
		else:
			dice_texture.self_modulate = Color.WHITE
		%DieContainer.add_child(dice_texture)

	var count : int = 0
	for roll : int in strike_rolls:
		if roll >= hit_cutoff:
			count += 1

	%CountLabel.text = str(count) + "/" + str(strike_rolls.size())