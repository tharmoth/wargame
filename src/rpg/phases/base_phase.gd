class_name BasePhase

# Public Variables
var team : String = "player1"
var name : String = "Base Phase"

# Public Methods
func start_phase() -> void:
	pass

func end_phase() -> void:
	pass

func mouse_over(unit : Unit) -> void:
	pass

func mouse_exit(unit : Unit) -> void:
	pass
	
func mouse_pressed(global_position : Vector2) -> void:
	pass

func button_pressed() -> void:
	pass

func can_end_phase() -> bool:
	return true
