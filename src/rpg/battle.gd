class_name Battle extends Object

var player_1_starting_count : int = 0
var player_2_starting_count : int = 0

var player_1_broken : bool = false
var player_2_broken : bool = false

func get_starting_count(player : int) -> int:
    if player == 1:
        return player_1_starting_count
    else:
        return player_2_starting_count