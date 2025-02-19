class_name SKTileMap extends TileMapLayer

static var Instance : SKTileMap
var layer : Dictionary = {}

func get_entities() -> Array[Node]:
	# Use dictionary as set and cast to array to remove dups
	var entities_dict : Dictionary = {}
	for entry : Variant in layer:
		entities_dict[layer[entry]] = null
	
	var entities : Array[Node] = []
	for entity : Variant in entities_dict:
		entities.append(entity)
	return entities

func _enter_tree() -> void:
	Instance = self

func add_entity(map_position: Vector2i, entity: Node) -> void:
	layer[map_position] = entity

func clear_entity(entity: Node) -> void:
	while true:
		var key : Variant = layer.find_key(entity)
		if key == null:
			break
		layer.erase(key)

func get_entity_positions(entity: Node) -> Array[Vector2i]:
	var positions : Array[Vector2i] = []
	for entry : Vector2i in layer:
		if layer[entry] == entity:
			positions.append(entry)
	return positions

func get_entity_at_position(map_position: Vector2i) -> Unit:
	if layer.has(map_position):
		return layer.get(map_position)
	return null

func get_entity_at_position_global(map_position: Vector2i) -> Unit:
	return get_entity_at_position(global_to_map(map_position))

func global_to_map(point: Vector2) -> Vector2i:
	return local_to_map(to_local(point))
	
func map_to_global(point: Vector2i) -> Vector2:
	var local : Vector2 = map_to_local(point)
	var global : Vector2 = to_global(local)
	return global
	
func to_map(point: Vector2) -> Vector2:
	return map_to_global(global_to_map(point))

func get_tiles_in_radius_global(center: Vector2, radius: float) -> Array[Vector2]:
	var center_map : Vector2i = global_to_map(center)
	var radius_tiles: int = ceili((float)(radius) / (float)(tile_set.tile_size.x))
	var tiles_map: Array[Vector2i] = get_tiles_in_radius(center_map, radius_tiles)
	var result : Array[Vector2] = []
	for tile : Vector2i in tiles_map:
		result.append(map_to_global(tile))
	return result

func get_tiles_in_radius(center: Vector2i, radius: float) -> Array[Vector2i]:
	var result: Array[Vector2i] = []
	
	var top: int = ceili(center.y - radius)
	var bottom: int = floori(center.y + radius)
	
	for y : int in range(top, bottom + 1):
		var dy: float = y - center.y
		var dx: float = sqrt(radius * radius - dy*dy)
		var left: int = ceili(center.x - dx)
		var right: int = floori(center.x + dx)
		for x : int in range(left, right + 1):
			result.append(Vector2i(x, y))
	
	return result
	
func line(p0 : Vector2i, p1 : Vector2i) -> Array[Vector2i]:
	var points : Array[Vector2i] = []
	var n: int = diagonal_distance(p0, p1)
	for step : int in range(0, n + 1):
		var t: float = 0.0 if n == 0 else float(step) / float(n)
		points.append(round_point(lerp(Vector2(p0), Vector2(p1), t)))
	return points

func diagonal_distance(p0 : Vector2i, p1 : Vector2i) -> int:
	var dx: int = p1.x - p0.x
	var dy: int = p1.y - p0.y
	return maxi(absi(dx), absi(dy))

func round_point(p : Vector2) -> Vector2i:
	return Vector2i(roundi(p.x), roundi(p.y))

func get_adjacent_units(map_position : Vector2i) -> Array[Unit]:
	var entities : Array[Unit] = []
	for direction : Vector2i in Movement.DIRECTIONS:
		var entity: Unit = SKTileMap.Instance.get_entity_at_position(map_position + direction)
		if entity != null:
			entities.append(entity)
	return entities

static func get_adjacent_units_not_of_team(map_position : Vector2i, team : String) -> Array[Unit]:
	var units : Array[Unit] = []
	for entity : Unit in SKTileMap.Instance.get_adjacent_units(map_position):
		if entity.team != team:
			units.append(entity)
	return units

static func get_adjacent_units_of_team(map_position : Vector2i, team : String) -> Array[Unit]:
	var units : Array[Unit] = []
	for entity : Unit in SKTileMap.Instance.get_adjacent_units(map_position):
		if entity.team == team:
			units.append(entity)
	return units
