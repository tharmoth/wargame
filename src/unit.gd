class_name Unit extends Node2D

var highlighted: bool = false
var clickbox_clicked: bool = false
var outline = OutlineComponent.new()
var activate_outline = OutlineComponent.new()
@export var team : String = "Goblin"
var tiles : Array[Vector2i]
var movement_distance : int = 5
var _activated : bool = true

static var selected_unit : Unit = null
static var highlighted_unit : Unit = null

func can_be_activated():
	_activated = false
	activate_outline.highlight()
	
func has_activated():
	_activated = true
	activate_outline.unhighlight()

func _ready() -> void:
	$Clickbox.mouse_entered.connect(_on_mouse_entered)
	$Clickbox.mouse_exited.connect(_on_mouse_exited)
	outline.sprite = $Sprite2D
	activate_outline.sprite = $Sprite2D
	activate_outline.highlight_color = Color.GREEN
	
	call_deferred("add_child", outline)
	call_deferred("add_child", activate_outline)
	
	global_position = SKTileMap.Instance.to_map(global_position)
	add_to_tilemap()
	
	add_to_group("unit")
	
func add_to_tilemap() -> void:
	SKTileMap.Instance.clear_entity(self)
	var map_tile : Vector2i = SKTileMap.Instance.global_to_map(global_position)
	SKTileMap.Instance.add_entity(map_tile, self)

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("left_click"):
		var distance = global_position.distance_to(get_global_mouse_position())
		
		tiles = Movement.get_valid_tiles(self, movement_distance, team, false)
		
		var selected_tile = SKTileMap.Instance.global_to_map(get_global_mouse_position())
		
		if selected_unit == self and tiles.find(selected_tile) != -1:
			global_position = SKTileMap.Instance.to_map(get_global_mouse_position())
			add_to_tilemap()
			has_activated()
			
			selected_unit = null
			outline.deselect()
			selected_unit = null
		elif highlighted and selected_unit == null and not _activated:
			selected_unit = self
			outline.select()
		queue_redraw()

func _on_mouse_entered() -> void:
	highlighted = true
	if selected_unit != null and selected_unit.team != team:
		outline.highlight_color = Utils.RED
	else:
		outline.highlight_color = Utils.BLUE
	outline.highlight()
	highlighted_unit = self
	
func _on_mouse_exited() -> void:
	highlighted = false
	outline.unhighlight()
	if highlighted_unit == self:
		highlighted_unit = null

func _draw() -> void:
	
	if selected_unit == self:
		var enemies = Movement.get_team_zoc(team)
		var line = []
		if highlighted_unit != null:
			var starting = SKTileMap.Instance.global_to_map(global_position)
			var ending = SKTileMap.Instance.global_to_map(highlighted_unit.global_position)
			line = SKTileMap.Instance.line(starting, ending)
		
		for tile_map in tiles:
			if SKTileMap.Instance.get_entity_at_position(tile_map) != null:
				continue
			var color = Utils.BLUE
			if line.find(tile_map) != -1:
				color = Color.YELLOW
			if enemies.find(tile_map) != -1:
				color = Color.RED
			var rect : Rect2 = Rect2(to_local(SKTileMap.Instance.map_to_global(tile_map)) - (Vector2)(SKTileMap.Instance.tile_set.tile_size / 2) , SKTileMap.Instance.tile_set.tile_size)
			draw_rect(rect, color)

		draw_rect(Rect2(Vector2.ZERO - (Vector2)(SKTileMap.Instance.tile_set.tile_size / 2), SKTileMap.Instance.tile_set.tile_size), Color.GREEN)
	
func generate_circle_polygon(radius: float, num_sides: int, position: Vector2) -> PackedVector2Array:
	var angle_delta: float = (PI * 2) / num_sides
	var vector: Vector2 = Vector2(radius, 0)
	var polygon: PackedVector2Array

	for _i in num_sides:
		polygon.append(vector + position)
		vector = vector.rotated(angle_delta)

	return polygon
