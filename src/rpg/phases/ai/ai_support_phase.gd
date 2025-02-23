class_name AISupportPhase extends SupportPhase

func _auto_support() -> void:
    super._auto_support()
    var units_to_iterate_over : Array[Unit] = []
    for unit : Unit in _units_to_pair:
        units_to_iterate_over.append(unit)
    for unit : Unit in units_to_iterate_over:
        var unit_to_support : Unit = unit.get_component("AIBlackboard").get_value("supporting")
        if unit_to_support != null:
            _attempt_support(unit_to_support, unit)
