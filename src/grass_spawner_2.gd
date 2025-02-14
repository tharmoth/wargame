extends Node

@export var node : TileMapLayer
@export var node_to_spawn : Texture2D
@export var enabled : bool = true
@export var grass_coords : Array[Vector2i] = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if not enabled:
		return
	for cell : Vector2i in node.get_used_cells():
		var coords : Vector2i = node.get_cell_atlas_coords(cell)
		var is_grass : bool = coords in grass_coords
		var global_coords : Vector2 = node.to_global(node.map_to_local(cell))
		if true:
			_spawn(global_coords)
			_spawn(global_coords)
			_spawn(global_coords)

func _spawn(global_pos : Vector2) -> void:
	var pos : Vector2 = Vector2(randf_range(-32 / 2.0, 32 / 2.0), randf_range(-32 / 2.0, 32/ 2.0))
	var instance : Sprite2D = Sprite2D.new()
	instance.texture = node_to_spawn
	instance.position = global_pos + pos
	instance.flip_h = randf() > .5
	instance.rotation_degrees = randf_range(-5, 5)
	instance.z_index = 10
	var x_scale : float = randf_range(.75, 1.25)
	var y_scale : float = randf_range(.75, 1.25)
	instance.scale = Vector2(instance.scale.x * x_scale, instance.scale.y * y_scale)
	call_deferred("add_sibling", instance)
