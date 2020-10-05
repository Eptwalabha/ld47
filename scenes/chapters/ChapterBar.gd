class_name ChapterBar
extends Chapter

onready var bar := $Bar as Bar
onready var player := $Player as Player
onready var ui := $UI as UI
onready var key := $Bar/Key as Key
onready var valve := $Bar/Valve as Valve
onready var corridor := $Bar/BarCorridor as BarCorridor
onready var music := $Music as AudioStreamPlayer3D
onready var friend := $Friend as Character
onready var dialogs := $Bar/Dialogs as Spatial
onready var door := $Bar/Trigger/Door as Door
onready var key_door := $Bar/Trigger/Door/key
onready var car := $Bar/Trigger/Door/CarInside

var current_state = "move"
var states = {
	'move': BarMobileState.new(),
	'dialog': BarDialogState.new(),
	'drink': DrinkState.new(),
	'car': DriveState.new(),
}

var reset_player_transform :Transform
var found_door := false
var key_picked_up := false
var valve_picked_up := false
var searching := true

var nbr_drink = 0
var current_objective = 0

enum OBJECTIVES {
	TALK_FRIEND_IDLE,
	TALK_FRIEND_DRINK,
	FIND_CLOSE_DOOR,
	FIND_KEY,
	PUT_KEY,
	FIND_VALVE,
	PUT_VALVE,
	WAKE_UP,
}


func _ready() -> void:
	hide()
	music.playing = false
	reset_player_transform = player.global_transform
	for state_name in states:
		var state = states[state_name]
		if state is GameState:
			state.player = player
			state.ui = ui
			state.connect("state_ended", self, "_on_State_ended", [state_name])
			state.connect("drink", self, "drink")
# warning-ignore:return_value_discarded
	player.connect("drink_ended", self, "_on_player_drink_ended")
	for trigger in dialogs.get_children():
		if trigger is DialogTrigger:
			trigger.set_active(false)
			
	_change_state('move')
	for trigger in get_tree().get_nodes_in_group("dialog-bar"):
		if trigger is DialogTrigger:
			trigger.connect("dialog_start", self, "_on_Dialog_start")
	
	states['car'].car_transform = $Bar/Trigger/Door/CarInside/Position.global_transform

	friend.show()
	car.reset()
	key_door.hide()

func end() -> void:
	hide()
	ui.hide()

func start() -> void:
	show()
	ui.reset()
	searching = false
	found_door = false
	key_picked_up = false
	valve_picked_up = false
	key.reset()
	valve.reset()
	player.reset()
	corridor.reset()
	door.reset()
	door.locked = true
	door.hide()
	friend.sit_stool_idle()
	friend.show()
	key_door.hide()
	car.hide()
	current_state = "move"
	$Dancers.show()
	$Music.playing = true
	$Bartender.show()
	AudioServer.set_bus_effect_enabled(3, 0, true)
	for dialog in get_tree().get_nodes_in_group("dialog_trigger"):
		if dialog is DialogTrigger:
			dialog.reset()
	current_objective = OBJECTIVES.TALK_FRIEND_IDLE
	prepare_current_objective()

	player.global_transform = reset_player_transform

func active_dialog(nbr: int, nbr2: int = -1) -> void:
	for i in range(dialogs.get_child_count()):
		var trigger = dialogs.get_child(i)
		if trigger is DialogTrigger:
			trigger.set_active(i == nbr || i == nbr2)

func prepare_current_objective() -> void:
	match current_objective:
		OBJECTIVES.TALK_FRIEND_IDLE:
			friend.sit_stool_idle()
			active_dialog(0)
		OBJECTIVES.TALK_FRIEND_DRINK:
			friend.sit_stool_drink()
			active_dialog(1)
		OBJECTIVES.FIND_CLOSE_DOOR:
			friend.sleep()
			active_dialog(2)
			door.show()
		OBJECTIVES.FIND_KEY:
			key.display(true)
			active_dialog(2, 3)
		OBJECTIVES.PUT_KEY:
			active_dialog(2)
		OBJECTIVES.FIND_VALVE:
			valve.display(true)
			active_dialog(2, 4)
		OBJECTIVES.PUT_VALVE:
			active_dialog(2)
			searching = false
			states['move'].searching = false
			ui.blink()
			yield(ui, "blink")
			empty_bar()
		OBJECTIVES.WAKE_UP:
			emit_signal("night_environment", true)
			_change_state('car')
			friend.hide()
			car.show()
			active_dialog(5)
		_:
			pass

func process(delta: float) -> void:
	states[current_state].process(delta)

func physics_process(delta: float) -> void:
	states[current_state].physics_process(delta)

