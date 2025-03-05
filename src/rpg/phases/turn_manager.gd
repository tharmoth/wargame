class_name TurnManager extends Object

static var Instance : TurnManager

var current_phase : BasePhase = null
var player1_phases : Array = []
var player2_phases : Array = []
var next_phase_requested : bool = false
var battle : Battle = Battle.new()
var player1_priority : bool = true

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

static func end_battle() -> void:
	Instance._end_battle()

#
# Godot
#
func _enter_tree() -> void:
	Instance = self

func _ready() -> void:
	var priorityPhase : PriorityPhase = PriorityPhase.new()
	priorityPhase.name = "priority"
	
	var couragePhase : CouragePhase = CouragePhase.new()
	couragePhase.team = "player1"
	couragePhase.name = "courage"

	var player2couragePhase : CouragePhase = CouragePhase.new()
	player2couragePhase.team = "player2"
	player2couragePhase.name = "courage"
	
	var player1movement : MovementPhase = MovementPhase.new()
	player1movement.team = "player1"
	player1movement.name = "movement"
	
	var player2movement : AIMovementPhase = AIMovementPhase.new()
	player2movement.team = "player2"
	player2movement.name = "movement"
	
	var pairOffPhase : PairOffPhase = PairOffPhase.new()
	pairOffPhase.name = "pair"
	
	var player1supportPhase : SupportPhase = SupportPhase.new()
	player1supportPhase.get_combats = pairOffPhase.get_combats
	player1supportPhase.team = "player1"
	player1supportPhase.name = "support"
	
	var player2SupportPhase : AISupportPhase = AISupportPhase.new()
	player2SupportPhase.get_combats = pairOffPhase.get_combats
	player2SupportPhase.team = "player2"
	player2SupportPhase.name = "support"
	
	var fightPhase : FightPhase = FightPhase.new()
	fightPhase.get_combats = pairOffPhase.get_combats
	fightPhase.get_supports1 = player1supportPhase.get_supports
	fightPhase.get_supports2 = player2SupportPhase.get_supports
	fightPhase.name = "fight"
	
	var cleanupPhase : CleanupPhase = CleanupPhase.new()
	cleanupPhase.name = "cleanup"
	
	player1_phases.append(priorityPhase)
	player1_phases.append(couragePhase)
	player1_phases.append(player2couragePhase)
	player1_phases.append(player1movement)
	player1_phases.append(player2movement)
	player1_phases.append(pairOffPhase)
	player1_phases.append(player1supportPhase)
	player1_phases.append(player2SupportPhase)
	player1_phases.append(fightPhase)
	player1_phases.append(cleanupPhase)

	player2_phases.append(priorityPhase)
	player2_phases.append(player2couragePhase)
	player2_phases.append(couragePhase)
	player2_phases.append(player2movement)
	player2_phases.append(player1movement)
	player2_phases.append(pairOffPhase)
	player2_phases.append(player2SupportPhase)
	player2_phases.append(player1supportPhase)
	player2_phases.append(fightPhase)
	player2_phases.append(cleanupPhase)

	battle.player_1_starting_count = WargameUtils.get_units("player1").size()
	battle.player_2_starting_count = WargameUtils.get_units("player2").size()
	
	end_phase()
	
func _pressed() -> void:
	end_phase()

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("left_click") and current_phase != null:
		current_phase.mouse_pressed(SKTileMap.Instance.get_global_mouse_position())
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

	var current_index : int 
	if player1_priority:
		current_index = player1_phases.find(current_phase)
		if current_index == len(player1_phases) - 1:
			current_index = 0
			GUI.play_audio(GUI.Sound.TURN)
		else:
			current_index += 1
	else:
		current_index = player2_phases.find(current_phase)
		if current_index == len(player2_phases) - 1:
			current_index = 0
			GUI.play_audio(GUI.Sound.TURN)
		else:
			current_index += 1
		
	if current_phase != null:
		current_phase.end_phase()
	
	if player1_priority:
		current_phase = player1_phases[current_index]
	else:
		current_phase = player2_phases[current_index]
		
	current_phase.start_phase()
	GUI.set_current_phase(current_phase.name)

func _end_battle() -> void:
	GUI.show_battle_over()
