extends BasePhase
class_name SupportPhase

# Public Variables
var get_combats : Callable
# Private Variables
var _units_to_pair : Array[Unit] = []
var _selected_unit : Unit = null
var _combats : Array[Array] = []
var _combat_supporters : Dictionary = {}

func get_supports() -> Dictionary:
	return _combat_supporters

func start_phase() -> void:
	_combats = get_combats.call()
	_combat_supporters = {}
	
	var units : Array[Unit] = WargameUtils.get_units(team)
	var with_spears : Array[Unit] = WargameUtils.get_units_with_item(units, "spear")
	var not_in_combat : Array[Unit] = _get_units_not_in_combat(with_spears)
	_units_to_pair = _get_adjacent_to_allies_in_combat(not_in_combat)
	_activate_unpaired()
	
	for combat : Array[Unit] in _combats:
		for unit : Unit in combat:
			if unit.team == team:
				_combat_supporters[unit] = []


	_auto_support()

	if _units_to_pair.is_empty():
		TurnManager.end_phase()

func end_phase() -> void:
	for unit : Unit in WargameUtils.get_units():
		unit.activated()

func mouse_over(unit : Unit) -> void:
	unit.highlight()

func mouse_exit(unit : Unit) -> void:
	unit.unhighlight()
	
func mouse_pressed(global_position : Vector2) -> void:
	var map_position : Vector2i = SKTileMap.Instance.global_to_map(global_position)
	
	if _selected_unit == null:
		var unit_clicked : Unit = SKTileMap.Instance.get_entity_at_position(map_position)
		if unit_clicked in _units_to_pair:
			_selected_unit = unit_clicked
			
			for unit_to_deactivate : Unit in WargameUtils.get_units():
				unit_to_deactivate.activated()
				
			var adjacent_units : Array[Unit] = SKTileMap.get_adjacent_units_of_team(map_position, unit_clicked.team)
			var adjacent_in_combat : Array[Unit] = []
			for adjacent : Unit in adjacent_units:
				if _unit_in_combat(adjacent):
					adjacent_in_combat.append(adjacent)
					adjacent.can_activate()

			if len(adjacent_in_combat) == 1:
				_attempt_support(adjacent_in_combat[0], _selected_unit)
	else:
		var unit_clicked : Unit = SKTileMap.Instance.get_entity_at_position(map_position)
		
		_attempt_support(unit_clicked, _selected_unit)
		
#
# Private
#
func _auto_support() -> void:
	#Auto support units that are adjacent to only one group of units in combat
	var units_to_iterate_over : Array[Unit] = []
	for unit : Unit in _units_to_pair:
		units_to_iterate_over.append(unit)
	for unit : Unit in units_to_iterate_over:
		var adjacent_units : Array[Unit] = SKTileMap.get_adjacent_units_of_team(unit.get_map_position(), unit.team)
		var adjacent_in_combat : Array[Unit] = []
		for adjacent : Unit in adjacent_units:
			if _unit_in_combat(adjacent):
				adjacent_in_combat.append(adjacent)

		var adjacent_combats : Array[Array] = []
		for combat : Array[Unit] in _combats:
			for adjacent_unit : Unit in adjacent_in_combat:
				if adjacent_unit in combat and combat not in adjacent_combats:
					adjacent_combats.append(combat)
					break
		if len(adjacent_combats) == 1:
			_selected_unit = unit
			_attempt_support(adjacent_in_combat[0], unit)
		else:
			print("Cannot autosupport?")

func _attempt_support(unit : Unit, supporter : Unit) -> void:
	var adjacent_units : Array[Unit] = SKTileMap.get_adjacent_units_of_team(supporter.get_map_position(), supporter.team)
	if unit != null and unit in adjacent_units and _unit_in_combat(unit):
		for combat : Array[Unit] in _combats:
			if unit in combat:
				_combat_supporters[unit].append(_selected_unit)
				break
				
		_units_to_pair.remove_at(_units_to_pair.find(_selected_unit))
		_selected_unit.deselect()
		_selected_unit = null

		_draw_supports()
		_activate_unpaired()

		if _units_to_pair.is_empty():
			TurnManager.end_phase()
	else:
		print("Trying to support a unit that is not in combat")

func _draw_supports() -> void:
	_clear_drawn_supports()
	for unit : Unit in _combat_supporters:
		var supporters : Array = _combat_supporters[unit]
		var locations : Array[Vector2i] = []
		for supporter : Unit in supporters:
			locations.append(supporter.get_map_position())
		unit.draw_supports(locations)

func _clear_drawn_supports() -> void:
	for unit : Unit in WargameUtils.get_units(team):
		unit.draw_supports([])

func _activate_unpaired() -> void:
	for unit : Unit in WargameUtils.get_units():
		if unit in _units_to_pair and unit.team == team:
			unit.can_activate()
		else:
			unit.activated()
			
func _unit_in_combat(unit : Unit) -> bool:
	for combat : Array[Unit] in _combats:
		if unit in combat:
			return true
	return false

func _get_adjacent_to_allies_in_combat(units : Array[Unit]) -> Array[Unit]:
	var adjacent_to_allies : Array[Unit] = []
	for unit : Unit in units:
		var adjacent_units : Array[Unit] = SKTileMap.Instance.get_adjacent_units_of_team(unit.get_map_position(), unit.team)
		for adjacent : Unit in adjacent_units:
			if _unit_in_combat(adjacent) and unit not in adjacent_to_allies:
				adjacent_to_allies.append(unit)
	return adjacent_to_allies

func _get_units_not_in_combat(units : Array[Unit]) -> Array[Unit]:
	var units_not_in_combat : Array[Unit] = []
	for unit : Unit in units:
		if not _unit_in_combat(unit):
			units_not_in_combat.append(unit)
	return units_not_in_combat