func input(event: InputEvent) -> void:
	states[current_state].input(event)

func drink() -> void:
	player.force_move_to($Drink)
	player.drink()
	states['move'].timer = 10.0
	_change_state('drink')

func _on_player_drink_ended() -> void:
	_change_state('move')

func _on_State_ended(state: String) -> void:
	if state == 'dialog':
		match current_objective:
			OBJECTIVES.TALK_FRIEND_IDLE:
				searching = true
				states['move'].searching = searching
				next_objective()
			OBJECTIVES.TALK_FRIEND_DRINK:
				next_objective()
			OBJECTIVES.WAKE_UP:
				emit_signal('chapter_ended')
			_:
				pass

	if state != 'move':
		_change_state('move')

func _change_state(new_state: String) -> void:
	if current_state != new_state and states.has(new_state):
		if current_state != '':
			states[current_state].exit()
		current_state = new_state
		states[current_state].enter()

class GameState:
# warning-ignore:unused_signal
	signal state_ended
# warning-ignore:unused_signal
	signal drink
	
	var player: Player = null
	var ui : UI = null

	func enter() -> void:
		pass

	func process(_delta: float) -> void:
		pass

	func physics_process(_delta: float) -> void:
		pass

	func input(_event: InputEvent) -> void:
		pass

	func exit() -> void:
		pass


class BarDialogState extends GameState:

	var dialog : Dialog = null

	func set_dialog(d: Dialog) -> void:
		dialog = d

	func enter() -> void:
		player.can_control(false)
		player.velocity = Vector3.ZERO
		ui.hide_context()
		dialog.start()
		var _a = _print_next_bit()

	func process(_delta: float) -> void:
		if Input.is_action_just_pressed("context_action"):
			if not _print_next_bit():
				player.can_control(true)
				ui.hide_dialog()
				emit_signal("state_ended")
	
	func _print_next_bit() -> bool:
		var d = dialog.next()
		if not d.has('what'):
			return false
		ui.display_dialog(d.who, d.what)
		return true

class DriveState extends GameState:
	
	var car_transform : Transform

	func enter() -> void:
		player.global_transform = car_transform
	
	func input(event: InputEvent) -> void:
		player.input(event)
	
	func process(delta: float) -> void:
		if player.ray.is_colliding():
			var collider = player.ray.get_collider()
			if collider is InteractTrigger and collider.active:
				if Input.is_action_just_pressed("context_action"):
					collider.interact()
				else:
					ui.show_context(collider.hover_key)
			else:
				ui.hide_context()
		else:
			ui.hide_context()

class DrinkState extends GameState:

	func enter() -> void:
		player.velocity.y = 0.0
		player.can_control(false)

class BarMobileState extends GameState:

	var timer : float = 3.0
	var searching := false

	func enter() -> void:
		player.can_control(true)

	func physics_process(delta: float) -> void:
		player.physics_process(delta)

	func input(event: InputEvent) -> void:
		player.input(event)

	func process(delta: float) -> void:
		_check_triggers()
		if searching:
			timer = timer - delta
		if timer <= 0:
			timer += 10.0
			ui.blink()
			yield(ui, "blink")
			emit_signal("drink")

	func _check_triggers():
		if player.ray.is_colliding():
			var collider = player.ray.get_collider()
			if collider is InteractTrigger and collider.active:
				if Input.is_action_just_pressed("context_action"):
					collider.interact()
				else:
					ui.show_context(collider.hover_key)
			else:
				ui.hide_context()
		else:
			ui.hide_context()


func _on_Bar_end_of_chapter() -> void:
	emit_signal("chapter_ended")

func next_objective() -> void:
	current_objective += 1
	ui.blink()
	yield(ui, "blink")
	drink()
	prepare_current_objective()

func _on_Key_picked_up() -> void:
	key_picked_up = true
	next_objective()

func _on_Valve_picked_up() -> void:
	valve_picked_up = true
	current_objective += 1
	prepare_current_objective()

func _on_Dialog_start(trigger: DialogTrigger) -> void:
	states['dialog'].dialog = trigger.dialog
	_change_state('dialog')

func empty_bar() -> void:
	$Dancers.hide()
	$Music.playing = false
	$Bartender.hide()

func _on_BarCorridor_first_entrance() -> void:
	AudioServer.set_bus_effect_enabled(3, 0, false)

func _on_Door_door_interacted_with() -> void:
	match current_objective:
		OBJECTIVES.FIND_CLOSE_DOOR:
			next_objective()
		OBJECTIVES.PUT_KEY:
			key_door.show()
			next_objective()
		OBJECTIVES.PUT_VALVE:
			current_objective += 1
			prepare_current_objective()
