class_name Unit extends Node2D

var highlighted: bool = false
var clickbox_clicked: bool = false
var outline = OutlineComponent.new()
@export var type : String = "Goblin"
var tiles : Array[Vector2]

static var selected_unit : Unit = null

func _ready() -> void:
	$Clickbox.mouse_entered.connect(_on_mouse_entered)
	$Clickbox.mouse_exited.connect(_on_mouse_exited)
	outline.sprite = $Sprite2D
	
	call_deferred("add_child", outline)
	
	global_position = SKTileMap.Instance.to_map(global_position)
	add_to_tilemap()
	
	

func add_to_tilemap() -> void:
	SKTileMap.Instance.clear_entity(self)
	var polygon : PackedVector2Array = $Clickbox/CollisionPolygon2D.polygon
	for i in range(0, polygon.size()):
		polygon.set(i, polygon[i] * $Clickbox/CollisionPolygon2D.scale)
	
	var x_max : float = Utils.FLOAT_MIN
	var x_min : float = Utils.FLOAT_MAX
	var y_max : float = Utils.FLOAT_MIN
	var y_min : float = Utils.FLOAT_MAX
	for point in polygon:
		if point.x > x_max: x_max = point.x
		if point.x < x_min: x_min = point.x
		if point.y > y_max: y_max = point.y
		if point.y < y_min: y_min = point.y
		
	for x in range(x_min, x_max + 1, SKTileMap.Instance.tile_set.tile_size.x):
		for y in range(y_min, y_max + 1, SKTileMap.Instance.tile_set.tile_size.y):
			if !Geometry2D.is_point_in_polygon(Vector2(x, y), polygon): continue
			
			var map_tile : Vector2i = SKTileMap.Instance.global_to_map(global_position + Vector2(x, y))
			
			SKTileMap.Instance.add_entity(map_tile, self)

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("left_click"):
		var distance = global_position.distance_to(get_global_mouse_position())
		
		tiles = Movement.get_valid_tiles(self)
		var valid_tiles : Array[Vector2i] = []
		for tile in tiles:
			var map_tile = SKTileMap.Instance.global_to_map(tile)
			valid_tiles.append(map_tile)
		
		var selected_tile = SKTileMap.Instance.global_to_map(get_global_mouse_position())
		
		if selected_unit == self and valid_tiles.find(selected_tile) != -1:
			global_position = SKTileMap.Instance.to_map(get_global_mouse_position())
			add_to_tilemap()
			
			selected_unit = null
			outline.deselect()
			queue_redraw()
			selected_unit = null
		elif highlighted and selected_unit == null:
			selected_unit = self
			outline.select()
			queue_redraw()

func _on_mouse_entered() -> void:
	highlighted = true
	outline.highlight()
	
func _on_mouse_exited() -> void:
	highlighted = false
	outline.unhighlight()

func _draw() -> void:
	if selected_unit == self:
		for tile in tiles:
			if SKTileMap.Instance.get_entity_at_position(SKTileMap.Instance.global_to_map(tile)) != null:
				continue
			var rect : Rect2 = Rect2(to_local(tile) - (Vector2)(SKTileMap.Instance.tile_set.tile_size / 2) , SKTileMap.Instance.tile_set.tile_size)
			draw_rect(rect, Color(0.0, 0.5, 0.5, 0.5))
		draw_rect(Rect2(Vector2.ZERO - (Vector2)(SKTileMap.Instance.tile_set.tile_size / 2), SKTileMap.Instance.tile_set.tile_size), Color.GREEN)
	
func generate_circle_polygon(radius: float, num_sides: int, position: Vector2) -> PackedVector2Array:
	var angle_delta: float = (PI * 2) / num_sides
	var vector: Vector2 = Vector2(radius, 0)
	var polygon: PackedVector2Array

	for _i in num_sides:
		polygon.append(vector + position)
		vector = vector.rotated(angle_delta)

	return polygon
