extends HBoxContainer


func set_current_phase(phase : String) -> void:
	%CourageLabel.remove_theme_color_override("font_color")
	%MovementLabel.remove_theme_color_override("font_color")
	%ShootingLabel.remove_theme_color_override("font_color")
	%FightLabel.remove_theme_color_override("font_color")
	match phase:
		"courage":
			%ActionLabel.text = "- Activate a unit to rally -"
			%CourageLabel.add_theme_color_override("font_color", Utils.BLUE)
		"movement":
			%ActionLabel.text = "- Activate a unit to move -"
			%MovementLabel.add_theme_color_override("font_color", Utils.BLUE)
		"shooting":
			%ActionLabel.text = "- Activate a unit to shoot -"
			%ShootingLabel.add_theme_color_override("font_color", Utils.BLUE)
		"fight":
			%ActionLabel.text = "- Activate a unit to fight -"
			%FightLabel.add_theme_color_override("font_color", Utils.BLUE)
		"cleanup":
			%ActionLabel.text = "- End of turn -"
			%FightLabel.add_theme_color_override("font_color", Utils.BLUE)
		"support":
			%ActionLabel.text = "- Activate a unit to support -"
			%FightLabel.add_theme_color_override("font_color", Utils.BLUE)
		"pair":
			%ActionLabel.text = "- Activate a unit to choose opponants -"
			%FightLabel.add_theme_color_override("font_color", Utils.BLUE)