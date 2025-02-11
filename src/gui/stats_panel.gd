extends Node

func show_stats(stats : Stats) -> void:
	%MovementLabel.text = str(stats.movement)
	%FightValueLabel.text = str(stats.fight_value)
	%StrengthLabel.text = str(stats.strength)
	%DefenseLabel.text = str(stats.defense)
	%AttacksLabel.text = str(stats.attacks)
	%WoundsLabel.text = str(stats.wounds)
	%CourgeLabel.text = str(stats.courage)

	%NameLabel.text = stats.unit_name
	
	var item_string : String = ""
	for item : String in stats.items:
		item_string = item_string + item + ", "
	item_string = item_string.substr(0, item_string.length() - 2)
	%ItemsLabel.text = item_string
	%IconRect.texture = stats.icon
	%IconRect.texture = stats.icon
	%IconRect.texture = stats.icon
