extends Node

enum LEVEL {
	FLAT,
	BAR,
	ROAD,
	HOSPITAL
}

var debug : bool = true
var debug_level = LEVEL.BAR

var first_time : bool = true
var using_controller : bool = false

var drink_delay := 20.0
var flat_level := 0
var drinking := false
var phone_picked_up := false
var friend_intro_bar := false
var friend_wants_to_go_home := false
var door_found := false
var key_found := false
var key_inserted := false
var valve_found := false
var valve_inserted := false
var road_tutorial := false

func reset_game(level) -> void:
	match level:
		LEVEL.FLAT:
			phone_picked_up = false
			flat_level = 0
		LEVEL.BAR:
			drinking = false
			friend_intro_bar = false
			friend_wants_to_go_home = false
			door_found = false
			key_found = false
			key_inserted = false
			valve_found = false
			valve_inserted = false
		LEVEL.ROAD:
			road_tutorial = false

var dialogs = {
	'flat-plant': 'flat_plant',
	'flat-phone': {
		'text': [
			'voice_mail:dialog_1_phone_01',
			'friend:dialog_1_phone_02',
			'friend:dialog_1_phone_03',
		],
	},
	'flat-bouncer': {
		'text': [
			'bouncer:dialog_1_bouncer_01',
			'bouncer:dialog_1_bouncer_02',
			'bouncer:dialog_1_bouncer_03',
		],
	},
	'flat-friend-flat': 'flat_friend_flat',
	'flat-friend-bar': 'friend:dialog_1_friend_02',
	'bar-friend_1': {
		'text': [
			'friend:dialog_2_01',
			'friend:dialog_2_02',
		],
	},
	'bar-friend_2': 'friend:dialog_2_03',
	'bar-friend_3': 'friend:dialog_2_04',
	'bartender_ask_key': 'bartender:dialog_02_bartender_01',
	'bartender_ask_found_key': 'bartender:bartender_ask_found_key',
	'bartender_ask_handle': {
		'text': [
			'bartender:dialog_02_bartender_02',
			'bartender:dialog_02_bartender_03',
		],
	},
	'door_is_locked': {
		'text': [
			'door_is_locked',
			'bartender:drink_call',
		],
	},
	'find_the_key': 'find_the_key',
	'find_the_valve': 'find_the_valve',
	'key_inserted': {
		'text': [
			'key_inserted',
			'missing_handle',
			'bartender:drink_call'
		]
	},
	'valve_inserted': 'key_inserted',
}
