class_name SupportPhase

# Public Variables
var team : String = "player1"
var name : String = "Support Phase"
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
	
	var units         : Array[Unit] = WargameUtils.get_units(team)
	var with_spears   : Array[Unit] = WargameUtils.get_units_with_item(units, "spear")
	var not_in_combat : Array[Unit] = _get_units_not_in_combat(with_spears)
	_units_to_pair = _get_adjacent_to_allies_in_combat(not_in_combat)
	_activate_unpaired()
	
	for combat in _combats:
		for unit in combat:
			if unit.team == team:
				_combat_supporters[unit] = []

func end_phase():
	pass

func mouse_over(unit : Unit) -> void:
	unit.highlight()

func mouse_exit(unit : Unit) -> void:
	unit.unhighlight()
	
func mouse_pressed(global_position : Vector2) -> void:
	var map_position : Vector2i = SKTileMap.Instance.global_to_map(global_position)
	
	if _selected_unit == null:
		var unit_clicked = SKTileMap.Instance.get_entity_at_position(map_position)
		if unit_clicked in _units_to_pair:
			_selected_unit = unit_clicked
			
			for unit_to_deactivate in WargameUtils.get_units():
				unit_to_deactivate.activated()
				
			for adjacent in SKTileMap.Instance.get_adjacent_units_of_team(map_position, unit_clicked.team):
				if _unit_in_combat(adjacent):
					adjacent.can_activate()
	else:
		var unit_clicked = SKTileMap.Instance.get_entity_at_position(map_position)
		
		if unit_clicked != null and unit_clicked.activate_outline._highlight:
			for combat in _combats:
				if unit_clicked in combat:
					_combat_supporters[unit_clicked].append(_selected_unit)
					break
					
			_units_to_pair.remove_at(_units_to_pair.find(_selected_unit))
			_draw_supports()
			_activate_unpaired()
			
			_selected_unit.deselect()
			_selected_unit = null
		
#
# Private
#
func _draw_supports() -> void:
	_clear_drawn_supports()
	for unit in _combat_supporters:
		var supporters = _combat_supporters[unit]
		var locations : Array[Vector2i] = []
		for supporter in supporters:
			locations.append(supporter.get_map_position())
		unit.draw_supports(locations)

func _clear_drawn_supports() -> void:
	for unit in WargameUtils.get_units(team):
		unit.draw_supports([])

func _activate_unpaired() -> void:
	for unit in WargameUtils.get_units():
		if unit in _units_to_pair and unit.team == team:
			unit.can_activate()
		else:
			unit.activated()
			
func _unit_in_combat(unit : Unit) -> bool:
	for combat in _combats:
		if unit in combat:
			return true
	return false

func _get_adjacent_to_allies_in_combat(units : Array[Unit]) -> Array[Unit]:
	var adjacent_to_allies : Array[Unit]
	for unit in units:
		var adjacent_units = SKTileMap.Instance.get_adjacent_units_of_team(unit.get_map_position(), unit.team)
		for adjacent in adjacent_units:
			if _unit_in_combat(adjacent):
				adjacent_to_allies.append(unit)
	return adjacent_to_allies

func _get_units_not_in_combat(units : Array[Unit]) -> Array[Unit]:
	var units_not_in_combat  : Array[Unit] = []
	for unit in units:
		if not _unit_in_combat(unit):
			units_not_in_combat.append(unit)
	return units_not_in_combat
