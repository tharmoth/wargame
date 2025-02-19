class_name PanCamera extends Camera2D

static var Instance : PanCamera

var threshold : int = 10
var step : int = 0
var MAX_CAMERA_SPEED : int= 750
var focused : bool = true
@onready var viewport_size : Vector2 = get_viewport().size
var local_mouse_pos : Vector2 = Vector2.ZERO

var use_mouse : bool = true

var velocity_tween : Tween = null

var velocity : Vector2 = Vector2.ZERO
var target_velocity : Vector2 = Vector2.ZERO
var listener : AudioListener2D = AudioListener2D.new()
var audio_size : int = 500

var follow_object : Node2D = null

var tween : Tween = null

func _enter_tree() -> void:
	Instance = self

	
func _ready() -> void:
	get_viewport().size_changed.connect(func() -> void: viewport_size = get_viewport().size)
	add_child(listener)


func _physics_process(delta : float) -> void:
	if not focused:
		return
	
	var d_zoom : Vector2 = zoom
	if Input.is_action_just_released("MWU"):
		zoom *= 1.1
		viewport_size = get_viewport().size
	if Input.is_action_just_released("MWD"):
		zoom /= 1.1
		viewport_size = get_viewport().size
	zoom = clamp(zoom, Vector2(.3, .3), Vector2(3, 3))
	d_zoom -= zoom
	if d_zoom != Vector2.ZERO:
		for audio_player : Node in get_tree().get_nodes_in_group("AudioZoom"):
			audio_player.max_distance = audio_size / zoom.x
	
	if follow_object != null and "position" in follow_object:
		position = follow_object.position
#	if Party.lock_camera:
#		position = Party.party_leader.position
	else:
		move_camera(delta)

func request(point : Vector2) -> void: 
	if tween:
		tween.kill()
	
	tween = create_tween()
	tween.tween_property(self, "position", point, .5)

func move_camera(delta : float) -> void:
	local_mouse_pos = get_local_mouse_position() * zoom
	step = int(MAX_CAMERA_SPEED / zoom.x)
	
	var new_target_velocity : Vector2 = Vector2.ZERO
	# if mouse_near_left(threshold) or Input.is_action_pressed("ui_left"):
	# 	new_target_velocity.x = -step
	# elif mouse_near_right(threshold) or Input.is_action_pressed("ui_right"):
	# 	new_target_velocity.x = step

	# if mouse_near_top(threshold) or Input.is_action_pressed("ui_up"):
	# 	new_target_velocity.y = -step
	# elif mouse_near_bottom(threshold) or Input.is_action_pressed("ui_down"):
	# 	new_target_velocity.y = step

	if Input.is_action_pressed("ui_left") or Input.is_action_pressed("left"):
		new_target_velocity.x = -step
	elif Input.is_action_pressed("ui_right") or Input.is_action_pressed("right"):
		new_target_velocity.x = step

	if Input.is_action_pressed("ui_up") or Input.is_action_pressed("up"):
		new_target_velocity.y = -step
	elif Input.is_action_pressed("ui_down") or Input.is_action_pressed("down"):
		new_target_velocity.y = step
		
	if abs(new_target_velocity.x) > 0:
		if mouse_near_top(threshold * 10):
			new_target_velocity.y = -step
		elif mouse_near_bottom(threshold * 10):
			new_target_velocity.y = step
	elif abs(new_target_velocity.y) > 0:
		if mouse_near_left(threshold * 10):
			new_target_velocity.x = -step
		elif mouse_near_right(threshold * 10):
			new_target_velocity.x = step
	
	new_target_velocity = new_target_velocity.normalized()
	if new_target_velocity != target_velocity:
		target_velocity = new_target_velocity
		if velocity_tween:
			velocity_tween.kill() # Abort the previous animation.
		velocity_tween = create_tween()
#		velocity_tween.set_trans(Tween.TRANS_QUART)
		velocity_tween.tween_property(self, "velocity", target_velocity * step, .2)
	
	position += velocity * delta
	
	position = Vector2(clamp(position.x, -10000, 10000), clamp(position.y, -10000, 10000))

func mouse_near_left(thresh : int) -> bool:
	return local_mouse_pos.x < -(viewport_size.x / 2) + thresh and use_mouse
	
func mouse_near_right(thresh : int) -> bool:
	return local_mouse_pos.x > viewport_size.x / 2 - thresh and use_mouse
	
func mouse_near_top(thresh : int) -> bool:
	return local_mouse_pos.y < -(viewport_size.y / 2) + thresh and use_mouse
	
func mouse_near_bottom(thresh : int) -> bool:
	return local_mouse_pos.y > viewport_size.y / 2 - thresh and use_mouse

func _notification(what : int) -> void:
	if what == MainLoop.NOTIFICATION_APPLICATION_FOCUS_OUT:
		focused = false
	elif what == MainLoop.NOTIFICATION_APPLICATION_FOCUS_IN:
		focused = true
