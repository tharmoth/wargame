extends BasePhase

class_name FightPhase

# Public Variables
var get_combats : Callable
var get_supports1 : Callable 
var get_supports2 : Callable 

# Private Variables
var _combats : Array[Array] = []
var _supports : Dictionary = {}
var _selected_combat : Array[Unit] = []
var _team1 : Array[Unit] = []
var _team2 : Array[Unit] = []

var _phases : Array = ["Duel", "Knockback", "Strike", "End"]
var _current_phase : String = "Duel"



var _team_1_result : Array[int]
var _team_2_result : Array[int]
var _winning_team : String = ""
var _reroll_queue : Array[Array] = []

# var _winners : Array[Unit] = []
# var _losers : Array[Unit] = []

func can_end_phase() -> bool:
	return _combats.is_empty()

func start_phase() -> void:
	_current_phase = "Select"
	_combats = get_combats.call()
	_supports = get_supports1.call()
	_supports.merge(get_supports2.call())
	
	for combat : Array[Unit] in _combats:
		for unit : Unit in combat:
			if unit.team == team:
				unit.can_activate()
				
	if _combats.is_empty():
		TurnManager.end_phase()

func end_phase() -> void:
	for unit : Unit in WargameUtils.get_units():
		unit.activated()

func mouse_over(unit : Unit) -> void:
	pass

func mouse_exit(unit : Unit) -> void:
	pass
	
func mouse_pressed(global_position : Vector2) -> void:
	if _current_phase != "Select" or not _selected_combat.is_empty():
		return
	var map_position : Vector2i = SKTileMap.Instance.global_to_map(global_position)
	var unit : Unit = SKTileMap.Instance.get_entity_at_position(map_position)
	if unit != null and unit.activate_outline._highlight:
		for combat : Array[Unit] in _combats:
			if unit in combat:
				_selected_combat = combat

				var team_result : Array[Array] = _calculate_teams(combat)
				_team1 = team_result[0]
				_team2 = team_result[1]

				GUI.show_fight_gui([_team1[0].stats], [_team2[0].stats])

				# Pause Here and display on gui until space pressed
				GUI.show_button("[Space] Roll to Duel")
				GUI.set_fight_gui_title("Duel Roll")
				GUI.set_fight_gui_button_text("[Space] Roll to Duel")
				_current_phase = "Duel"

				_combats.remove_at(_combats.find(combat))
				PanCamera.Instance.request(unit.global_position)
				break

func button_pressed() -> void:
	if _current_phase == "Duel":
		_duel(_team1, _team2)
		
		_reroll_queue.clear()
		_reroll_queue.append(get_losers())
		_reroll_queue.append(get_winners())

		print("Reroll Queue: first " + _reroll_queue[0][0].team + " second " + _reroll_queue[1][0].team, " current winner " + _winning_team)

		if _should_team_reroll(_reroll_queue[0]):
			_current_phase = "Reroll"
			GUI.set_fight_gui_title("Duel Roll")
			GUI.set_fight_gui_button_text("[Space] Banner Reroll")
			if _reroll_queue[0][0].team == "player2":
				GUI.instance.get_tree().create_timer(1.0).connect("timeout", func() -> void: GUI.instance.programatically_press_button())
		else:
			_current_phase = "Strike"
			_clean_up_combat()
	elif _current_phase == "Reroll":
		var team_to_reroll : Array[Unit] = _reroll_queue[0]
		_reroll_queue.remove_at(0)
		var results : Array[int] = _team_1_result if team_to_reroll[0].team == "player1" else _team_2_result
		reroll(team_to_reroll, results)

		if not _reroll_queue.is_empty() and _should_team_reroll(_reroll_queue[0]):
			if _reroll_queue[0][0].team == "player2":
				GUI.instance.get_tree().create_timer(1.0).connect("timeout", func() -> void: GUI.instance.programatically_press_button())
			GUI.set_fight_gui_button_text("[Space] Banner Reroll")
		else:
			_current_phase = "Strike"
			_clean_up_combat()
			GUI.set_fight_gui_button_text("[Space] Roll to Strike")
	elif _current_phase == "Strike":
		_knockback_losers(get_losers())
		_current_phase = "End"
		_deal_strikes(get_winners(), get_losers())
		_selected_combat = []
		_team1 = []
		_team2 = []
	elif _current_phase == "End":
		GUI.hide_fight_gui()
		_current_phase = "Select"
		if _combats.is_empty():
			TurnManager.end_phase()

