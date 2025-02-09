class_name Utils

static var FLOAT_MAX : float = 1.79769e308
static var FLOAT_MIN : float = -1.79769e308
static var INT_MAX : int = 9223372036854775807 
static var INT_MIN : int = -9223372036854775808
static var BLUE : Color = Color(0.0, 0.5, 0.5, 1.0)
static var RED : Color = Color.RED

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

static func roll_dice(dice_string : String) -> int:
	var drop_lowest : bool = dice_string.ends_with("l")
	if drop_lowest: dice_string = dice_string.substr(0, dice_string.length() - 1)
	
	var damage : int = 0
	var num_dice_loc : int = dice_string.find("d")
	var num_dice : int = 0
	var dice_loc : int = dice_string.find("+")
	var dice : int = 0
	
	var addition : int = 0
	if num_dice_loc > -1: num_dice = int(dice_string.substr(0, num_dice_loc))
	
	dice = int(dice_string.substr(num_dice_loc + 1, dice_loc - 2)) if dice_loc > -1 else int(dice_string.substr(num_dice_loc + 1))
	
	if dice_loc > -1:
		addition = int(dice_string.substr(dice_loc + 1))
	elif dice_loc == -1 and num_dice_loc == -1:
		damage = int(dice_string)
		
	var rolls : Array[int] = []
	for i in range(0, num_dice):
		rolls.append(randi_range(1, dice))
	if drop_lowest: rolls.remove_at(rolls.find(min(rolls)))
	damage = sum(rolls) + addition
	return damage

static func sum(list):
	var total = 0
	for value in list:
		total = total + value
	return total
