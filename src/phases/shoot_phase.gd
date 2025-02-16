extends BasePhase

class_name ShootPhase

# Public Variables

# Private Variables
var _units_to_shoot : Array[Unit] = []
var _selected_unit : Unit = null
var _target : Unit = null
var _current_phase : String = "Shoot"
var _rolls : Array[int] = []

func start_phase() -> void:
	_units_to_shoot = []
	var units : Array[Unit] = WargameUtils.get_units(team)
	
	for unit : Unit in units:
		if "bow" in unit.stats.items:
			_units_to_shoot.append(unit)
			unit.can_activate()

	if _units_to_shoot.is_empty():
		TurnManager.end_phase()

	_current_phase = "Aim"

func end_phase() -> void:
	WargameUtils.deactivate_units()


func mouse_over(unit : Unit) -> void:
	if unit in _units_to_shoot:
		unit.highlight()

func mouse_exit(unit : Unit) -> void:
	unit.unhighlight()

func button_pressed() -> void:
	if _current_phase == "Shoot":
		_shoot(_selected_unit, _target)
		
		# Check to see if any hit
		var found : bool = false
		for roll : int in _rolls:
			if roll >= 3:
				found = true
		if not found:
			_current_phase = "End"
		else:
			_current_phase = "Strike"
	elif _current_phase == "Strike":
		_current_phase = "End"
		_deal_strikes([_selected_unit], [_target])
	elif _current_phase == "End":
		_selected_unit.activated()
		_selected_unit.deselect()
		_selected_unit = null
		_target = null
		
		
		GUI.hide_fight_gui()
		_current_phase = "Aim"

		WargameUtils.deactivate_units()
		for unit : Unit in _units_to_shoot:
			unit.can_activate()

		if _units_to_shoot.is_empty():
			TurnManager.end_phase()


func mouse_pressed(global_position : Vector2) -> void:
	if _current_phase != "Aim":
		return
	var map_position : Vector2i = SKTileMap.Instance.global_to_map(global_position)
	var unit_clicked : Unit = SKTileMap.Instance.get_entity_at_position(map_position)
	if _selected_unit == null:
		if unit_clicked in _units_to_shoot:
			unit_clicked.select()
			_selected_unit = unit_clicked
			
			var targetable_units : Array[Unit] = _get_valid_shooting_units(_selected_unit)

			WargameUtils.deactivate_units()

			for targetable_unit : Unit in targetable_units:
				targetable_unit.can_activate()

	elif unit_clicked != null and unit_clicked.activate_outline._highlight:
		if unit_clicked != null and unit_clicked.team != _selected_unit.team:
			_target = unit_clicked
			GUI.show_fight_gui([_selected_unit.stats], [unit_clicked.stats])
			GUI.show_button("[Space] Roll to Shoot")
			_units_to_shoot.remove_at(_units_to_shoot.find(_selected_unit))
			_current_phase = "Shoot"

func _get_valid_shooting_units(unit : Unit) -> Array[Unit]:
	var valid_units : Array[Unit] = []
	for tile : Vector2i in SKTileMap.Instance.get_tiles_in_radius(unit.get_map_position(), 24):
		var entity : Unit = SKTileMap.Instance.get_entity_at_position(tile)
		if entity != null and entity.team != unit.team and not unit.is_in_melee():
			valid_units.append(entity)
	return valid_units

func _shoot(shooter : Unit, target : Unit) -> void:
	var roll : int = Utils.roll_dice("1d6")
	# var cutoff : int = Stats.get_shoot_target(shooter.stats.shoot, target.stats.defense)
	var cutoff : int = 3
	_rolls = [roll]
	GUI.show_strike_row(_rolls, cutoff)

func _deal_strikes(winners : Array[Unit], losers : Array[Unit]) -> void:
	var units_to_strike_with : Array[Unit] = winners
	var rolls : Array[int] = []
	var cutoff : int = 3
	for unit : Unit in units_to_strike_with:
		if losers.is_empty():
			break
		var loser : Unit = losers[0]
		var defense : int = loser.stats.defense
		var strength : int = unit.stats.strength
		cutoff = Stats.get_wound_target(strength, defense)
		var roll : int = Utils.roll_dice("1d6")
		rolls.append(roll)
		
		if roll >= cutoff:
			loser.stats.wounds = loser.stats.wounds - 1
			if loser.stats.wounds <= 0:
				losers.remove_at(losers.find(loser))
				loser.kill()

	GUI.show_strike_row(rolls, cutoff)
	# GUI.show_shoot_result(shooter, target, roll, cutoff)
