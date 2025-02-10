class_name GUI extends CanvasLayer

static var instance : GUI

func _enter_tree() -> void:
	instance = self

static func show_stats(stats: Array[Stats], team : String) -> void:
	instance._show_stats(stats, team)

func _show_stats(stats: Array[Stats], team : String) -> void:
	if team == "player1":
		%Player1Stats.show_stats(stats[0])
	else:
		%Player2Stats.show_stats(stats[0])
