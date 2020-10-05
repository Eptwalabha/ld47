class_name ChapterBar
extends Chapter

onready var bar := $Bar as Bar
onready var player := $Player as Player
onready var ui := $UI as UI
onready var key := $Bar/Key as Key
onready var valve := $Bar/Valve as Valve
onready var corridor := $Bar/BarCorridor as BarCorridor
onready var music := $Music as AudioStreamPlayer3D

var current_state = "move"
var states = {
	'move': MobileState.new(),
	'dialog': DialogState.new(),
	'drink': DrinkState.new(),
}

var reset_player_transform :Transform
var key_picked_up := false
var valve_picked_up := false
var searching := true

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
	_change_state('move')

func end() -> void:
	hide()
	ui.hide()

func start() -> void:
	show()
	ui.reset()
	searching = true
	key_picked_up = false
	valve_picked_up = false
	key.reset()
	valve.reset()
	player.reset()
	corridor.reset()
	current_state = "move"
	$Dancers.show()
	$Music.playing = true
	$Bartender.show()
	AudioServer.set_bus_effect_enabled(3, 0, true)
	for dialog in get_tree().get_nodes_in_group("dialog_trigger"):
		if dialog is DialogTrigger:
			dialog.reset()
	states['move'].searching = true
	states['move'].timer = 10.0

	player.global_transform = reset_player_transform

func process(delta: float) -> void:
	states[current_state].process(delta)

func physics_process(delta: float) -> void:
	states[current_state].physics_process(delta)

func input(event: InputEvent) -> void:
	states[current_state].input(event)

func drink() -> void:
	player.force_move_to($Drink)
	player.drink()
	_change_state('drink')

func _on_player_drink_ended() -> void:
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


class DialogState extends GameState:

	var dialog : DialogTrigger = null

	func set_dialog(d: DialogTrigger) -> void:
		dialog = d

	func enter() -> void:
		player.can_control(false)
		ui.hide_context()
		dialog.start()
# warning-ignore:return_value_discarded
		_print_next_bit()

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


class DrinkState extends GameState:

	func enter() -> void:
		player.velocity.y = 0.0
		player.can_control(false)

class MobileState extends GameState:

	var timer : float = 3.0
	var searching := true

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


func _on_Key_picked_up() -> void:
	key_picked_up = true
	_check_if_player_found_all_items()

func _on_Valve_picked_up() -> void:
	valve_picked_up = true
	_check_if_player_found_all_items()

func _check_if_player_found_all_items() -> void:
	if searching && key_picked_up && valve_picked_up:
		searching = false
		states['move'].searching = false
		ui.blink()
		yield(ui, "blink")
		empty_bar()

func empty_bar() -> void:
	$Dancers.hide()
	$Music.playing = false
	$Bartender.hide()

func _on_BarCorridor_first_entrance() -> void:
	AudioServer.set_bus_effect_enabled(3, 0, false)