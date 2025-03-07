extends AudioStreamPlayer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var button : Button = get_parent()
	button.connect("pressed", play)