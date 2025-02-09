class_name SKTileMap extends TileMapLayer

static var Instance : SKTileMap
var layer : Dictionary = {}

func get_entities() -> Array[Node]:
	# Use dictionary as set and cast to array to remove dups
	var entities_dict : Dictionary = {}
	for entry in layer:
		entities_dict[layer[entry]] = null
	
	var entities : Array[Node] = []
	for entity in entities_dict:
		entities.append(entity)
	return entities

func _enter_tree() -> void:
	Instance = self

func add_entity(position: Vector2i, entity: Node) -> void:
	layer[position] = entity

func clear_entity(entity: Node) -> void:
	while true:
		var key = layer.find_key(entity)
		if key == null:
			break
		layer.erase(key)

func get_entity_at_position(position: Vector2i):
	return layer.get(position)

func get_entity_at_position_global(position: Vector2i):
	return get_entity_at_position(global_to_map(position))

func global_to_map(point: Vector2) -> Vector2i:
	return local_to_map(to_local(point))
	
func map_to_global(point: Vector2i) -> Vector2:
	var local = map_to_local(point)
	var global = to_global(local)
	return global
	
func to_map(point: Vector2) -> Vector2:
	return map_to_global(global_to_map(point))

func get_tiles_in_radius_global(center: Vector2, radius: float) -> Array[Vector2]:
	var center_map = global_to_map(center)
	var radius_tiles = ceili((float)(radius) / (float)(tile_set.tile_size.x))
	var tiles_map = get_tiles_in_radius(center_map, radius_tiles)
	var result : Array[Vector2] = []
	for tile in tiles_map:
		result.append(map_to_global(tile))
	return result

func get_tiles_in_radius(center: Vector2i, radius: float) -> Array[Vector2i]:
	var result: Array[Vector2i] = []
	
	var top: int = ceili(center.y - radius)
	var bottom: int = floori(center.y + radius)
	
	for y in range(top, bottom + 1):
		var dy = y - center.y
		var dx = sqrt(radius * radius - dy*dy)
		var left = ceili(center.x - dx)
		var right = floori(center.x + dx)
		for x in range(left, right + 1):
			result.append(Vector2i(x, y))
	
	return result
	
func line(p0 : Vector2i, p1 : Vector2i) -> Array[Vector2i]:
	var points : Array[Vector2i] = []
	var n = diagonal_distance(p0, p1)
	for step in range(0, n + 1):
		var t = 0 if n == 0 else step / n
		points.append(round_point(lerp(Vector2(p0), Vector2(p1), t)))
	return points

func diagonal_distance(p0 : Vector2i, p1 : Vector2i) -> int:
	var dx = p1.x - p0.x
	var dy = p1.y - p0.y
	return maxi(absi(dx), absi(dy))

func round_point(p : Vector2i):
	return Vector2i(roundi(p.x), roundi(p.y))

func get_adjacent_units(map_position : Vector2i) -> Array[Unit]:
	var entities : Array[Unit]= []
	for direction in Movement.DIRECTIONS:
		var entity = SKTileMap.Instance.get_entity_at_position(map_position + direction)
		if entity != null:
			entities.append(entity)
	return entities

static func get_adjacent_units_not_of_team(map_position : Vector2i, team : String) -> Array[Unit]:
	var units : Array[Unit] = []
	for entity in SKTileMap.Instance.get_adjacent_units(map_position):
		if entity.team != team:
			units.append(entity)
	return units

static func get_adjacent_units_of_team(map_position : Vector2i, team : String) -> Array[Unit]:
	var units : Array[Unit] = []
	for entity in SKTileMap.Instance.get_adjacent_units(map_position):
		if entity.team == team:
			units.append(entity)
	return units
