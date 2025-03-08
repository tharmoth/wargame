class_name Movement

static var DIRECTIONS : Array[Vector2i] = [Vector2i(0, 1), Vector2i(1, 0), Vector2i(0, -1), Vector2i(-1, 0), Vector2i(1, -1), Vector2i(-1, -1)]

static func get_team_zoc(team: String) -> Array[Vector2i]:
	var entities: Array[Node] = SKTileMap.Instance.get_entities()
	var enemies : Array[Node] = []
	for entity : Node in entities:
		if entity.team != team:
			enemies.append(entity)
	
	var positions: Array[Vector2i] = []
	for enemy : Node in enemies:
		var map_pos : Vector2i = SKTileMap.Instance.global_to_map(enemy.global_position)
		for direction : Vector2i in SKTileMap.get_adjacent_cells(map_pos):
			if SKTileMap.Instance.get_entity_at_position(map_pos + direction) == null:
				positions.append(map_pos + direction)
	
	return positions

static func get_valid_tiles(node: Unit) -> Array[Vector2i]:
	var distance : int = node.stats.movement
	var team: String  = node.team

	# Obtain a list of empty grid positions within the move distance of the unit
	var valid_tiles_map : Array[Vector2i] = []
	var tiles_map : Array[Vector2i] = SKTileMap.Instance.get_tiles_in_radius(SKTileMap.Instance.global_to_map(node.global_position), distance)
	for map_tile : Vector2i in tiles_map:
		var current: Unit = SKTileMap.Instance.get_entity_at_position(map_tile)
		if current == null || current == node:
			valid_tiles_map.append(map_tile)

	# Initalize a dictionary to store the distance from the starting node to each node
	var distance_dictionary : Dictionary = {}
	for tile : Vector2i in valid_tiles_map:
		distance_dictionary[tile] = -1
	distance_dictionary[node.get_map_position()] = 0

	# Fill out the dictionary with the enemy teams ZOC
	var zoc: Array[Vector2i] = get_team_zoc(team)
	for i : int in range(len(zoc)):
		if distance_dictionary.has(zoc[i]):
			distance_dictionary[zoc[i]] = -2

	_flood_fill_distance(distance_dictionary)

	# Translate the dictionary to a list of valid points
	var valid_points_map : Array[Vector2i] = []
	for key : Vector2i in distance_dictionary.keys():
		if distance_dictionary[key] > -1 and distance_dictionary[key] <= distance:
			valid_points_map.append(key)

	# For each ZOC point check if there is an adjacent valid point if so add the ZOC point to the valid points
	for zoc_point : Vector2i in zoc:
		for direction : Vector2i in SKTileMap.get_adjacent_cells(zoc_point):
			var neighbor : Vector2i = zoc_point + direction
			if distance_dictionary.has(neighbor) and distance_dictionary[neighbor] > -1 and distance_dictionary[neighbor] <= distance:
				valid_points_map.append(zoc_point)
				break

	return valid_points_map

static func _flood_fill_distance(distance_dict : Dictionary) -> Dictionary:
	var queue : Array[Vector2i] = []
	queue.append(distance_dict.find_key(0))

	while queue.size() > 0:
		var current : Vector2i = queue.pop_front()
		var current_distance : int = distance_dict[current]

		for direction : Vector2i in SKTileMap.get_adjacent_cells(current):
			var neighbor : Vector2i = current + direction
			if distance_dict.has(neighbor) and distance_dict[neighbor] == -1:
				distance_dict[neighbor] = current_distance + 1
				queue.append(neighbor)
	
	return distance_dict
