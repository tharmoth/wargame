class_name Unit extends Node2D

# Game Data (To be moved?)
@export var team : String = "player1"
var movement_distance : int = 5
var tiles : Array[Vector2i] = []
var fights : Array[Vector2i] = []

# Selection Variables
var can_be_clicked : bool
var outline = OutlineComponent.new()
var activate_outline = OutlineComponent.new()

#
# Public
#
func select() -> void:
	outline.select()
	
func deselect() -> void:
	outline.deselect()

func highlight() -> void:
	outline.highlight()
	
func unhighlight() -> void:
	outline.unhighlight()

func can_activate() -> void:
	activate_outline.highlight()
	
func activated() -> void:
	activate_outline.unhighlight()

func add_to_tilemap() -> void:
	SKTileMap.Instance.clear_entity(self)
	var map_tile : Vector2i = SKTileMap.Instance.global_to_map(global_position)
	SKTileMap.Instance.add_entity(map_tile, self)

func get_map_position() -> Vector2i:
	return SKTileMap.Instance.global_to_map(global_position)
	
func draw_movement(tiles_to_move : Array[Vector2i]) -> void:
	tiles = tiles_to_move
	queue_redraw()

func draw_fights(fights_to_draw : Array[Vector2i]) -> void:
	fights = fights_to_draw
	queue_redraw()

#
# Godot
#
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

func _draw() -> void:
	if not tiles.is_empty():
		var enemies = Movement.get_team_zoc(team)
		
		for tile_map in tiles:
			if SKTileMap.Instance.get_entity_at_position(tile_map) != null:
				continue
			var color = Utils.BLUE
			if enemies.find(tile_map) != -1:
				color = Color.RED
			var rect : Rect2 = Rect2(to_local(SKTileMap.Instance.map_to_global(tile_map)) - (Vector2)(SKTileMap.Instance.tile_set.tile_size / 2) , SKTileMap.Instance.tile_set.tile_size)
			draw_rect(rect, color)

		draw_rect(Rect2(Vector2.ZERO - (Vector2)(SKTileMap.Instance.tile_set.tile_size / 2), SKTileMap.Instance.tile_set.tile_size), Color.GREEN)
	if not fights.is_empty():
		for fight in fights:
			draw_line(Vector2.ZERO, to_local(SKTileMap.Instance.map_to_global(fight)), Color.RED, 10, true)
#
# Private
#
func _on_mouse_pressed() -> void:
	TurnManager.mouse_pressed(self)

func _on_mouse_entered() -> void:
	TurnManager.mouse_over(self)
	
func _on_mouse_exited() -> void:
	TurnManager.mouse_exit(self)
