extends BasePhase

class_name AIMovementPhase

# Public Variables

# Private Variables
var _units_to_move : Array[Unit] = []

func start_phase() -> void:
	_units_to_move = []
	var units : Array[Unit] = WargameUtils.get_units(team)
	
	# Check the condition that a unit is not near enemy units to move
	for unit : Unit in units:
		var in_enemy_zoc : bool = false
		for entity : Unit in SKTileMap.Instance.get_adjacent_units(unit.get_map_position()):
			if entity.team != team:
				in_enemy_zoc = true
		if not in_enemy_zoc:
			_units_to_move.append(unit)

	var spear_units : Array[Unit] = WargameUtils.get_units_with_item(_units_to_move, "spear")
	var other_units : Array[Unit] = []
	for unit : Unit in _units_to_move:
		if unit not in spear_units:
			other_units.append(unit)

	move_to_nearest_enemy(other_units)
	move_to_support(spear_units)

	TurnManager.end_phase()

func move_randomly(units : Array[Unit]) -> void:
	for unit : Unit in units:
		var tiles : Array[Vector2i] = Movement.get_valid_tiles(unit, false)
		if tiles.is_empty():
			continue
		else:
			unit.move_to(tiles[randi() % tiles.size()])

# Attmpt to move units to a tile adjacent to friendly units that are in combat, but not next to enemies.
func move_to_support(units : Array[Unit]) -> void:
	var enemy_units : Array[Unit] = WargameUtils.get_units(WargameUtils.get_enemy_team(team))
	var friendly_units : Array[Unit] = WargameUtils.get_units(team)
	var already_supported : Array[Unit] = []

	for unit : Unit in units:
		friendly_units.sort_custom(func(a : Unit, b : Unit) -> bool:
			return _sort_by_distance(unit.get_map_position(), a, b))

		var unit_supported : Unit = null
		var in_melee : Array[Unit] = friendly_units.filter(func(x: Unit) -> bool: return x.is_in_melee())
		var in_melee_not_supported : Array[Unit] = in_melee.filter(func(x: Unit) -> bool: return x not in already_supported)
		var not_supported : Array[Unit] = friendly_units.filter(func(x: Unit) -> bool: return x not in already_supported)
		# First attempt to move to allies that are in melee and are not supported
		unit_supported = move_to_nearest(unit, in_melee_not_supported)
		if unit_supported != null:
			unit.draw_supports([unit_supported.get_map_position()])
			unit.get_component("AIBlackboard").set_value("supporting", unit_supported)
			already_supported.append(unit_supported)
			continue
		# Then move to any ally not supported
		# unit_supported = move_to_nearest(unit, not_supported)
		# if unit_supported != null:
		# 	unit.draw_supports([unit_supported.get_map_position()])
		# 	already_supported.append(unit_supported)
		# 	continue
		# Then move to any enemy
		enemy_units.sort_custom(func(a : Unit, b : Unit) -> bool:
			return _sort_by_distance(unit.get_map_position(), a, b))
		var enemy_targeted : Unit = move_to_nearest(unit, enemy_units)
		if enemy_targeted != null:
			unit.draw_fights([enemy_targeted.get_map_position()])
			continue
		print("Nowhere found to move, remaining stationary")

func _sort_by_distance(origin : Vector2i, a : Unit, b : Unit) -> bool:
	return origin.distance_to(a.get_map_position()) < origin.distance_to(b.get_map_position())


func move_to_nearest_enemy(units : Array[Unit]) -> void:
	var enemy_units : Array[Unit] = WargameUtils.get_units(WargameUtils.get_enemy_team(team))
	

	for unit : Unit in units:
		enemy_units.sort_custom(func(a : Unit, b : Unit) -> bool:
			return _sort_by_distance(unit.get_map_position(), a, b))

		var not_in_melee : Array[Unit] = enemy_units.filter(func(x: Unit) -> bool: return not x.is_in_melee())
		# First attempt to move to enemies that are not in melee
		if move_to_nearest(unit, not_in_melee) != null:
			continue
		# Then move to any enemy
		if move_to_nearest(unit, enemy_units) != null:
			continue
		
# Attempt to move adjacent to the first possible unit in target_units, if possible
# Returns true if a move was made, false otherwise
func move_to_nearest(unit_to_move : Unit, target_units : Array[Unit]) -> Unit:
	for target_unit : Unit in target_units:
		var valid_tiles : Array[Vector2i] = Movement.get_valid_tiles(unit_to_move, false)
		var target_tiles : Array[Vector2i] = []
		for direction : Vector2i in SKTileMap.get_adjacent_cells(target_unit.get_map_position()):
			if direction + target_unit.get_map_position() in valid_tiles:
				target_tiles.append(direction + target_unit.get_map_position())
		target_tiles.sort_custom(func(a : Vector2i, b : Vector2i) -> bool:
			return unit_to_move.get_map_position().distance_to(a) < unit_to_move.get_map_position().distance_to(b))
		for target : Vector2i in target_tiles:
			unit_to_move.move_to(target)
			return target_unit
	return null
		

func end_phase() -> void:
	for unit : Unit in _units_to_move:
		unit.activated()

func mouse_over(unit : Unit) -> void:
	pass

func mouse_exit(unit : Unit) -> void:
	pass
	
func mouse_pressed(global_position : Vector2) -> void:
	pass

func _can_move_next_to(unit : Unit, map_pos : Vector2i) -> bool:
	var valid_tiles : Array[Vector2i] = Movement.get_valid_tiles(unit, false)
	for direction : Vector2i in SKTileMap.get_adjacent_cells(map_pos):
		if direction + map_pos in valid_tiles:
			return true
	return false