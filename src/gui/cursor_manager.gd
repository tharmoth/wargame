class_name CursorManager

static var mouseover_queue : Array[Node2D]

static func mouse_enetered(node: Node2D) -> void:
	mouseover_queue.append(node)
	
static func mouse_exited(node: Node2D) -> void:
	var index: int = mouseover_queue.find(node)
	if index < 0: return
	mouseover_queue.remove_at(index)