#
# Private
#
func _should_team_reroll(team : Array[Unit]) -> bool:
	if team == get_winners():
		return false

	var team_1_fight_value : int = _get_team_fight_value(_team1)
	var team_2_fight_value : int = _get_team_fight_value(_team2)
	var team_1_max : int = _get_max_roll(_team_1_result)
	var team_2_max : int = _get_max_roll(_team_2_result)

	if team[0].team == "player1":
		if team_2_max == 6 and team_2_fight_value > team_1_fight_value:
			return false

	if team[0].team == "player2":
		if team_1_max == 6 and team_1_fight_value > team_2_fight_value:
			return false

	for unit : Unit in team:
		if _should_have_banner_bonus(unit):
			return true
	return false

# TODO: Care about which unit
func reroll(units : Array[Unit], results : Array[int]) -> void:
	# Find the lowest roll in results
	var min_roll : int = 7
	var min_index : int = -1
	for i : int in range(results.size()):
		if results[i] < min_roll:
			min_roll = results[i]
			min_index = i

	var new_roll : int = Utils.roll_dice("1d6")
	results[min_index] = new_roll

	_winning_team = determine_winner()
	GUI.reroll(min_index, new_roll, units[0].team, _winning_team)

func _clean_up_combat() -> void:
	for unit : Unit in _selected_combat:
		var empty : Array[Vector2i] = []
		unit.draw_fights(empty)
		unit.draw_supports(empty)
		unit.activated()

func _get_team_fight_value(team : Array[Unit]) -> int:
	var fight_value : int = 0
	for unit : Unit in team:
		fight_value = max(fight_value, unit.stats.fight_value)
	return fight_value

func _calculate_teams(combat : Array[Unit]) -> Array[Array]:
	var team1 : Array[Unit] = []
	var team2 : Array[Unit] = []
	for unit : Unit in combat:
		if unit.team == "player1":
			team1.append(unit)
		else:
			team2.append(unit)
	return [team1, team2]

func _duel(team1 : Array[Unit], team2 : Array[Unit]) -> void:
	_team_1_result = _duel_roll(team1)
	_team_2_result = _duel_roll(team2)
	_winning_team = determine_winner()
	GUI.show_duel_row(_team_1_result, _team_2_result, _winning_team)


func determine_winner() -> String:
	var team_1_fight_value : int = _get_team_fight_value(_team1)
	var team_2_fight_value : int = _get_team_fight_value(_team2)
	var team_1_max : int = _get_max_roll(_team_1_result)
	var team_2_max : int = _get_max_roll(_team_2_result)

	var player_1_wins_tie : bool = false
	if team_1_max == team_2_max:
		if team_1_fight_value == team_2_fight_value:
			var tie_roll : int = Utils.roll_dice("1d6")
			if tie_roll > 3:
				player_1_wins_tie = true
		elif team_1_fight_value > team_2_fight_value:
			player_1_wins_tie = true
		else:
			player_1_wins_tie = false

	if team_1_max > team_2_max or (team_1_max == team_2_max and player_1_wins_tie):
		return "player1"
	else:
		return "player2"

func get_winners() -> Array[Unit]:
	return _team1 if _winning_team == "player1" else _team2

func get_losers() -> Array[Unit]:
	return _team1 if _winning_team == "player2" else _team2

func _calculate_winners_losers(team1 : Array[Unit], team2 : Array[Unit], team_1_result : Array[int], team_2_result : Array[int]) -> Array[Array]:
	var team_1_fight_value : int = _get_team_fight_value(team1)
	var team_2_fight_value : int = _get_team_fight_value(team2)

	var team_1_max : int = _get_max_roll(team_1_result)
	var team_2_max : int = _get_max_roll(team_2_result)

	var player_1_wins_tie : bool = false
	if team_1_max == team_2_max:
		if team_1_fight_value == team_2_fight_value:
			var tie_roll : int = Utils.roll_dice("1d6")
			if tie_roll > 3:
				player_1_wins_tie = true
		elif team_1_fight_value > team_2_fight_value:
			player_1_wins_tie = true
		else:
			player_1_wins_tie = false

	var winners : Array[Unit] = []
	var losers : Array[Unit] = []
	if team_1_max > team_2_max or (team_1_max == team_2_max and player_1_wins_tie):
		winners = team1
		losers = team2
	else:
		winners = team2
		losers = team1
	
	GUI.show_duel_row(team_1_result, team_2_result, winners[0].team)
	
	return [winners, losers]

