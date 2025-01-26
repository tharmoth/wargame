class_name OutlineComponent extends Node2D

var sprite: Sprite2D
var _selected: bool = false
var _highlight: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for poly : CollisionPolygon2D in Utils.GeneratePolygon(sprite):
		call_deferred("add_child", poly)
	queue_redraw()
	pass # Replace with function body.'

func select() -> void:
	_selected = true
	queue_redraw()
	
func deselect()-> void:
	_selected = false
	queue_redraw()
	
func highlight() -> void:
	_highlight = true
	queue_redraw()
	
func unhighlight() -> void:
	_highlight = false
	queue_redraw()

func _draw() -> void:
	
	var polys_to_draw = get_children()
	
	for poly in polys_to_draw:
		var adjustedPoly : PackedVector2Array = poly.polygon
		
		for i in range(0, adjustedPoly.size()):
			adjustedPoly.set(i, to_local(poly.to_global(adjustedPoly[i])))
			
		if _selected or _highlight:
			var outline = adjustedPoly
			outline.append(outline[0])
			draw_polyline(outline, Color(0.0, 0.5, 0.5, 1.0), 2.0, true)
	
		if _selected:
			draw_polygon(adjustedPoly, [Color(0.0, 0.5, 0.5, 0.3)])
	
