extends Node

enum CHAPTER {
	FLAT,
	BAR,
	ROAD,
	HOSPITAL
}

enum GAME_STATE {
	MOVE,
	MOVE_DRINK,
	MOVE_THROUGH,
	DRIVE,
	ANIMATION,
	PAUSE,
	DIALOG,
}

enum PLAYER {
	FPS,
	CAR,
}

const DEBUG : bool = true
const DEBUG_GAME_LEVEL = CHAPTER.ROAD
const DEBUG_FLAT_INITIAL_LEVEL : int = 2
const DEBUG_ENVIRONMENT : bool = true
const DEBUG_ROAD_CONTROL : bool = false

const MOUSE_SENSITIVITY_MIN : float = 0.1
const MOUSE_SENSITIVITY_MAX : float = 0.7

const BUS_VOLUME_MIN : float = -24.0
const BUS_VOLUME_MAX : float = 7.0

const GRAVITY : int = 10
const MAX_GRAVITY : int = 100
const MAX_SLOP : float = deg2rad(15.0)

const FLAT_INITIAL_LEVEL : int = -1

const BAR_DRINK_DELAY_SECOND : float = 10.0

const ROAD_CAR_ACCELERATION : float = 1.0
const ROAD_CAR_SPEED : float = 0.6
const ROAD_CAR_MAX_DRAG : float = -0.001
const ROAD_DISABLE_CAR_DRAG : bool = true

var mouse_sensitivity : float = -.3

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
var road_car_drag := 0.01

func reset_game(level) -> void:
	match level:
		CHAPTER.FLAT:
			phone_picked_up = false
			flat_level = FLAT_INITIAL_LEVEL
			if DEBUG:
				flat_level = DEBUG_FLAT_INITIAL_LEVEL
		CHAPTER.BAR:
			drinking = false
			friend_intro_bar = false
			friend_wants_to_go_home = false
			door_found = false
			key_found = false
			key_inserted = false
			valve_found = false
			valve_inserted = false
		CHAPTER.ROAD:
			road_tutorial = false
			road_car_crashed = false
			road_car_speed = 0.0
			if DEBUG and ROAD_DISABLE_CAR_DRAG:
				road_car_drag = 0.0
			else:
				road_car_drag = ROAD_CAR_MAX_DRAG

func change_mouse_sensitivity(mouse: float) -> void:
	mouse_sensitivity = -lerp(MOUSE_SENSITIVITY_MIN, MOUSE_SENSITIVITY_MAX, mouse)

func get_mouse_sensitivity_amount() -> float:
	return inverse_lerp(MOUSE_SENSITIVITY_MIN, MOUSE_SENSITIVITY_MAX, -mouse_sensitivity)

func change_master_bus_volume(volume: float) -> void:
	var v = lerp(BUS_VOLUME_MIN, BUS_VOLUME_MAX, volume)
	AudioServer.set_bus_volume_db(0, v)
	AudioServer.set_bus_mute(0, volume <= 0.0)

func get_master_bus_amount() -> float:
	return inverse_lerp(BUS_VOLUME_MIN, BUS_VOLUME_MAX, AudioServer.get_bus_volume_db(0))

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
