extends Label

var pos : Vector2i


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("left_click"):
		pos = SKTileMap.Instance.global_to_map(get_global_mouse_position())
	text = str(SKTileMap.Instance.map_distance(pos, SKTileMap.Instance.global_to_map(get_global_mouse_position())))