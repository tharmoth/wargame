class_name Movement

static func get_valid_tiles(node: Node2D, debug : bool = false) -> Array[Vector2]:
	# Obtain a list of empty grid positions within the move distance of the unit
	var valid_tiles_map : Array[Vector2i] = []
	var tiles : Array[Vector2] = SKTileMap.Instance.get_tiles_in_radius_global(node.global_position, 200)
	for tile in tiles:
		var map_tile = SKTileMap.Instance.global_to_map(tile)
		var current = SKTileMap.Instance.get_entity_at_position(map_tile)
		if current == null || current == node:
			valid_tiles_map.append(map_tile)
	
	# find the max and min map coords.
	var x_max : int = Utils.INT_MIN
	var x_min : int = Utils.INT_MAX
	var y_max : int = Utils.INT_MIN
	var y_min : int = Utils.INT_MAX
	for point in valid_tiles_map:
		if point.x > x_max: x_max = point.x
		if point.x < x_min: x_min = point.x
		if point.y > y_max: y_max = point.y
		if point.y < y_min: y_min = point.y
	
	var width : int = x_max - x_min
	var height : int = y_max - y_min
	
	var valid_tiles_map_zeroed : Array[Vector2i]  = []
	for point in valid_tiles_map:
		valid_tiles_map_zeroed.append(point - Vector2i(x_min, y_min))
	
	# Map the list of valid points to a grid based at 0, 0 where valid tiles are 1 and invalid are 0
	var grid : Array = []
	for x in range(0, width + 1):
		var row : Array[int] = []
		for y in range(0, height + 1):
			if valid_tiles_map_zeroed.find(Vector2i(x, y)) == -1:
				row.append(0)
			else:
				row.append(1)
		grid.append(row)

	# Loop over the grid and perform the grow operation a number of times based on the units size
	for i in range(0, 3):
		_grow(grid)
	
	for x in range(0, width + 1):
		for y in range(0, height + 1):
			if grid[x][y] == 1:
				grid[x][y] = -1
			if grid[x][y] == 0:
				grid[x][y] = -2

	# Perform a flood fill and set any values that are more than the movement distnace away to invalid
	_flood_fill_distance(grid, Vector2(width / 2, height / 2))
	
	# Print the grid for debug
	if debug: _print_grid(grid)

	# map the grid of values back to a list of valid points
	var valid_points_map : Array[Vector2i] = []
	for x in range(0, width + 1):
		for y in range(0, height + 1):
			if grid[x][y] < 0:
				continue
			if grid[x][y] > 22:
				continue
			valid_points_map.append(Vector2i(x, y) + Vector2i(x_min, y_min))
	
	# Convert from map coords to global coords
	var valid_points_global : Array[Vector2] = []
	for point in valid_points_map:
		valid_points_global.append(SKTileMap.Instance.map_to_global(point))
	
	return valid_points_global

static func _grow(grid: Array):
	var rows = grid.size()
	var cols = grid[0].size()
	
	# Define directions for moving up, down, left, right
	var directions = [Vector2(0, 1), Vector2(1, 0), Vector2(0, -1), Vector2(-1, 0), Vector2(1, 1), Vector2(1, -1), Vector2(-1, 1), Vector2(-1, -1)]
	
	for x in range(0, rows):
		for y in range(0, cols):
			if grid[x][y] == 0:
				continue

			for direction in directions:
				var neighbor = Vector2(x, y) + direction
				if neighbor.x >= 0 and neighbor.x < rows and neighbor.y >= 0 and neighbor.y < cols:
					if grid[neighbor.x][neighbor.y] == 0:
						grid[x][y] = 2
	
	for x in range(0, rows):
		for y in range(0, cols):
			if grid[x][y] == 2:
				grid[x][y] = 0

static func _flood_fill_distance(grid: Array, center: Vector2):
	var rows = grid.size()
	var cols = grid[0].size()

	# Create a queue for flood fill
	var queue = []

	# Add the center to the queue
	queue.append(center)
	grid[center.x][center.y] = 0  # Distance at center is 0

	# Define directions for moving up, down, left, right
	var directions = [Vector2(0, 1), Vector2(1, 0), Vector2(0, -1), Vector2(-1, 0), Vector2(1, 1), Vector2(1, -1), Vector2(-1, 1), Vector2(-1, -1)]

	while queue.size() > 0:
		var current = queue.pop_front()
		var current_distance = grid[current.x][current.y]

		for direction in directions:
			var neighbor = current + direction
			if neighbor.x >= 0 and neighbor.x < rows and neighbor.y >= 0 and neighbor.y < cols:
				if grid[neighbor.x][neighbor.y] == -1:  # Check if unvisited
					grid[neighbor.x][neighbor.y] = current_distance + 1
					queue.append(neighbor)

static func _print_grid(grid: Array):
	var rows = grid.size()
	var cols = grid[0].size()
	for x in range(0, rows):
		var row : Array[Vector2i] = []
		var string : String = ""
		for y in range(0, cols):
			string = string + " " + str(grid[x][y]).lpad(2)

		print(string)
