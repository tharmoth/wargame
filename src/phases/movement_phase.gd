class_name MovementPhase

# Public Variables
var team : String = "player1"
var name : String = "Movement"

# Private Variables
var _units_to_move : Array[Unit] = []
var _selected_unit : Unit = null

func start_phase() -> void:
	_units_to_move = []
	var units : Array[Unit] = WargameUtils.get_units(team)
	
	# Check the condition that a unit is not near enemy units to move
	for unit in units:
		var in_enemy_zoc : bool = false
		for entity in SKTileMap.Instance.get_adjacent_units(unit.get_map_position()):
			if entity.team != team:
				in_enemy_zoc = true
		if not in_enemy_zoc:
			_units_to_move.append(unit)
			unit.can_activate()

func end_phase():
	for unit in _units_to_move:
		unit.activated()

func mouse_over(unit : Unit) -> void:
	if unit in _units_to_move:
		unit.highlight()

func mouse_exit(unit : Unit) -> void:
	unit.unhighlight()
	
func mouse_pressed(global_position : Vector2) -> void:
	var map_position = SKTileMap.Instance.global_to_map(global_position)
	if _selected_unit == null:
		var unit = SKTileMap.Instance.get_entity_at_position(map_position)
		if unit in _units_to_move:
			unit.select()
			_selected_unit = unit
			
			var tiles = Movement.get_valid_tiles(_selected_unit, false)
			_selected_unit.draw_movement(tiles)
	elif map_position in _selected_unit.tiles:
		_selected_unit.move_to(map_position)
		
		_selected_unit.activated()
		_selected_unit.deselect()
		_selected_unit.draw_movement([])
		_units_to_move.remove_at(_units_to_move.find(_selected_unit))
		_selected_unit = null
