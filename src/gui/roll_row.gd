class_name RollRow extends PanelContainer

# Hardcoded Scene Import
static var scene : PackedScene = preload("res://src/gui/roll_row.tscn")

func set_message(message : String) -> void:
	%Label.text = message