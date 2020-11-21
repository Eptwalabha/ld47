class_name Game
extends Spatial

onready var current_player : Player
onready var fps_player : FPSPlayer = $Player/FPSPlayer
onready var car_player : CarPlayer = $Player/CarPlayer
onready var ui := $UI as UI

onready var bar := $Map/Bar as Bar
onready var flat := $Map/Flat as Flat
onready var road := $Map/Road as Road

onready var player_states := {
	'pause-menu': $GameStates/PauseMenu,
	'move': $GameStates/Move,
	'move-drink': $GameStates/MoveDrink,
	'dialog': $GameStates/Dialog,
	'move-through': $GameStates/MoveThrough,
	'animation': $GameStates/Animation,
}
onready var maps := {
	Data.LEVEL.FLAT: flat,
	Data.LEVEL.BAR: bar,
	Data.LEVEL.ROAD: road,
}

var current_state := 'move'
var states_queue := []
var current_map : int = Data.LEVEL.FLAT
var triggers := {}
var game_paused := false

func _ready() -> void:
	_init_level()
	for state_name in player_states:
		var state = player_states[state_name]
		if state is PlayerState:
			state.ui = ui
			state.connect("state_ended", self, "_on_PlayerState_ended", [state_name])

func _init_level() -> void:
	Data.reset_game(Data.LEVEL.FLAT)
	Data.reset_game(Data.LEVEL.BAR)
	Data.reset_game(Data.LEVEL.ROAD)
	Data.reset_game(Data.LEVEL.HOSPITAL)
	ui.hide_context()
	ui.hide_dialog()
	current_state = 'move'
	states_queue = ['move']
	var level_id = Data.LEVEL.FLAT
	if Data.DEBUG:
		level_id = Data.DEBUG_GAME_LEVEL
	current_map = level_id
	game_paused = (current_state == 'pause-menu')
	change_map(level_id)
	if Data.DEBUG:
		current_player.global_transform.origin = maps[current_map].get_start_origin()
		current_player.reset()
		if level_id == Data.LEVEL.ROAD and Data.DEBUG_ENVIRONMENT:
			$AnimationPlayer.play("sunset")

func _physics_process(delta: float) -> void:
	player_states[current_state].physics_process(current_player, delta)

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("reset_level") and Data.DEBUG:
		_init_level()
	player_states[current_state].process(current_player, delta)
	if not game_paused:
		maps[current_map].process(delta)
		_check_triggers_orientation()
		_trigger_hint()

func _input(event: InputEvent) -> void:
	player_states[current_state].input(current_player, event)

func _check_triggers_orientation() -> void:
	for trigger_id in triggers:
		var trigger = triggers[trigger_id]
		if trigger.is_well_oriented(current_player.head.global_transform.basis):
			active_tp(trigger)
			triggers = {}
			break

func _trigger_hint() -> void:
	if player_states[current_state].is_hint_activated():
		var collider = current_player.get_trigger_hover()
		if collider == null:
			ui.hide_context()
		else:
			var collider_id = collider.get_id()
			match collider_id:
				'bar-bartender':
					if not Data.key_found:
						collider_id = "bartender_ask_key"
					elif Data.key_found and not Data.key_inserted:
						collider_id = "bartender_ask_found_key"
					elif Data.key_inserted and not Data.valve_found:
						collider_id = "bartender_ask_handle"
			ui.show_context("hover_%s" % collider_id)

func _on_Flat_door_interacted_with(door: Door) -> void:
	if not Data.phone_picked_up:
		display_dialog('pick_up_phone_first')
	else:
		door.toggle()

func _on_Flat_tp_entered(trigger: TPTrigger) -> void:
	if trigger.is_well_oriented(current_player.head.global_transform.basis):
		active_tp(trigger)
	else:
		triggers[trigger.id] = trigger

func _on_Flat_tp_exited(trigger) -> void:
	if triggers.has(trigger.id):
		# warning-ignore:return_value_discarded
		triggers.erase(trigger.id)

func active_tp(trigger: TPTrigger) -> void:
	_before_tp(trigger)
	var tp_translation = trigger.destination_translation()
	if trigger.id == 'bar-tp':
		tp_translation = bar.start.global_transform.origin - trigger.global_transform.origin
		current_map = Data.LEVEL.BAR
	current_player.force_move(tp_translation)

func _before_tp(trigger: TPTrigger) -> void:
	match trigger.id:
		"bar-tp":
			change_map(Data.LEVEL.BAR)
#			bar.reset()
		"flat-stairs-up":
			Data.flat_level = int(clamp(Data.flat_level + 1, -4, 2))
			flat.set_level(Data.flat_level)
		"flat-stairs-down":
			Data.flat_level = int(clamp(Data.flat_level - 1, -4, 2))
			flat.set_level(Data.flat_level)
		_ : pass

func _on_FPS_context_action_pressed() -> void:
	var collider = current_player.get_trigger_hover()
	if collider is InteractTrigger:
		collider.interact()

func _on_dialog_triggered(dialog_trigger: DialogTriggerArea) -> void:
	var dialog_id = dialog_trigger.id
	match dialog_id:
		"bar-friend":
			if not Data.friend_intro_bar:
				dialog_id = "bar-friend_1"
				bar.show_restroom()
			elif not Data.friend_wants_to_go_home:
				dialog_id = "bar-friend_2"
			else:
				dialog_id = "bar-friend_3"
		"bar-bartender":
			if not Data.key_found:
				dialog_id = "bartender_ask_key"
			elif Data.key_found and not Data.key_inserted:
				dialog_id = "bartender_ask_found_key"
			elif Data.key_inserted and not Data.valve_found:
				dialog_id = "bartender_ask_handle"
	display_dialog(dialog_id)

