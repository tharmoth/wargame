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
	
static func _grid_to_map(grid: Array, xmin: int, y_min: int) -> Array[Vector2i]:
	var valid_points_map : Array[Vector2i] = []
	for x : int in range(0, len(grid)):
		for y : int in range(0, len(grid[0])):
			valid_points_map.append(Vector2i(x, y) + Vector2i(xmin, y_min))
	return valid_points_map
	
static func _map_to_grid(tiles: Array[Vector2i]) -> Dictionary:
	# find the max and min map coords.
	var x_max : int = Utils.INT_MIN
	var x_min : int = Utils.INT_MAX
	var y_max : int = Utils.INT_MIN
	var y_min : int = Utils.INT_MAX
	for point : Vector2i in tiles:
		if point.x > x_max: x_max = point.x
		if point.x < x_min: x_min = point.x
		if point.y > y_max: y_max = point.y
		if point.y < y_min: y_min = point.y
	
	var width : int = x_max - x_min
	var height : int = y_max - y_min
	
	var valid_tiles_map_zeroed : Array[Vector2i]  = []
	for point : Vector2i in tiles:
		valid_tiles_map_zeroed.append(point - Vector2i(x_min, y_min))
	
	# Map the list of valid points to a grid based at 0, 0 where valid tiles are 1 and invalid are 0
	var grid : Array = []
	for x : int in range(0, width + 1):
		var row : Array[int] = []
		for y : int in range(0, height + 1):
			# In radius
			if valid_tiles_map_zeroed.find(Vector2i(x, y)) == -1:
				row.append(0)
			# Not in radius
			else:
				row.append(1)
		grid.append(row)
		
	var result : Dictionary = {}
	result["grid"] = grid
	result["x_min"] = x_min
	result["y_min"] = y_min
	
	return result

static func get_valid_tiles(node: Unit, debug : bool = false) -> Array[Vector2i]:
	var distance : int = node.stats.movement
	var team: String  = node.team
	
	# Obtain a list of empty grid positions within the move distance of the unit
	var valid_tiles_map : Array[Vector2i] = []
	var tiles_map : Array[Vector2i] = SKTileMap.Instance.get_tiles_in_radius(SKTileMap.Instance.global_to_map(node.global_position), distance)
	for map_tile : Vector2i in tiles_map:
		var current: Unit = SKTileMap.Instance.get_entity_at_position(map_tile)
		if current == null || current == node:
			valid_tiles_map.append(map_tile)
	
	var result: Dictionary = _map_to_grid(valid_tiles_map)
	var grid: Array = result["grid"]
	var conversion : Vector2i = Vector2i(result["x_min"], result["y_min"])
	
	var zoc: Array[Vector2i] = get_team_zoc(team)
	for i : int in range(len(zoc)):
		zoc[i] = zoc[i] - Vector2i(result["x_min"], result["y_min"])
	
	for x : int in range(0, len(grid)):
		for y : int in range(0, len(grid[0])):
			if zoc.find(Vector2i(x, y)) != -1:
				grid[x][y] = -2
			elif grid[x][y] == 1:
				grid[x][y] = -1
			elif grid[x][y] == 0:
				grid[x][y] = -2

	# Perform a flood fill and set any values that are more than the movement distnace away to invalid
	_flood_fill_distance(grid, Vector2i(len(grid) / 2, len(grid[0]) / 2), conversion)
	
	for map_pos : Vector2i in zoc:
		for direction : Vector2i in SKTileMap.get_adjacent_cells(map_pos):
			var neighbor : Vector2i = map_pos + direction
			# If the point is in the grid
			if neighbor.x >= 0 and neighbor.x < len(grid) and neighbor.y >= 0 and neighbor.y < len(grid[0]) \
			and map_pos.x >= 0 and map_pos.x < len(grid) and map_pos.y >= 0 and map_pos.y < len(grid[0]):
				# if it is within range to move into
				if grid[neighbor.x][neighbor.y] < distance and grid[neighbor.x][neighbor.y] > -1:
					grid[map_pos.x][map_pos.y] = distance
			
	# Print the grid for debug
	if debug: _print_grid(grid)

	# map the grid of values back to a list of valid points
	var valid_points_map : Array[Vector2i] = []
	for x : int in range(0, len(grid)):
		for y : int in range(0, len(grid[0])):
			if grid[x][y] < 0:
				continue
			if grid[x][y] > distance:
				continue
			valid_points_map.append(Vector2i(x, y) + Vector2i(result["x_min"], result["y_min"]))
	
	return valid_points_map

# static func _grow(grid: Array) -> void:
# 	var rows: int = grid.size()
# 	var cols: int = grid[0].size()
	
# 	for x : int in range(0, rows):
# 		for y : int in range(0, cols):
# 			if grid[x][y] == 0:
# 				continue

# 			for direction : Vector2 in DIRECTIONS:
# 				var neighbor : Vector2 = Vector2(x, y) + direction
# 				if neighbor.x >= 0 and neighbor.x < rows and neighbor.y >= 0 and neighbor.y < cols:
# 					if grid[neighbor.x][neighbor.y] == 0:
# 						grid[x][y] = 2
	
# 	for x : int in range(0, rows):
# 		for y : int in range(0, cols):
# 			if grid[x][y] == 2:
# 				grid[x][y] = 0

static func _flood_fill_distance(grid: Array, center: Vector2i, conversion : Vector2i) -> void:
	var rows: int = grid.size()
	var cols: int = grid[0].size()

	# Create a queue for flood fill
	var queue: Array[Variant] = []

	# Add the center to the queue
	queue.append(center)
	grid[center.x][center.y] = 0  # Distance at center is 0

	# Define DIRECTIONS for moving up, down, left, right
	#var DIRECTIONS = [Vector2(0, 1), Vector2(1, 0), Vector2(0, -1), Vector2(-1, 0), Vector2(1, 1), Vector2(1, -1), Vector2(-1, 1), Vector2(-1, -1)]

	while queue.size() > 0:
		var current : Vector2i = queue.pop_front()
		var current_distance : int = grid[current.x][current.y]

		for direction : Vector2i in SKTileMap.get_adjacent_cells(current + conversion):
			var neighbor : Vector2i = current + direction
			if neighbor.x >= 0 and neighbor.x < rows and neighbor.y >= 0 and neighbor.y < cols:
				if grid[neighbor.x][neighbor.y] == -1:  # Check if unvisited
					grid[neighbor.x][neighbor.y] = current_distance + 1
					queue.append(neighbor)

static func _print_grid(grid: Array) -> void:
	var rows: int = grid.size()
	var cols: int = grid[0].size()
	for x : int in range(0, rows):
		var string : String = ""
		for y : int in range(0, cols):
			string = string + " " + str(grid[x][y]).lpad(2)

		print(string)
