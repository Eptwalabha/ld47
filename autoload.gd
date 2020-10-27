extends Node

enum LEVEL {
	HOME,
	BAR,
	ROAD,
	HOSPITAL
}

var first_time : bool = true
var using_controller : bool = false
var debug : bool = false
var first_level : int = LEVEL.BAR

var phone_picked_up := false
var friend_intro_bar := false
var friend_wants_to_go_home := false
var door_found := false
var key_found := false
var missing_handle := false
var valve_found := false
var road_tutorial := false

func reset_game(level: String) -> void:
	match level:
		'flat':
			phone_picked_up = false
		'bar':
			friend_intro_bar = false
			friend_wants_to_go_home = false
			door_found = false
			key_found = false
			missing_handle = false
			valve_found = false
		'road':
			road_tutorial = false
