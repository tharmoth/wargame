class_name FightPhase

# Public Variables
var team = "player1"
var name : String  = "Fight"
var get_combats : Callable
var get_supports1 : Callable 
var get_supports2 : Callable 

# Private Variables
var _combats : Array[Array] = []
var _supports : Dictionary = {}

func start_phase() -> void:
	_combats = get_combats.call()
	_supports = get_supports1.call()
	_supports.merge(get_supports2.call())
	
	for combat : Array[Unit] in _combats:
		for unit : Unit in combat:
			if unit.team == team:
				unit.can_activate()

func end_phase():
	for unit in WargameUtils.get_units():
		unit.activated()

func mouse_over(unit : Unit) -> void:
	pass

func mouse_exit(unit : Unit) -> void:
	pass
	
func mouse_pressed(global_position : Vector2) -> void:
	var map_position: Vector2i = SKTileMap.Instance.global_to_map(global_position)
	var unit                   = SKTileMap.Instance.get_entity_at_position(map_position)
	if unit != null and unit.activate_outline._highlight:
		for combat in _combats:
			if unit in combat:
				_evaluate_combat(combat)
				unit.activated()
				for unit2 in combat: 
					var empty : Array[Vector2i] = []
					unit2.draw_fights(empty)
					unit2.draw_supports(empty)
					unit2.activated()
				break

#
# Private
#
func _evaluate_combat(combat : Array[Unit]) -> void:
	var team1 : Array[Unit] = []
	var team2 : Array[Unit] = []
	var team_1_fight_value : int = 0
	var team_2_fight_value : int = 0
	for unit in combat:
		if unit.team == "player1":
			team1.append(unit)
			team_1_fight_value = max(team_1_fight_value, unit.stats.fight_value)
		else:
			team2.append(unit)
			team_2_fight_value = max(team_2_fight_value, unit.stats.fight_value)
	
	var team_1_result: Array[int] = duel_roll(team1)
	var team_2_result: Array[int] = duel_roll(team2)
	
	GUI.show_stats([team1[0].stats], "player1")
	GUI.show_stats([team2[0].stats], "player2")
	
	print("Player 1 rolled " + get_roll_string(team_1_result) + " for a max of " + str(get_max_roll(team_1_result)))
	print("Player 2 rolled " + get_roll_string(team_2_result) + " for a max of " + str(get_max_roll(team_2_result)))
	
	var player_1_wins_tie : bool = false
	if get_max_roll(team_1_result) == get_max_roll(team_2_result):
		if team_1_fight_value == team_2_fight_value:
			print("Duel tied with equal fight values!")
			var tie_roll: int = Utils.roll_dice("1d6")
			print("Tie Roll: " + str(tie_roll))
			if tie_roll > 3:
				player_1_wins_tie = true
		elif team_1_fight_value > team_2_fight_value:
			player_1_wins_tie = true
			print("Player 1 wins tie due to fight value: " + str(team_1_fight_value) + " vs " + str(team_2_fight_value))
		else:
			player_1_wins_tie = false
			print("Player 2 wins tie due to fight value: " + str(team_2_fight_value) + " vs " + str(team_1_fight_value))
			
	var winners : Array[Unit] = []
	var losers : Array[Unit] = []
	if get_max_roll(team_1_result) > get_max_roll(team_2_result) or (get_max_roll(team_1_result) == get_max_roll(team_2_result) and player_1_wins_tie):
		print("Player 1 Won the Duel")
		winners = team1
		losers = team2
	else:
		print("Player 2 Won the Duel")
		winners = team2
		losers = team1
		
	knockback_losers(losers)
	deal_strikes(winners, losers)

