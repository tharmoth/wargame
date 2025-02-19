class_name BloodComponent extends Sprite2D

func _init() -> void:
    var rand_value : float = randf()
    if rand_value <= 0.33:
        texture = load("res://data/graphics/particles/dirt_01.png")
    elif rand_value < 0.66:
        texture = load("res://data/graphics/particles/dirt_02.png")
    else:
        texture = load("res://data/graphics/particles/dirt_03.png")
    
    scale = Vector2.ONE * float(randf_range(0.05, 0.2))
    modulate = Utils.BLOOD
    rotation = float(randf_range(0, PI * 2))
    z_index = -1