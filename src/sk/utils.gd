class_name Utils

static var FLOAT_MAX : float = 1.79769e308
static var FLOAT_MIN : float = -1.79769e308
static var INT_MAX : int = 9223372036854775807 
static var INT_MIN : int = -9223372036854775808

static func GeneratePolygon(sprite: Sprite2D) -> Array[CollisionPolygon2D]:
	var image = sprite.texture.get_image()
	if sprite.flip_v: image.flip_x()
	if sprite.flip_h: image.flip_x()
	if sprite.region_enabled: image.get_region(sprite.region_rect)
	
	var x: int = roundi(image.get_width() * sprite.scale.x)
	var y: int = roundi(image.get_height() * sprite.scale.y)
	
	image.resize(x, y, Image.INTERPOLATE_NEAREST)
	
	var bitmap = BitMap.new()
	bitmap.create_from_image_alpha(image)

	var polys : Array[PackedVector2Array] = bitmap.opaque_to_polygons(Rect2i(Vector2i.ZERO, image.get_size()), 1)
	var collisionPolygons : Array[CollisionPolygon2D] = []
	for poly in polys:
		pass
		var collisionPolygon = CollisionPolygon2D.new()
		collisionPolygon.polygon = poly
		collisionPolygon.rotation = sprite.rotation
		var copy : PackedVector2Array = collisionPolygon.polygon
		for i in range(0, copy.size()):
			copy.set(i, copy[i] - (Vector2) (image.get_size() / 2))
		collisionPolygon.polygon = copy
		collisionPolygons.append(collisionPolygon)
		
	return collisionPolygons
