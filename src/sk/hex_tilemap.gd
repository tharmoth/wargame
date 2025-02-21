class_name HexTileMap extends TileMapLayer

const EVEN_DIRECTIONS : Array[Vector2i] = [Vector2i(-1, -1), Vector2i(0, -1), Vector2i(1, -1), Vector2i(1, 0), Vector2i(0, 1),  Vector2i(-1, 0)]
const ODD_DIRECTIONS  : Array[Vector2i] = [Vector2i(-1, 0), Vector2i(0, -1),  Vector2i(1, 0), Vector2i(1, 1), Vector2i(0, 1),  Vector2i(-1, 1)]

func cardinal_between_points(a : Vector2i, b :Vector2i) -> String:
	var direction : Array[Vector2i] = ODD_DIRECTIONS if abs(b.x) % 2 == 1 else EVEN_DIRECTIONS
	
	var index : int = direction.find(a - b)
	var cardinal : String = ""
	match index:
		0:
			cardinal = "nw"
		1:
			cardinal = "n"
		2:
			cardinal = "ne"
		3:
			cardinal = "se"
		4:
			cardinal = "s"
		5:
			cardinal = "sw"
	return cardinal

func global_to_map(point : Vector2) -> Vector2i:
	return local_to_map(to_local(point))

func map_to_global(point : Vector2) -> Vector2:
	return to_global(map_to_local(point))

func to_map(point : Vector2) -> Vector2:
	return map_to_global(global_to_map(point))

static func get_adjacent_cells(cell: Vector2i) -> Array[Vector2i]:
	return ODD_DIRECTIONS if abs(cell.x) % 2 == 1 else EVEN_DIRECTIONS

################################################
#        Hereafter lies funky math             #
# https://www.redblobgames.com/grids/hexagons/ #
################################################
var cube_direction_vectors : Array[Vector3i] = [
	Vector3i(+1, 0, -1), Vector3i(+1, -1, 0), Vector3i(0, -1, +1), 
	Vector3i(-1, 0, +1), Vector3i(-1, +1, 0), Vector3i(0, +1, -1), 
]

func global_map_distance(a : Vector2, b : Vector2) -> int:
	return cube_distance(oddq_to_cube(global_to_map(a)), oddq_to_cube(global_to_map(b)))


func map_distance(a : Vector2i, b : Vector2i) -> int:
	return cube_distance(oddq_to_cube(a), oddq_to_cube(b))


func oddq_to_cube(hex : Vector2i) -> Vector3i:
	var q : int = hex.x
	var r : int = hex.y - (hex.x - (hex.x & 1)) / 2
	# q : x, r : y, s : z
	return Vector3i(q, r, -q-r)


func cube_to_oddq(hex : Vector3i) -> Vector2i:
	var x : int = hex.x
	var y : int = hex.y + (hex.x - (hex.x & 1)) / 2
	return Vector2i(x, y)


func cube_subtract(a : Vector3i, b : Vector3i) -> Vector3i:
	return Vector3i(a.x - b.x, a.y - b.y, a.z - b.z)


func cube_add(a : Vector3i, b : Vector3i) -> Vector3i:
	return Vector3i(a.x + b.x, a.y + b.y, a.z + b.z)


func cube_distance(a : Vector3i, b : Vector3i) -> int:
	var vec : Vector3i = cube_subtract(a, b)
	return (abs(vec.x) + abs(vec.y) + abs(vec.z)) / 2


func cube_direction(direction : int) -> Vector3i:
	return cube_direction_vectors[direction]


func cube_neighbor(cube : Vector3i, direction  : int) -> Vector3i:
	return cube_add(cube, cube_direction(direction))

func map_range(center : Vector2i, radius : int) -> Array[Vector2i]:
	return cube_array_to_oddq(cube_range(oddq_to_cube(center), radius))
	
func map_ring(center : Vector2i, radius : int) -> Array[Vector2i]:
	return cube_array_to_oddq(cube_ring(oddq_to_cube(center), radius))
	
func map_array_to_global(map_points : Array[Vector2i]) -> Array[Vector2]:
	var results : Array[Vector2] = []
	for map_point : Vector2i in map_points:
		results.append(map_to_global(map_point))
	return results
	
func cube_array_to_oddq(cubes : Array[Vector3i]) -> Array[Vector2i]:
	var results : Array[Vector2i] = []
	for cube : Vector3i in cubes:
		results.append(cube_to_oddq(cube))
	return results

func cube_range(center : Vector3i, radius : int) -> Array[Vector3i]:
	var results : Array[Vector3i] = []
	for q : int in range(-radius, radius + 1):
		for r : int in range(max(-radius, -q-radius), min(+radius, -q+radius) + 1):
			var s : int = -q-r
			results.append(cube_add(center, Vector3i(q, r, s)))
	return results


func cube_scale(hex : Vector3i, factor : int) -> Vector3i:
	return Vector3i(hex.x * factor, hex.y * factor, hex.z * factor)


func cube_ring(center : Vector3i, radius : int) -> Array[Vector3i]:
	var results : Array[Vector3i] = []
	# this code doesn't work for radius == 0; can you see why?
	var hex : Vector3i = cube_add(center, cube_scale(cube_direction(4), radius))
	for i : int in range(0, 6):
		for j : int in range(0, radius):
			results.append(hex)
			hex = cube_neighbor(hex, i)
	return results

func cube_round(frac : Vector3) -> Vector3i:
	var x : int = round(frac.x)
	var y : int = round(frac.y)
	var z : int = round(frac.z)
	
	var x_diff : float = abs(x - frac.x)
	var y_diff : float = abs(y - frac.y)
	var z_diff : float = abs(z - frac.z)
	
	if x_diff > y_diff and x_diff > z_diff:
		x = -y-z
	elif y_diff > z_diff:
		y = -x-z
	else:
		z = -x-y
		
	return Vector3i(x, y, z)

func float_lerp(a : float, b : float, t : float) -> float:
	return a + (b - a) * t
	
func cube_lerp(a : Vector3i, b : Vector3i, t : float) -> Vector3:
	return Vector3(float_lerp(a.x, b.x, t), float_lerp(a.y, b.y, t), float_lerp(a.z, b.z, t))

func global_linedraw(global_from : Vector2, global_to : Vector2) -> Array[Vector2]:
	return map_array_to_global(map_linedraw(global_to_map(global_from), global_to_map(global_to)))

func map_linedraw(map_from : Vector2i, map_to : Vector2i) -> Array[Vector2i]:
	return cube_array_to_oddq(cube_linedraw(oddq_to_cube(map_from), oddq_to_cube(map_to)))
	
func cube_linedraw(a : Vector3i, b : Vector3i) -> Array[Vector3i]:
	var n : int = cube_distance(a, b)
	var results : Array[Vector3i] = []
	for i : int in range(0, n):
		results.append(cube_round(cube_lerp(a, b, 1.0/n * i)))
	return results
