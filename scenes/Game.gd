class_name Game
extends Spatial

onready var current_player : Player = $Player/Player as Player
onready var ui := $UI as UI
onready var player_states = {
	'move': $GameStates/FPS,
	'dialog': $GameStates/Dialog,
	'move-through': $GameStates/MoveThrough,
	'animation': $GameStates/Animation,
}
onready var timer := $Timer as Timer

var current_state = 'move'

var triggers := {}

func _ready() -> void:
	ui.capture_mouse()
	$Map/Flat.reset()
	if Data.debug:
		_init_debug()
	for state_name in player_states:
		var state = player_states[state_name]
		if state is PlayerState:
			state.player = current_player
			state.ui = ui
			state.connect("state_ended", self, "_on_PlayerState_ended", [state_name])

func _init_debug() -> void:
	match Data.debug_level:
		Data.LEVEL.BAR:
			$Map/Flat.hide()
			current_player.global_transform.origin = $Map/Bar.start.global_transform.origin
			current_player.reset()
			$Map/Bar.reset()
		_:
			pass

func _physics_process(delta: float) -> void:
	player_states[current_state].physics_process(delta)

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		ui.show_mouse_capture()
	if Input.is_action_just_pressed("reset_level") and Data.debug:
		_init_debug()
	player_states[current_state].process(delta)
	_check_triggers_orientation()
	_trigger_hint()

func _input(event: InputEvent) -> void:
	player_states[current_state].input(event)

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
			ui.show_context("hover_%s" % collider.id)

func _on_Appartment_door_interacted_with(door: Door) -> void:
	if not Data.phone_picked_up:
		display_dialog('pick_up_phone_first')
	else:
		door.toggle()

func _on_Appartment_tp_entered(trigger: TPTrigger) -> void:
	if trigger.is_well_oriented(current_player.head.global_transform.basis):
		active_tp(trigger)
	else:
		triggers[trigger.id] = trigger

func active_tp(trigger: TPTrigger) -> void:
	_before_tp(trigger)
	current_player.force_move(trigger.destination_translation())
	_after_tp(trigger)

func _before_tp(trigger: TPTrigger) -> void:
	match trigger.id:
		"bar/tp":
			$Map/Bar.show()
		"flat/stairs-up":
			Data.flat_level = int(clamp(Data.flat_level + 1, -4, 2))
			$Map/Flat.set_level(Data.flat_level)
		"flat/stairs-down":
			Data.flat_level = int(clamp(Data.flat_level - 1, -4, 2))
			$Map/Flat.set_level(Data.flat_level)
		_ : pass

func _after_tp(trigger: TPTrigger) -> void:
	match trigger.id:
		"bar/tp":
			$Map/Flat.hide()
		_: pass

func _on_FPS_context_action_pressed() -> void:
	var collider = current_player.get_trigger_hover()
	if collider is InteractTrigger:
		collider.interact()

func _on_Appartment_tp_exited(trigger) -> void:
	if triggers.has(trigger.id):
		triggers.erase(trigger.id)

func _on_dialog_triggered(dialog_trigger: DialogTriggerArea) -> void:
	var dialog_id = dialog_trigger.id
	match dialog_id:
		"bar/friend":
			dialog_id = "bar/friend_1"
			if not Data.friend_intro_bar:
				$Map/Bar.show_restroom()
		_:
			pass
	print("request dialog %s" % dialog_id)
	display_dialog(dialog_id)

func _on_Bar_door_interacted_with(door) -> void:
	door.toggle()

func _on_window_triggered(window_trigger: WindowTrigger) -> void:
	move_through(window_trigger)
	window_trigger.through()

func _on_PlayerState_ended(state_name: String) -> void:
	change_player_state('move')

func change_player_state(new_state: String) -> void:
	if current_state != new_state and player_states.has(new_state):
		if current_state != '':
			player_states[current_state].exit()
		current_state = new_state
		player_states[current_state].enter()

func move_through(window: WindowTrigger) -> void:
	var path = window.get_path_points(current_player.global_transform.origin, .3)
	player_states['move-through'].set_route(path)
	change_player_state('move-through')

func display_dialog(dialog_id: String) -> void:
	player_states['dialog'].set_dialog(dialog_id)
	change_player_state('dialog')

func _on_Flat_phone_picked_up() -> void:
	display_dialog("flat/phone")
	current_player.answer_phone()

func _on_Dialog_dialog_ended(dialog_id) -> void:
	var next_state = 'move'
	match dialog_id:
		'flat/phone':
			Data.phone_picked_up = true
			current_player.hangup_phone()
		'bar/friend_1':
			if not Data.friend_intro_bar:
				Data.friend_intro_bar = true
				drink()
				return
		_:
			print("dialog %s" % dialog_id)
	change_player_state(next_state)

func drink() -> void:
	change_player_state('animation')
	current_player.force_move_to($Map/Bar.drink)
	current_player.drink()

func _on_Player_drink_ended() -> void:
	change_player_state('move')
	if Data.friend_intro_bar and not Data.valve_found:
		timer.start(Data.drink_delay)

func _on_Timer_timeout() -> void:
	drink()
