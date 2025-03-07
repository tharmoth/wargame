class_name GUI extends CanvasLayer

static var instance : GUI

var _last_duel_row : DuelRow = null

enum Sound {
	STAB,
	MISS,
	TURN,
	WALK,
	ROLL,
	IMPACT
}

func _enter_tree() -> void:
	instance = self

static func play_audio(sound : Sound) -> void:
	instance._play_audio(sound)

static func show_message(message : String) -> void:
	instance._show_message(message)

static func show_button(message : String) -> void:
	instance._show_button(message)

static func show_fight_gui(team1 : Array[Stats], team2 : Array[Stats]) -> void:
	instance._show_fight_gui(team1, team2)

static func hide_fight_gui() -> void:
	instance._hide_fight_gui()

static func set_fight_gui_title(title : String) -> void:
	instance._set_fight_gui_title(title)

static func set_fight_gui_button_text(text : String) -> void:
	instance._set_fight_gui_button_text(text)

static func show_duel_row(team1 : Array[int], team2 : Array[int], winner : String, text : String = "Duel") -> void:
	instance._show_duel_row(team1, team2, winner, text)

static func show_cutoff_row(strike_rolls : Array[int], hit_cutoff : int) -> void:
	instance._show_strike_row(strike_rolls, hit_cutoff)

static func show_sum_row(rolls : Array[int], sum : int, cutoff : int) -> void:
	instance._show_sum_row(rolls, sum, cutoff)

static func set_current_phase(phase : String) -> void:
	instance._set_current_phase(phase)

static func show_battle_over() -> void:
	instance._show_battle_over()

static func reroll(reroll_index : int, reroll_value : int, reroll_team : String, winner : String) -> void:
	instance._last_duel_row.reroll(reroll_index, reroll_value, reroll_team, winner)

#
# Godot Methods
#
func _ready() -> void:
	%RollButton.connect("pressed", _button_pressed)
	%NextButton.connect("pressed", _button_pressed)

func _button_pressed() -> void:
	TurnManager.button_pressed()

func _process(delta : float) -> void:
	if Input.is_action_just_pressed("space"):
		programatically_press_button()

func programatically_press_button() -> void:
	if %FightGui.visible:
		%RollButton.toggle_mode = true
		%RollButton.button_pressed = true
		%RollButton.emit_signal("pressed")
		get_tree().create_timer(0.2).connect("timeout", func() -> void: 
			%RollButton.button_pressed = false 
			%RollButton.toggle_mode = false)
	else:
		%NextButton.toggle_mode = true
		%NextButton.button_pressed = true
		%NextButton.emit_signal("pressed")
		get_tree().create_timer(0.2).connect("timeout", func() -> void: 
			%NextButton.button_pressed = false
			%NextButton.toggle_mode = false)
#
# Private
#
func _play_audio(sound : Sound) -> void:
	match sound:
		Sound.STAB:
			%StabAudio.play()
		Sound.MISS:
			%MissAudio.play()
		Sound.TURN:
			%TurnAudio.play()
		Sound.WALK:
			%WalkAudio.play()
		Sound.ROLL:
			%RollAudio.play()
		Sound.IMPACT:
			%ImpactAudio.play()

func _show_message(message : String) -> void:
	var roll_row : RollRow = RollRow.scene.instantiate()
	roll_row.set_message(message)
	%RollContainer.add_child(roll_row)
	%RollContainer.move_child(roll_row, 0)

func _show_button(message : String) -> void:
	%NextButton.text = message

func _show_duel_row(team1 : Array[int], team2 : Array[int], winner : String, text : String) -> void:
	var duel_row : DuelRow = DuelRow.scene.instantiate()
	duel_row.set_message(team1, team2, winner, text)
	%RollContainer.add_child(duel_row)
	%RollContainer.move_child(duel_row, 0)
	_last_duel_row = duel_row

func _show_fight_gui(team1 : Array[Stats], team2 : Array[Stats]) -> void:
	%FightGui.visible = true
	%Player1Stats.set_hidden(team1.size() == 0)
	if team1.size() > 0:
		%Player1Stats.show_stats(team1[0])
	%Player2Stats.set_hidden(team2.size() == 0)
	if team2.size() > 0:
		%Player2Stats.show_stats(team2[0])

func _hide_fight_gui() -> void:
	%FightGui.visible = false

func _show_strike_row(strike_rolls : Array[int], hit_cutoff : int) -> void:
	var strike_row : StrikelRow = StrikelRow.scene.instantiate()
	strike_row.set_cutoff_message(strike_rolls, hit_cutoff)
	%RollContainer.add_child(strike_row)
	%RollContainer.move_child(strike_row, 0)

func _show_sum_row(rolls : Array[int], sum : int, cutoff : int) -> void:
	var sum_row : StrikelRow = StrikelRow.scene.instantiate()
	sum_row.set_sum_message(rolls, sum, cutoff)
	%RollContainer.add_child(sum_row)
	%RollContainer.move_child(sum_row, 0)

func _set_current_phase(phase : String) -> void:
	%PhaseGui.set_current_phase(phase)

func _show_battle_over() -> void:
	%BattleCompleteGui.show()

func _set_fight_gui_title(title : String) -> void:
	%FightGuiTitleLabel.text = title

func _set_fight_gui_button_text(text : String) -> void:
	%RollButton.text = text