extends BasePhase

class_name PairOffPhase

# Public Variables
# Private Variables
var _units_to_pair : Array[Unit] = []
var _selected_unit : Unit = null
var _combats : Array[Array] = []

func get_combats() -> Array[Array]:
	return _combats

func start_phase() -> void:
	_combats = []
	_units_to_pair = []
	
	# Find list of units adjacent to units of a different team
	var units_in_combat : Array[Unit] = []
	for unit : Unit in WargameUtils.get_units():
		for entity : Unit in SKTileMap.Instance.get_adjacent_units(unit.get_map_position()):
			if entity.team != unit.team:
				units_in_combat.append(unit)
				break
	
	var new_combat_made : bool = true
	while new_combat_made:
		new_combat_made = false
		# Find all units with only one adjacent enemy unit and pair them into fights
		for unit : Unit in units_in_combat:
			if _unit_in_combat(unit):
				continue
				
			var adjacent : Array[Unit] = SKTileMap.get_adjacent_units_not_of_team(unit.get_map_position(), unit.team)
			var adjacent_not_in_combat : Array[Unit] = []
			for entity : Unit in adjacent:
				if not _unit_in_combat(entity):
					adjacent_not_in_combat.append(entity)
			if len(adjacent_not_in_combat) == 1:
				new_combat_made = true
				_add_to_combat(unit, adjacent_not_in_combat[0])
			elif len(adjacent) == 1:
				new_combat_made = true
				_add_to_combat(unit, adjacent[0])

	_draw_combats()
	
	# While there are units without pairs adjacent to units without pairs pair them up
	for unit : Unit in units_in_combat:
		var found : bool = false
		for combat : Array[Unit] in _combats:
			if unit in combat:
				found = true
				
		if not found:
			_units_to_pair.append(unit)
			
	_activate_unpaired()

	if _units_to_pair.is_empty():
		TurnManager.end_phase()

	# Now every unit with an individual combat should be paired so attept to add
	# units into combats that already have units in them


func end_phase() -> void:
	for unit : Unit in WargameUtils.get_units():
		unit.activated()
	#_clear_drawn_combats()

func mouse_over(unit : Unit) -> void:
	if unit in _units_to_pair:
		unit.highlight()

func mouse_exit(unit : Unit) -> void:
	unit.unhighlight()
	
func mouse_pressed(global_position : Vector2) -> void:
	var map_position : Vector2i = SKTileMap.Instance.global_to_map(global_position)
	
	if _selected_unit == null:
		var unit : Unit = SKTileMap.Instance.get_entity_at_position(map_position)
		if unit != null and unit.activate_outline._highlight:
			unit.select()
			_selected_unit = unit
			
			for unit_to_deactivate : Unit in WargameUtils.get_units():
				unit_to_deactivate.activated()
			
			var adjacent : Array[Unit] = SKTileMap.get_adjacent_units_not_of_team(map_position, team)
			var unpaired_adjacent : Array[Unit] = []
			for adjacent_unit : Unit in adjacent:
				if adjacent_unit in _units_to_pair:
					unpaired_adjacent.append(adjacent_unit)
					adjacent_unit.can_activate()
			if unpaired_adjacent.is_empty():
				for adjacent_unit : Unit in SKTileMap.get_adjacent_units_not_of_team(map_position, team):
					adjacent_unit.can_activate()
	else:
		var unit_clicked : Unit = SKTileMap.Instance.get_entity_at_position(map_position)
		var adjacent_to_selected_units : Array[Unit] = SKTileMap.get_adjacent_units_not_of_team(_selected_unit.get_map_position(), team)
		
		if unit_clicked in adjacent_to_selected_units and unit_clicked.activate_outline._highlight:
			
			_add_to_combat(_selected_unit, unit_clicked)

			_units_to_pair.remove_at(_units_to_pair.find(_selected_unit))
			_units_to_pair.remove_at(_units_to_pair.find(unit_clicked))
			_draw_combats()
			_activate_unpaired()
			
			_selected_unit.deselect()
			_selected_unit = null
#
# Private
#
func _activate_unpaired() -> void:
	for unit : Unit in WargameUtils.get_units():
		if unit in _units_to_pair and unit.team == team:
			unit.can_activate()
		else:
			unit.activated()
	
	var any_of_team_remaining : bool = false
	for unit : Unit in _units_to_pair:
		if unit.team == team:
			any_of_team_remaining = true
			break

	if not any_of_team_remaining:
		for unit : Unit in _units_to_pair:
			for adjacent : Unit in SKTileMap.get_adjacent_units_not_of_team(unit.get_map_position(), unit.team):
				adjacent.can_activate()
	
func _clear_drawn_combats() -> void:
	for unit : Unit in WargameUtils.get_units():
		unit.draw_fights([])

func _unit_in_combat(unit : Unit) -> bool:
	for combat : Array[Unit] in _combats:
		if unit in combat:
			return true
	return false

func _draw_combats() -> void:
	_clear_drawn_combats()
	for combat : Array[Unit] in _combats:
		var debug_string : String = ""
		var map_positions : Array[Vector2i] = []
		for unit : Unit in combat:
			debug_string = debug_string + unit.name + " "
			map_positions.append(unit.get_map_position())
		
		var team1 : Array[Unit] = []
		var team1pos : Array[Vector2i] = []
		var team2 : Array[Unit] = []
		var team2pos : Array[Vector2i] = []
		for unit : Unit in combat:
			if unit.team == "player1":
				team1.append(unit)
				team1pos.append(unit.get_map_position())
			else:
				team2.append(unit)
				team2pos.append(unit.get_map_position())
		
		for unit : Unit in team1:
			unit.draw_fights(team2pos)
			
		for unit : Unit in team2:
			unit.draw_fights(team1pos)
			
		print(debug_string)

func _add_to_combat(unit_a : Unit, unit_b : Unit) -> void:
	var found : bool = false
	for combat : Array[Unit] in _combats:
		if unit_a in combat:
			combat.append(unit_b)
			found = true
			break
		elif unit_b in combat:
			combat.append(unit_a)
			found = true
			break
	if not found:
		var combat : Array[Unit] = []
		combat.append(unit_a)
		combat.append(unit_b)
		_combats.append(combat)