func _on_Bar_door_interacted_with(door: Door) -> void:
	match door.id:
		'exit-door':
			if not Data.door_found:
				display_dialog('door_is_locked')
			elif Data.door_found and not Data.key_found:
				display_dialog('find_the_key')
			elif Data.key_found and not Data.key_inserted:
				bar.enable_item(bar.ITEMS.EXIT_DOOR_KEY, true)
				current_player.show_item('key', false)
				display_dialog('key_inserted')
			elif Data.key_inserted and not Data.valve_found:
				display_dialog('find_the_valve')
			elif Data.valve_found and not Data.valve_inserted:
				bar.enable_item(bar.ITEMS.EXIT_DOOR_VALVE, true)
				current_player.show_item('key', false)
				display_dialog('valve_inserted')
			else:
				change_map(Data.LEVEL.ROAD)
		_:
			door.toggle()

func _on_window_triggered(window_trigger: WindowTrigger) -> void:
	move_through(window_trigger)
	window_trigger.through()

func _on_PlayerState_ended(_state_name: String) -> void:
	pop_player_state()

func pop_player_state() -> void:
	if len(states_queue) > 0:
		var old_state = states_queue.pop_back()
		player_states[current_state].exit(current_player)
		var previous_state = current_state
		current_state = old_state
		player_states[current_state].resume(current_player, previous_state)

func push_player_state(next_state: String) -> void:
	if current_state != next_state:
		states_queue.push_back(current_state)
		player_states[current_state].pause(current_player, next_state)
		current_state = next_state
		player_states[current_state].enter(current_player)

func change_current_player(player: int) -> void:
	fps_player.visible = (player == Data.PLAYER.FPS)
	car_player.visible = (player == Data.PLAYER.CAR)
	current_player = fps_player if (player == Data.PLAYER.FPS) else car_player
	current_player.make_current()

func change_map(new_map) -> void:
	current_map = new_map
	var new_origin = maps[current_map].get_start_origin()
	match current_map:
		Data.LEVEL.FLAT:
			maps[current_map].reset()
			change_current_player(Data.PLAYER.FPS)
			current_player.global_transform.origin = new_origin
			current_player.reset()
		Data.LEVEL.BAR:
			maps[current_map].reset()
			change_current_player(Data.PLAYER.FPS)
		Data.LEVEL.ROAD:
			maps[current_map].reset()
			change_current_player(Data.PLAYER.CAR)
			current_player.global_transform.origin = new_origin
			current_player.reset()
	for map in maps:
		maps[map].visible = (map == current_map)

func move_through(window: WindowTrigger) -> void:
	var path = window.get_path_points(current_player.global_transform.origin, .3)
	player_states['move-through'].set_route(path)
	push_player_state('move-through')

func display_dialog(dialog_id: String) -> void:
	player_states['dialog'].set_dialog(dialog_id)
	push_player_state('dialog')

func _on_Flat_phone_picked_up() -> void:
	display_dialog("flat-phone")
	current_player.answer_phone()

func _on_Dialog_dialog_ended(dialog_id) -> void:
	pop_player_state()
	match dialog_id:
		'flat-phone':
			Data.phone_picked_up = true
			current_player.hangup_phone()
		'bar-friend_1':
			Data.friend_intro_bar = true
			bar.set_character_animation(bar.CHARACTERS.FRIEND, 'sit-stool-drink')
			drink()
		'bar-friend_2':
			Data.friend_wants_to_go_home = true
			bar.enable_item(bar.ITEMS.EXIT_DOOR, true)
		'door_is_locked':
			Data.door_found = true
			bar.enable_item(bar.ITEMS.KEY, true)
			bar.enable_dialog(bar.CHARACTERS.BARTENDER, true)
			bar.set_character_animation(bar.CHARACTERS.FRIEND, 'sleep')
			drink()
		'key_inserted':
			Data.key_inserted = true
			bar.enable_item(bar.ITEMS.VALVE, true)
			drink()
		'valve_inserted':
			Data.valve_inserted = true

func drink() -> void:
	push_player_state('move-drink')
	push_player_state('animation')
	current_player.force_move_to(bar.drink)
	current_player.drink()

func _on_Player_drink_ended() -> void:
	pop_player_state()

func _on_CarPlayer_bounce_ended() -> void:
	pop_player_state()

func _on_Bar_item_picked_up(item) -> void:
	match item.id:
		'key':
			Data.key_found = true
			bar.enable_item(bar.ITEMS.KEY, false)
			bar.enable_item(bar.ITEMS.VALVE, true)
			current_player.show_item('key', true)
			display_dialog('key_found')
		'valve':
			Data.valve_found = true
			Data.drinking = false
			bar.enable_item(bar.ITEMS.VALVE, false)
			current_player.show_item('valve', true)
			pop_player_state()
			display_dialog('valve_found')
			bar.close_bar()

func _on_Road_car_crashed() -> void:
#	ui.black()
#	ui.show_dot(false)
	change_map(Data.LEVEL.FLAT)

func _on_Road_car_bounced(left: bool) -> void:
	if current_player is CarPlayer:
		push_player_state('animation')
		current_player.bounce(left)

func _on_Night_environment(is_night: bool) -> void:
	if is_night:
		if Data.DEBUG and Data.DEBUG_ENVIRONMENT or not Data.DEBUG:
			$AnimationPlayer.play("sunset")
	else:
		$AnimationPlayer.play("sunrise")

func _on_MoveDrink_drink_timeout() -> void:
	current_player.force_move_to(bar.drink)
	push_player_state('animation')
	current_player.drink()

func _on_UI_game_resumed() -> void:
	game_paused = false
	pop_player_state()

func _on_UI_game_paused() -> void:
	game_paused = true
	push_player_state('pause-menu')
