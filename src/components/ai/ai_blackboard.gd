class_name AIBlackboard extends Object

var _blackboard : Dictionary = {}

# GDScript is half baked, so we need to implement our own type system
func get_type() -> String:
    return "AIBlackboard"

func get_value(key : String) -> Variant:
    if _blackboard.has(key):
        return _blackboard[key]
    return null

func set_value(key : String, value : Variant) -> void:
    _blackboard[key] = value