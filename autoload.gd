extends Node

enum LEVEL {
	FLAT,
	BAR,
	ROAD,
	HOSPITAL
}

const DEBUG : bool = false
const DEBUG_GAME_LEVEL = LEVEL.FLAT
const DEBUG_FLAT_INITIAL_LEVEL : int = 2

const GRAVITY : int = 10
const MAX_GRAVITY : int = 100
const MAX_SLOP : float = deg2rad(15.0)

const FLAT_INITIAL_LEVEL : int = -1

const BAR_DRINK_DELAY_SECOND : float = 10.0

const ROAD_CAR_ACCELERATION : float = 1.0
const ROAD_CAR_SPEED : float = 0.6
const ROAD_CAR_MAX_DRAG : float = -0.005

var first_time : bool = true
var using_controller : bool = false

var flat_level := -1
var phone_picked_up := false

var drinking := false
var friend_intro_bar := false
var friend_wants_to_go_home := false
var door_found := false
var key_found := false
var key_inserted := false
var valve_found := false
var valve_inserted := false

var road_tutorial := false
var road_car_crashed := false
var road_car_speed := 0.0
var road_car_drag := 0.0

func reset_game(level) -> void:
	match level:
		LEVEL.FLAT:
			phone_picked_up = false
			flat_level = FLAT_INITIAL_LEVEL
			if DEBUG:
				flat_level = DEBUG_FLAT_INITIAL_LEVEL
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
			road_car_crashed = false
			road_car_speed = 0.0
			road_car_drag = 0.0

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
	'flat-friend_flat': 'flat_friend_flat',
	'flat-friend_bar': 'friend:dialog_1_friend_02',
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
	'valve_inserted': 'valve_inserted',
	'pick_up_phone_first': 'pick_up_phone_first',
}
