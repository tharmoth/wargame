class_name Unit extends Node2D

# Game Data (To be moved?)
@export var team : String = "player1"

@export var stats : Stats = Stats.new()
var tiles : Array[Vector2i] = []
var fights : Array[Vector2i] = []
var supports : Array[Vector2i] = []
var shots : Array[Vector2i] = []

# Selection Variables
var can_be_clicked : bool
var outline : OutlineComponent = OutlineComponent.new()
var activate_outline : OutlineComponent = OutlineComponent.new()

var _target_position : Vector2 = Vector2.ZERO
var animating : bool = false

var _bob_tween : Tween = null
@onready var _body_sprite : Sprite2D = $Sprite2D

var _move_tween : Tween = null

var _components : Array[Variant] = []

#
# Public
#
func add_component(component : Variant) -> void:
    _components.append(component)
    if component is Node:
        var node : Node = component
        add_child(node)

func remove_component(component : Variant) -> void:
    if _components.find(component) != -1:
        _components.remove_at(_components.find(component))
    if component is Node and component.get_parent() == self:
        var node : Node = component
        remove_child(node)

func get_component(type : String) -> Variant:
    for component : Variant in _components:
        print(component.get_type())
        if component.get_type() == type:
            return component
    return null

func get_components(type : String) -> Array[Variant]:
    var components : Array[Variant] = []
    for component : Variant in _components:
        if component.get_class() == type:
            components.append(component)
    return components

func kill() -> void:
    SKTileMap.Instance.clear_entity(self)
    if _bob_tween != null:
        _bob_tween.kill()
    
    let_the_bodies_hit_the_floor(_body_sprite)

    queue_free()

func flee() -> void:
    var target : Vector2i = get_map_position()
    SKTileMap.Instance.clear_entity(self)
    if team == "player1":
        target = Vector2i(-1, target.y + randi_range(-20, 20))
    else:
        target = Vector2i(49, target.y + randi_range(-20, 20))
    move_to(target)
    remove_from_group("unit")
    get_tree().create_timer(15).connect("timeout", queue_free)

func select() -> void:
    outline.select()
    
func deselect() -> void:
    outline.deselect()

func highlight() -> void:
    outline.highlight()
    
func unhighlight() -> void:
    outline.unhighlight()

func can_activate() -> void:
    activate_outline.highlight()
    
func activated() -> void:
    activate_outline.unhighlight()

func move_to(map_position : Vector2i) -> void:
    if SKTileMap.Instance.get_entity_at_position(map_position) != null and map_position != get_map_position():
        printerr("Can't move to occupied tile!")
        return

    var distance_map : float = SKTileMap.Instance.global_to_map(global_position).distance_to(map_position)

    _target_position = SKTileMap.Instance.map_to_global(map_position)
    # global_position = SKTileMap.Instance.map_to_global(map_position)
    SKTileMap.Instance.clear_entity(self)
    SKTileMap.Instance.add_entity(map_position, self)
    animating = true

    _body_sprite.flip_h = _target_position.x < global_position.x;
    
    if _move_tween != null:
        _move_tween.kill()
    _move_tween = _body_sprite.create_tween()
    _move_tween.tween_property(self, "global_position", _target_position, 0.5 * distance_map);

func get_map_position() -> Vector2i:
    return SKTileMap.Instance.get_entity_positions(self)[0]
    
func draw_movement(tiles_to_move : Array[Vector2i]) -> void:
    tiles = tiles_to_move
    queue_redraw()

func draw_fights(fights_to_draw : Array[Vector2i]) -> void:
    fights = fights_to_draw
    queue_redraw()

func draw_supports(supports_to_draw : Array[Vector2i]) -> void:
    supports = supports_to_draw
    queue_redraw()

func draw_shot(line_to_draw : Array[Vector2i]) -> void:
    shots = line_to_draw
    queue_redraw()

func is_in_melee() -> bool:
    var adjacent : Array[Unit] = SKTileMap.get_adjacent_units_not_of_team(get_map_position(), team)
    return not adjacent.is_empty()

func is_in_animation() -> bool:
    return animating

#
# Godot
#
func _ready() -> void:
    $Clickbox.mouse_entered.connect(_on_mouse_entered)
    $Clickbox.mouse_exited.connect(_on_mouse_exited)
    outline.sprite = $Sprite2D
    activate_outline.sprite = $Sprite2D
    var color : Color = Color.GREEN
    color.a = .25
    activate_outline.highlight_color = color
    
    call_deferred("add_child", outline)
    call_deferred("add_child", activate_outline)
    
    move_to(SKTileMap.Instance.global_to_map(global_position))
    
    add_to_group("unit")

    var blackboard : AIBlackboard = AIBlackboard.new()
    add_component(blackboard)

func _process(delta : float) -> void:
    if global_position != _target_position:
        _play_movement_animation()
        global_position = lerp(global_position, _target_position, .1)
        if global_position.distance_to(_target_position) < 1:
            global_position = _target_position
            animating = false
    else:
        animating = false

