class_name WargameUtils

# Managed in the untis class, used to avoid calls to get_tree().get_nodes_in_group("unit")
static var units : Array[Unit] = []

static func get_units(team : String = "any") -> Array[Unit]:
	var units_of_team : Array[Unit] = []
	for entity : Unit in units:
		if (entity != null and entity.team == team) or (entity != null and team == "any"):
			units_of_team.append(entity)
	return units_of_team

static func get_enemy_team(team : String) -> String:
	if team == "player1":
		return "player2"
	else:
		return "player1"

static func get_units_with_item(units : Array[Unit], item : String) -> Array[Unit]:
	var with_item : Array[Unit] = []
	for unit : Unit in units:
		if item in unit.stats.items:
			with_item.append(unit)
	return with_item

static func deactivate_units() -> void:
	for unit : Unit in WargameUtils.get_units():
		unit.activated()