func knockback_losers(losers : Array[Unit]) -> void:
	for unit in losers:
		var valid_adjacent : Array[Vector2i] = []
		for direction in Movement.DIRECTIONS:
			var pos: Vector2i = unit.get_map_position() + direction
			if SKTileMap.Instance.get_entity_at_position(pos) != null:
				continue
			var enemies : Array[Unit] = SKTileMap.get_adjacent_units_not_of_team(pos, unit.team)
			if enemies.is_empty():
				valid_adjacent.append(pos)
		
		if valid_adjacent.is_empty():
			var found : bool = false
			for adjacent_ally in SKTileMap.get_adjacent_units_of_team(unit.get_map_position(), unit.team):
				var location: Vector2i = adjacent_ally.get_map_position()
				var returned : bool    = _make_way(adjacent_ally, unit)
				if returned:
					unit.move_to(location)
					found = true
					break
			if not found:
				unit.queue_free()
		else:
			var adjacent_units: Array[Unit] = SKTileMap.get_adjacent_units_not_of_team(unit.get_map_position(), unit.team)
			var found : bool                = false
			for adjacent_unit : Unit in adjacent_units:
				var prefered: Vector2i = 2 * unit.get_map_position() - adjacent_unit.get_map_position()
				if prefered in valid_adjacent:
					unit.move_to(prefered)
					found = true
					break
			if not found:
				unit.move_to(valid_adjacent[0])

func _make_way(unit : Unit, requestor: Unit) -> bool:
	var valid_adjacent : Array[Vector2i] = []
	for direction in Movement.DIRECTIONS:
		var pos: Vector2i = unit.get_map_position() + direction
		if SKTileMap.Instance.get_entity_at_position(pos) != null:
			continue
		var enemies : Array[Unit] = SKTileMap.get_adjacent_units_not_of_team(pos, unit.team)
		if enemies.is_empty():
			valid_adjacent.append(pos)
	
	if valid_adjacent.is_empty():
		return false
	else:
		var found : bool       = false
		var prefered: Vector2i = 2 * unit.get_map_position() - requestor.get_map_position()
		if prefered in valid_adjacent:
			unit.move_to(prefered)
			found = true
		if not found:
			unit.move_to(valid_adjacent[0])
	return true

func duel_roll(units : Array[Unit]) -> Array[int]:
	var rolls : Array[int] = []
	for unit in units:
		var roll: int = Utils.roll_dice("1d6")
	
		if roll == 1 and should_have_banner_bonus(unit):
			print(unit.name + " rerolled a 1 due to banner!")
			roll = Utils.roll_dice("1d6")
	
		rolls.append(roll)
		
		if unit in _supports:
			for support in _supports[unit]:
				var support_roll: int = Utils.roll_dice("1d6")
				rolls.append(support_roll)
	return rolls

func deal_strikes(winners : Array[Unit], losers : Array[Unit]) -> void:
	var untis_to_strike_with : Array[Unit] = []
	for unit in winners:
		untis_to_strike_with.append(unit)
		for support in _supports[unit]:
			untis_to_strike_with.append(support)
		
	for unit in untis_to_strike_with:
		if losers.is_empty():
			break
		var loser: Unit   = losers[0]
		var defense: int  = loser.stats.defense
		var strength: int = unit.stats.strength
		var cutoff: int   = Stats.get_wound_target(strength, defense)
		var roll: int     = Utils.roll_dice("1d6")
		print(unit.name + " needs a " + str(cutoff) + " to wound!")
		print(unit.name + " rolled a " + str(roll) + " to wound...")
		if roll >= cutoff:
			print("It wounds " + loser.name)
			loser.stats.wounds = loser.stats.wounds - 1
			if loser.stats.wounds <= 0:
				losers.remove_at(losers.find(loser))
				loser.queue_free()
		else:
			print(" it fails to wound!")

func should_have_banner_bonus(unit : Unit) -> bool:
	var units: Array[Unit]   = WargameUtils.get_units(unit.team)
	var banners: Array[Unit] = WargameUtils.get_units_with_item(units, "banner")
	for banner in banners:
		if banner.get_map_position().distance_to(unit.get_map_position()) <= 6:
			return true
	return false

func get_roll_string(rolls : Array[int]) -> String:
	var string : String = ""
	for roll in rolls:
		string = string + str(roll) + ", "
	return string.substr(0, string.length() - 2)

func get_max_roll(rolls : Array[int]) -> int:
	var max_roll : int = -1
	for roll in rolls:
		max_roll = max(max_roll, roll)
	return max_roll