func _get_valid_movement_options(unit : Unit) -> Array[Vector2i]:
	var valid_adjacent : Array[Vector2i] = []
	for direction : Vector2i in SKTileMap.get_adjacent_cells(unit.get_map_position()):
		var pos : Vector2i = unit.get_map_position() + direction
		if SKTileMap.Instance.get_entity_at_position(pos) != null:
			continue
		var enemies : Array[Unit] = SKTileMap.get_adjacent_units_not_of_team(pos, unit.team)
		if enemies.is_empty():
			valid_adjacent.append(pos)
	return valid_adjacent

func _knockback_losers(losers : Array[Unit]) -> void:
	GUI.play_audio(GUI.Sound.IMPACT)
	for unit : Unit in losers:
		var valid_adjacent : Array[Vector2i] = _get_valid_movement_options(unit)
		
		for adjacent_ally : Unit in SKTileMap.get_adjacent_units_of_team(unit.get_map_position(), unit.team):
			if _is_in_combat(adjacent_ally):
				continue
			var allies_adjacent : Array[Vector2i] = _get_valid_movement_options(adjacent_ally)
			if not allies_adjacent.is_empty():
				valid_adjacent.append(adjacent_ally.get_map_position())

		# Prefer to move directly away from the opponent find locations opposite of the opponent
		var preferred_locations : Array[Vector2i] = []
		var adjacent_enemies : Array[Unit] = SKTileMap.get_adjacent_units_not_of_team(unit.get_map_position(), unit.team)
		for enemy : Unit in adjacent_enemies:
			var direction : Vector2i = unit.get_map_position() - enemy.get_map_position()
			preferred_locations.append(unit.get_map_position() + direction)

		var found : bool = false
		for location : Vector2i in preferred_locations:
			if location in valid_adjacent:
				var adjacent_ally : Unit = SKTileMap.Instance.get_entity_at_position(location)
				if adjacent_ally != null:
					_make_way(adjacent_ally, unit)
				unit.move_to(location)
				found = true
				break
		if not found and not valid_adjacent.is_empty():
			unit.move_to(valid_adjacent[0])

func _make_way(unit : Unit, requestor : Unit) -> bool:
	var valid_adjacent : Array[Vector2i] = _get_valid_movement_options(unit)
	
	if valid_adjacent.is_empty():
		return false
	else:
		var found : bool = false
		var prefered : Vector2i = 2 * unit.get_map_position() - requestor.get_map_position()
		if prefered in valid_adjacent:
			unit.move_to(prefered)
			found = true
		if not found:
			unit.move_to(valid_adjacent[0])
	return true

func _duel_roll(units : Array[Unit]) -> Array[int]:
	var rolls : Array[int] = []
	for unit : Unit in units:
		var roll : int = Utils.roll_dice("1d6")	
		rolls.append(roll)
		
		if unit in _supports:
			for support : Unit in _supports[unit]:
				var support_roll : int = Utils.roll_dice("1d6")
				rolls.append(support_roll)
	return rolls

func _deal_strikes(winners : Array[Unit], losers : Array[Unit]) -> void:
	var units_to_strike_with : Array[Unit] = []
	for unit : Unit in winners:
		units_to_strike_with.append(unit)
		for support : Unit in _supports[unit]:
			units_to_strike_with.append(support)
	
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
			GUI.play_audio(GUI.Sound.STAB)
			var blood : BloodComponent = BloodComponent.new()
			blood.position = loser.global_position
			loser.get_parent().add_child(blood)
			loser.stats.wounds = loser.stats.wounds - 1
			if loser.stats.wounds <= 0:
				losers.remove_at(losers.find(loser))
				loser.kill()
		else:
			GUI.play_audio(GUI.Sound.MISS)

	GUI.show_cutoff_row(rolls, cutoff)

func _should_have_banner_bonus(unit : Unit) -> bool:
	var units : Array[Unit] = WargameUtils.get_units(unit.team)
	var banners : Array[Unit] = WargameUtils.get_units_with_item(units, "banner")
	for banner : Unit in banners:
		var distance : int = SKTileMap.Instance.map_distance(banner.get_map_position(), unit.get_map_position())
		if SKTileMap.Instance.map_distance(banner.get_map_position(), unit.get_map_position()) <= 6:
			return true
	return false

func _get_roll_string(rolls : Array[int]) -> String:
	var string : String = ""
	for roll : int in rolls:
		string = string + str(roll) + ", "
	return string.substr(0, string.length() - 2)

func _get_max_roll(rolls : Array[int]) -> int:
	var max_roll : int = -1
	for roll : int in rolls:
		max_roll = max(max_roll, roll)
	return max_roll

func _is_in_combat(unit : Unit) -> bool:
	for combat : Array[Unit] in _combats:
		if unit in combat:
			return true
	return false


	
