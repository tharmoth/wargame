class_name WargameUtils

static func get_units(team : String = "any") -> Array[Unit]:
	var entities: Array[Node] = SKTileMap.Instance.get_tree().get_nodes_in_group("unit")
	var units : Array[Unit]   = []
	for entity : Unit in entities:
		if (entity != null and entity.team == team) or (entity != null and team == "any"):
			units.append(entity)
	return units

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
