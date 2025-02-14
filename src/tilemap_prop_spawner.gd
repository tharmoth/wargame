extends Node2D

@export var textures : Array[Texture2D]
@export var atlas_coords : Array[Vector2i]
@export var target_tilemap : TileMapLayer
@export var noise_seed : int
@export var size_pixels : int = 32
@export var threshold : float = 0.5
@export var density : float = 0.5
@export var use_wind : bool = true
@export var single : bool = false
@export var instances_per_tile : float = 5.0

var _meshes : Array[MultiMesh] = []
var _positions : Array[Dictionary] = []

func _ready() -> void:
    call_deferred("spawn")

func spawn() -> void:
    for texture : Texture2D in textures:
        _generate_multimesh(texture)
    _calculate_positions()
    for multi_mesh : MultiMesh in _meshes:
        var positions : Array[Dictionary] = _positions.filter(func(pos : Dictionary) -> bool: return pos["texture_index"] == _meshes.find(multi_mesh))
        multi_mesh.instance_count = positions.size()
        for index : int in range(0, positions.size()):
            var position : Vector2 = positions[index]["position"]
            var transform : Transform2D = Transform2D.IDENTITY.translated(position).rotated_local(deg_to_rad(randf_range(-10, 10) + 180)).scaled_local(Vector2.ONE * size_pixels * randf_range(0.5, 1.5))
            multi_mesh.set_instance_transform_2d(index, transform)

func _generate_multimesh(texture : Texture2D) -> void:
    var multi_mesh : MultiMesh = MultiMesh.new()
    multi_mesh.transform_format = MultiMesh.TRANSFORM_2D
    multi_mesh.mesh = QuadMesh.new()
    multi_mesh.instance_count = 0
    _meshes.append(multi_mesh)
    
    var multi_mesh_instance : MultiMeshInstance2D = MultiMeshInstance2D.new()
    multi_mesh_instance.multimesh = multi_mesh
    multi_mesh_instance.texture = texture
    multi_mesh_instance.z_index = 1
    if use_wind:
        var matty : ShaderMaterial = ShaderMaterial.new()
        # matty.shader = load("res://src/factory/shaders/wind_sway.gdshader")
        matty.set_shader_parameter("minStrength", 1.0 / 1200.0)
        matty.set_shader_parameter("maxStrength", 1.0 / 800.0)
        matty.set_shader_parameter("detail", 5.0)
        multi_mesh_instance.material = matty
    add_child(multi_mesh_instance)

func _calculate_positions() -> void:
    var small_noise : FastNoiseLite = FastNoiseLite.new()
    small_noise.noise_type = FastNoiseLite.TYPE_SIMPLEX
    small_noise.seed = noise_seed
    small_noise.frequency = 0.005
    small_noise.offset = Vector3(global_position.x, global_position.y, 0)
    
    var big_noise : FastNoiseLite = FastNoiseLite.new()
    big_noise.noise_type = FastNoiseLite.TYPE_SIMPLEX
    big_noise.seed = noise_seed
    big_noise.frequency = 0.0005
    big_noise.offset = Vector3(global_position.x, global_position.y, 0)
    
    var rect : Rect2i = target_tilemap.get_used_rect()
    for y : int in range(rect.position.y, rect.end.y):
        for x : int in range(rect.position.x, rect.end.x):
            var cell : Vector2i = target_tilemap.get_cell_atlas_coords(Vector2i(x, y))
            if not atlas_coords.has(cell):
                continue
            var position : Vector2 = Vector2(x * target_tilemap.tile_set.tile_size.x, y * target_tilemap.tile_set.tile_size.y)
            var noise : float = (Utils.noise_norm(small_noise, position) + Utils.noise_norm(big_noise, position)) / 2.0
            if noise > threshold:
                continue
            _fill_cell(position)

func _fill_cell(position : Vector2) -> void:
    if single:
        var cell_info : Dictionary = {"position": position + Vector2(randf_range(-16, 16), randf_range(-16, 16)), "texture_index": randi() % textures.size()}
        _positions.append(cell_info)
        return
    
    var x_step : float = target_tilemap.tile_set.tile_size.x / instances_per_tile
    var y_step : float = target_tilemap.tile_set.tile_size.y / instances_per_tile
    
    for x : int in range(5, target_tilemap.tile_set.tile_size.x, x_step):
        for y : int in range(5, target_tilemap.tile_set.tile_size.y, y_step):
            if randf() > density:
                continue
            var pos : Vector2 = position + Vector2(x + randf_range(-x_step, x_step), y + randf_range(-y_step, y_step))
            var cell_info : Dictionary = {"position": pos, "texture_index": randi() % textures.size()}
            _positions.append(cell_info)
