class_name TurnManager extends Button

static var Instance : TurnManager

var current_phase : BasePhase = null
var phases : Array = []
var next_phase_requested : bool = false

# 
# Public
#		
static func mouse_over(unit : Unit) -> void:
	Instance._mouse_over(unit)

static func mouse_exit(unit : Unit) -> void:
	Instance._mouse_exit(unit)
	
static func mouse_pressed(unit : Unit) -> void:
	Instance._mouse_pressed(unit)

static func button_pressed() -> void:
	Instance._button_pressed()

static func end_phase() -> void:
	Instance._request_end_phase()

#
# Godot
#
func _enter_tree() -> void:
	Instance = self

func _ready() -> void:
	var player1movement : MovementPhase = MovementPhase.new()
	player1movement.team = "player1"
	player1movement.name = "Player 1 Movement"
	phases.append(player1movement)
	
	var player2movement : AIMovementPhase = AIMovementPhase.new()
	player2movement.team = "player2"
	player2movement.name = "Player 2 Movement"
	phases.append(player2movement)

	# var shootPhase : ShootPhase = ShootPhase.new()
	# shootPhase.team = "player1"
	# shootPhase.name = "Player 1 Shoot"
	# phases.append(shootPhase)
	
	var pairOffPhase : PairOffPhase = PairOffPhase.new()
	pairOffPhase.name = "Pair off"
	phases.append(pairOffPhase)
	
	var supportPhase : SupportPhase = SupportPhase.new()
	supportPhase.get_combats = pairOffPhase.get_combats
	supportPhase.name = "Player 1 Support"
	phases.append(supportPhase)
	
	var supportPhase2 : AISupportPhase = AISupportPhase.new()
	supportPhase2.get_combats = pairOffPhase.get_combats
	supportPhase2.team = "player2"
	supportPhase2.name = "Player 2 Support"
	phases.append(supportPhase2)
	
	var fightPhase : FightPhase = FightPhase.new()
	fightPhase.get_combats = pairOffPhase.get_combats
	fightPhase.get_supports1 = supportPhase.get_supports
	fightPhase.get_supports2 = supportPhase2.get_supports
	fightPhase.name = "Fight"
	phases.append(fightPhase)
	
func _pressed() -> void:
	end_phase()

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("left_click") and current_phase != null:
		current_phase.mouse_pressed(SKTileMap.Instance.get_global_mouse_position())
	disabled = not (current_phase == null or current_phase != null and current_phase.can_end_phase())
	# print(str(next_phase_requested) + " " + str(_all_animations_finished()))
	if next_phase_requested and _all_animations_finished():
		next_phase_requested = false
		_do_end_phase()
		


#
# Private
#
func _mouse_over(unit : Unit) -> void:
	if current_phase != null: current_phase.mouse_over(unit)

func _mouse_exit(unit : Unit) -> void:
	if current_phase != null: current_phase.mouse_exit(unit)
	
func _mouse_pressed(unit : Unit) -> void:
	pass

func _button_pressed() -> void:
	if current_phase != null: current_phase.button_pressed()

func _all_animations_finished() -> bool:
	for unit : Unit in WargameUtils.get_units():
		if unit.is_in_animation():
			return false
	return true

func _request_end_phase() -> void:
	next_phase_requested = true

func _do_end_phase() -> void:
	if current_phase != null and not current_phase.can_end_phase():
		return

	var current_index : int = phases.find(current_phase)
	if current_index == len(phases) - 1:
		current_index = 0
		GUI.play_audio(GUI.Sound.TURN)
	else:
		current_index += 1
		
	if current_phase != null:
		current_phase.end_phase()	
	current_phase = phases[current_index]
	current_phase.start_phase()
	
	%PhaseLabel.text = current_phase.name