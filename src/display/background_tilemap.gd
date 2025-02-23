extends TileMapLayer


func _ready() -> void:
	var dimensions : Vector2i = get_used_rect().size
	var tile_size : Vector2 = tile_set.tile_size

	var dimensions_pixels : Vector2 = Vector2(dimensions) * tile_size

	for x : int in range(0, dimensions_pixels.x, 512):
		for y : int in range(0, dimensions_pixels.y, 512):
			var sprite : Sprite2D = Sprite2D.new()
			sprite.texture = preload("res://data/textures/soil3.png")
			# sprite.centered = false
			sprite.position = Vector2(x + 256 , y + 256)
			# sprite.rotation_degrees = [0, 90, 180, 270][randi() % 4]
			call_deferred("add_child", sprite)
