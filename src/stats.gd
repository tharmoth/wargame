class_name Stats extends Resource

@export var unit_name : String = "Mysterous Stranger"
@export var items : Array[String] = []
@export var icon : Texture2D

@export var movement : int = 6
@export var fight_value : int = 4
@export var strength : int = 3
@export var defense : int = 6
@export var attacks : int = 1
@export var wounds : int = 1
@export var courage : int = 6

static func get_wound_target(strength : int, defense : int) -> int:
	if strength >= defense + 2:
		return 3
	elif strength >= defense:
		return 4
	elif strength >= defense - 2:
		return 5
	elif strength >= defense - 4:
		return 6
	else:
		printerr("Strength too different to defense finish chart!")
		return 6
