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

func _check_triggers_orientation() -> void:
	for trigger_id in triggers:
		var trigger = triggers[trigger_id]
		if trigger.is_well_oriented(current_player.head.global_transform.basis):
			active_tp(trigger)
			triggers = {}
			break

func _input(event: InputEvent) -> void:
	player_states[current_state].input(event)

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

func _on_Flat_dialog_triggered(dialog_trigger: DialogTriggerArea) -> void:
	print("request flat's dialog %s" % dialog_trigger.id)

func _on_Bar_dialog_triggered(dialog_trigger: DialogTriggerArea) -> void:
	match dialog_trigger.id:
		"bar/friend":
			if not Data.friend_intro_bar:
				Data.friend_intro_bar = true
				$Map/Bar.show_restroom()
			else:
				print("request bar's dialog with friend")
		var dialog_id:
			print("request bar's dialog %s" % dialog_id)

func _on_Bar_door_interacted_with(door) -> void:
	door.toggle()

func _on_window_triggered(window_trigger: WindowTrigger) -> void:
	move_through(window_trigger)
	window_trigger.through()

func _on_PlayerState_ended(state_name: String) -> void:
	print("end of state '%s'" % state_name)
	change_player_state('move')

func _update_path(path: Array) -> void:
	if not Data.debug:
		return
	var DebugPoint = preload("res://scenes/core/debug/DebugPoint.tscn")
	for n in $Path.get_children():
		n.queue_free()
	for v in path:
		var point = DebugPoint.instance()
		$Path.add_child(point)
		point.global_transform.origin = v

func change_player_state(new_state: String) -> void:
	if current_state != new_state and player_states.has(new_state):
		if current_state != '':
			player_states[current_state].exit()
		current_state = new_state
		player_states[current_state].enter()

func move_through(window: WindowTrigger) -> void:
	var path = window.get_path_points(current_player.global_transform.origin, .3)
	_update_path(path)
	player_states['move-through'].set_route(path)
	change_player_state('move-through')