func _draw() -> void:
    if not tiles.is_empty():
        var enemies : Array[Vector2i] = Movement.get_team_zoc(team)
        
        for tile_map : Vector2i in tiles:
            if SKTileMap.Instance.get_entity_at_position(tile_map) != null:
                continue
            var color : Color = Utils.BLUE
            if enemies.find(tile_map) != -1:
                color = Color.RED
            var rect : Rect2 = Rect2(to_local(SKTileMap.Instance.map_to_global(tile_map)) - (Vector2)(SKTileMap.Instance.tile_set.tile_size / 2) , SKTileMap.Instance.tile_set.tile_size)
            draw_rect(rect, color)

        draw_rect(Rect2(Vector2.ZERO - (Vector2)(SKTileMap.Instance.tile_set.tile_size / 2), SKTileMap.Instance.tile_set.tile_size), Color.GREEN)
    # for fight : Vector2i in fights:
    # 	draw_line(Vector2.ZERO, to_local(SKTileMap.Instance.map_to_global(fight)), Color.RED, 10, true)
    for support : Vector2i in supports:
        var target_pos : Vector2 = to_local(SKTileMap.Instance.map_to_global(support))
        var start : Vector2 = Vector2.ZERO + target_pos / 10 + Vector2.DOWN * 16
        var end : Vector2 = target_pos - target_pos / 10 + Vector2.DOWN * 16
        var point : Vector2 = Vector2(0, -15)

        var curve : Curve2D = Curve2D.new()
        curve.add_point(start, point, point)
        curve.add_point(end, point, point)

        var curve_points : PackedVector2Array = curve.tessellate()
        for index : int in len(curve_points) - 1:
            draw_line(curve_points[index], curve_points[index + 1], Color.BLACK, 7)
        for index : int in len(curve_points) - 1:
            draw_line(curve_points[index], curve_points[index + 1], Color.YELLOW, 3)

    for shot : Vector2i in shots:
        var rect : Rect2 = Rect2(to_local(SKTileMap.Instance.map_to_global(shot)) - (Vector2)(SKTileMap.Instance.tile_set.tile_size / 2) , SKTileMap.Instance.tile_set.tile_size)
        draw_rect(rect, Utils.BLUE)


    for fight : Vector2i in fights:
        var target_pos : Vector2 = to_local(SKTileMap.Instance.map_to_global(fight))
        var start : Vector2 = Vector2.ZERO + target_pos / 10 + Vector2.DOWN * 16
        var end : Vector2 = target_pos - target_pos / 10 + Vector2.DOWN * 16
        var point : Vector2 = Vector2(0, -15)

        var curve : Curve2D = Curve2D.new()
        curve.add_point(start, point, point)
        curve.add_point(end, point, point)

        var curve_points : PackedVector2Array = curve.tessellate()

        for index : int in len(curve_points) - 1:
            draw_line(curve_points[index], curve_points[index + 1], Color.BLACK, 7)
        for index : int in len(curve_points) - 1:
            draw_line(curve_points[index], curve_points[index + 1], Utils.RED, 3)

# Private
#
func _on_mouse_pressed() -> void:
    TurnManager.mouse_pressed(self)

func _on_mouse_entered() -> void:
    TurnManager.mouse_over(self)
    
func _on_mouse_exited() -> void:
    TurnManager.mouse_exit(self)

# Plays a walking animation that bobs the sprite up and down.
func _play_movement_animation(speed_mult: float = 1.0) -> void:
    if _bob_tween != null and _bob_tween.is_running():
        return
    if _bob_tween != null:
        _bob_tween.kill()
    _bob_tween = _body_sprite.create_tween()
    _bob_tween.set_trans(Tween.TRANS_SINE)
    _bob_tween.tween_property(_body_sprite, "position", Vector2(0, -7.5), (0.5 / speed_mult) / 2)
    _bob_tween.tween_callback(_play_walk_sound)
    _bob_tween.tween_property(_body_sprite, "position", Vector2(0, 0), (0.5 / speed_mult) / 2)

func _play_walk_sound() -> void:
    GUI.play_audio(GUI.Sound.WALK)

static func let_the_bodies_hit_the_floor(sprite: Sprite2D) -> void:
    var animation_time: float = 0.5
    
    var pos: Vector2 = sprite.global_position
    var parent : Node2D = sprite.get_parent().get_parent()

    sprite.get_parent().remove_child(sprite)
    parent.add_child(sprite)
    sprite.global_position = pos
    # sprite.modulate = Color(0.5, 0.5, 0.5)
    sprite.z_index = -1

    var random_pos: Vector2 = Vector2(randf_range(-16, 16), randf_range(8, 16)) 
    # - pos.direction_to(Globals.player.global_position) * 30 + Vector2.DOWN * 10
    var target_pos: Vector2 = pos + random_pos
    var target_degrees: float = -90 + randf_range(-10, 10) if random_pos.x < 0 else 90 + randf_range(-10, 10)

    var knock_back_tween: Tween = sprite.create_tween()
    knock_back_tween.set_trans(Tween.TRANS_SINE)
    knock_back_tween.tween_property(sprite, "global_position", target_pos, animation_time)

    var death_rotation_tween: Tween = sprite.create_tween()
    death_rotation_tween.set_trans(Tween.TRANS_QUAD)
    death_rotation_tween.set_ease(Tween.EASE_IN)
    death_rotation_tween.tween_property(sprite, "rotation_degrees", target_degrees, animation_time)

    var color_tween: Tween = sprite.create_tween()
    var target_color : Color = Color(0.5, 0.5, 0.5, 0.5)
    color_tween.tween_property(sprite, "modulate", target_color, animation_time)
    # death_rotation_tween.tween_callback(Callable.new(self, "_on_death_rotation_tween_completed").bind(sprite, target_pos))

# func _on_death_rotation_tween_completed(sprite: Sprite2D, target_pos: Vector2) -> void:
#     var container: ItemContainer = ItemContainer.new(false)
#     sprite.reparent(container)
#     sprite.position = Vector2.ZERO
#     # sprite.rotation_degrees = 0
#     Globals.level_scene.add_child(container)
#     container.global_position = target_pos
    # container.global_rotation_degrees = target_degrees
