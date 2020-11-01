extends Node

enum LEVEL {
	HOME,
	BAR,
	ROAD,
	HOSPITAL
}

var first_time : bool = true
var using_controller : bool = false
var debug : bool = true
var first_level : int = LEVEL.BAR

var flat_level := 0
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
			flat_level = 0
		'bar':
			friend_intro_bar = false
			friend_wants_to_go_home = false
			door_found = false
			key_found = false
			missing_handle = false
			valve_found = false
		'road':
			road_tutorial = false

var dialogs = {
	'flat/plant': 'flat_plant',
	'flat/bouncer': {
		'seq': [
			'flat_bouncer_line_1',
			'flat_bouncer_line_2',
			'flat_bouncer_line_3'
		]
	},
	'flat/friend-flat': 'flat_friend_flat',
	'flat/friend-bar': 'flat_friend_bar',
	'bar/friend': 'test:bar_friend',
	'bar/bartender': {
		'if_keys': 'bar_bartender_ask_keys',
		'if_valve': 'bar_bartender_ask_valve',
	}
}
