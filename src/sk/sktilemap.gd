class_name SKTileMap extends TileMapLayer

static var Instance : SKTileMap
var layer : Dictionary = {}

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
