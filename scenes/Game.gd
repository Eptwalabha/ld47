class_name Game
extends Spatial

onready var current_player : Player = $Player/Player as Player
onready var ui := $UI as UI
onready var player_states = {
	'move': $GameStates/FPS,
	'dialog': $GameStates/Dialog,
	'move-through': $GameStates/MoveThrough,
}

var current_state = 'move'

var triggers := {}

func _ready() -> void:
	ui.capture_mouse()
	$Map/Flat.set_level(Data.flat_level)
	for state_name in player_states:
		var state = player_states[state_name]
		if state is PlayerState:
			state.player = current_player
			state.ui = ui
			state.connect("state_ended", self, "_on_PlayerState_ended", [state_name])

func _physics_process(delta: float) -> void:
	player_states[current_state].physics_process(delta)

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		ui.show_mouse_capture()
	player_states[current_state].process(delta)
	_check_triggers_orientation()
	if player_states[current_state].should_handle_hover():
		_handle_hover()

func _input(event: InputEvent) -> void:
	player_states[current_state].input(event)

func _handle_hover():
	var collider = current_player.get_trigger_hover()
	if collider == null:
		ui.hide_context()
		return
	if Input.is_action_just_pressed("context_action"):
		collider.interact()
	else:
		ui.show_context("hover:%s" % collider.id)

func _check_triggers_orientation() -> void:
	for trigger_id in triggers:
		var trigger = triggers[trigger_id]
		if trigger.is_well_oriented(current_player.head.global_transform.basis):
			active_tp(trigger)
			triggers = {}
			break

func _on_Appartment_door_interacted_with(door: Door) -> void:
	if not Data.phone_picked_up:
		door.close()
		Data.phone_picked_up = true
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

func _on_Appartment_tp_exited(trigger) -> void:
	if triggers.has(trigger.id):
		triggers.erase(trigger.id)

func _on_dialog_triggered(dialog_trigger: DialogTriggerArea) -> void:
	var dialog_id = dialog_trigger.id
	match dialog_id:
		"bar/friend":
			if not Data.friend_intro_bar:
				Data.friend_intro_bar = true
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
	print("end of state '%s'" % state_name)
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
