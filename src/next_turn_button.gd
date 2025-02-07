class_name TurnManager extends Button

static var Instance : TurnManager

var current_phase = null
var phases : Array = []

# 
# Public
#		
static func mouse_over(unit : Unit) -> void:
	Instance.mouse_over_instanace(unit)

static func mouse_exit(unit : Unit) -> void:
	Instance.mouse_exit_instanace(unit)
	
static func mouse_pressed(unit : Unit) -> void:
	Instance.mouse_pressed_instanace(unit)

#
# Godot
#
func _enter_tree() -> void:
	Instance = self

func _ready() -> void:
	var player1movement = MovementPhase.new()
	player1movement.team = "player1"
	player1movement.name = "Player 1 Movement"
	phases.append(player1movement)
	
	var player2movement = MovementPhase.new()
	player2movement.team = "player2"
	player2movement.name = "Player 2 Movement"
	phases.append(player2movement)
	
	var pairOffPhase = PairOffPhase.new()
	phases.append(pairOffPhase)
	

func _pressed() -> void:
	var current_index : int = phases.find(current_phase)
	if current_index == len(phases) - 1:
		current_index = 0
	else:
		current_index += 1
		
	if current_phase != null:
		current_phase.end_phase()	
	current_phase = phases[current_index]
	current_phase.start_phase()
	
	%PhaseLabel.text = current_phase.name

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("left_click") and current_phase != null:
		current_phase.mouse_pressed(get_global_mouse_position())

#
# Private
#
func mouse_over_instanace(unit : Unit) -> void:
	if current_phase != null: current_phase.mouse_over(unit)

func mouse_exit_instanace(unit : Unit) -> void:
	if current_phase != null: current_phase.mouse_exit(unit)
	
func mouse_pressed_instanace(unit : Unit) -> void:
	pass
