extends BasePhase
class_name CouragePhase

# Private Variables
var _units_to_check : Array[Unit] = []
var _selected_unit : Unit = null

var _phases : Array = ["Roll", "End"]
var _current_phase : String = "Roll"
var _sum : int = 0

func start_phase() -> void:
	GUI.show_button("[Space] Skip Phase")
	_current_phase = "Roll"
	_units_to_check = []
	var units : Array[Unit] = WargameUtils.get_units(team)
	var starting_count : int = TurnManager.Instance.battle.player_1_starting_count if team == "player1" else TurnManager.Instance.battle.player_2_starting_count
	if units.size() <= starting_count * 0.5:
		for unit : Unit in units:
			_units_to_check.append(unit)
		_activate_units()
	else:
		TurnManager.end_phase()

func can_end_phase() -> bool:
	return _units_to_check.is_empty()

func end_phase() -> void:
	for unit : Unit in _units_to_check:
		unit.activated()

func mouse_over(unit : Unit) -> void:
	if unit in _units_to_check:
		unit.highlight()

func mouse_exit(unit : Unit) -> void:
	unit.unhighlight()

func mouse_pressed(global_position : Vector2) -> void:
	var map_position : Vector2i = SKTileMap.Instance.global_to_map(global_position)
	var unit : Unit = SKTileMap.Instance.get_entity_at_position(map_position)
	if unit in _units_to_check:
		GUI.show_fight_gui([unit.stats], [])

		# Pause Here and display on gui until space pressed
		GUI.show_button("[Space] Roll to Rally")
		_selected_unit = unit

func button_pressed() -> void:
	if _selected_unit != null:
		if _current_phase == "Roll":
			var roll1 : int = Utils.roll_dice("1d6")
			var roll2 : int = Utils.roll_dice("1d6")
			_sum = roll1 + roll2
			
			_units_to_check.remove_at(_units_to_check.find(_selected_unit))
			_selected_unit.activated()
			GUI.show_sum_row([roll1, roll2], _sum, _selected_unit.stats.courage)
			_current_phase = "End"
		else:
			if _sum < _selected_unit.stats.courage:
				_selected_unit.flee()
			GUI.hide_fight_gui()
			if _units_to_check.is_empty():
				TurnManager.end_phase()
			_current_phase = "Roll"
			_selected_unit = null
	elif _units_to_check.is_empty():
		TurnManager.end_phase()
	else:
		_selected_unit = _units_to_check[0]
		GUI.show_fight_gui([_selected_unit.stats], [])

func _activate_units() -> void:
	for unit : Unit in _units_to_check:
		unit.can_activate()
