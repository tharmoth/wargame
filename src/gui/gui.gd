class_name GUI extends CanvasLayer

static var instance : GUI

func _enter_tree() -> void:
	instance = self

static func show_message(message : String) -> void:
	instance._show_message(message)

func _show_message(message : String) -> void:
	var roll_row : RollRow = RollRow.scene.instantiate()
	roll_row.set_message(message)
	%RollContainer.add_child(roll_row)
	%RollContainer.move_child(roll_row, 0)

static func show_button(message : String) -> void:
	instance._show_button(message)

func _show_button(message : String) -> void:
	pass

static func show_fight_gui(team1 : Array[Stats], team2 : Array[Stats]) -> void:
	instance._show_fight_gui(team1, team2)

func _show_fight_gui(team1 : Array[Stats], team2 : Array[Stats]) -> void:
	%FightGui.visible = true
	%Player1Stats.show_stats(team1[0])
	%Player2Stats.show_stats(team2[0])

static func hide_fight_gui() -> void:
	instance._hide_fight_gui()

func _hide_fight_gui() -> void:
	%FightGui.visible = false

static func show_duel_row(team1 : Array[int], team2 : Array[int], winner : String, team1_highlight_index : int, team2_highlight_index : int) -> void:
	instance._show_duel_row(team1, team2, winner, team1_highlight_index, team2_highlight_index)

func _show_duel_row(team1 : Array[int], team2 : Array[int], winner : String, team1_highlight_index : int, team2_highlight_index : int) -> void:
	var duel_row : DuelRow = DuelRow.scene.instantiate()
	duel_row.set_message(team1, team2, winner, team1_highlight_index, team2_highlight_index)
	%RollContainer.add_child(duel_row)
	%RollContainer.move_child(duel_row, 0)

static func show_strike_row(strike_rolls : Array[int], hit_cutoff : int) -> void:
	instance._show_strike_row(strike_rolls, hit_cutoff)

func _show_strike_row(strike_rolls : Array[int], hit_cutoff : int) -> void:
	var strike_row : StrikelRow = StrikelRow.scene.instantiate()
	strike_row.set_message(strike_rolls, hit_cutoff)
	%RollContainer.add_child(strike_row)
	%RollContainer.move_child(strike_row, 0)

#
# Godot Methods
#
func _ready() -> void:
	%RollButton.connect("pressed", _button_pressed)

func _button_pressed() -> void:
	print("Button Pressed")
	var audio : AudioStreamPlayer2D = %DiceRoll
	audio.play()
	TurnManager.button_pressed()