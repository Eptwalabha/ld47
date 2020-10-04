class_name Game
extends Spatial

onready var ui := $UI as UI
onready var appartment := $Appartment as Appartment
onready var street := $StreetLevel as Spatial
onready var player := $Player as Player
onready var road := $Road
onready var tween_move_player := $Appartment/MovePlayer as Tween

var lvl = -1
var player_is_inside = true
var current_state = ""
var states = {
	'move': MobileState.new(),
	'dialog': DialogState.new(),
}

func _ready() -> void:
	reset_game()
	for state_name in states:
		var state = states[state_name]
		if state is GameState:
			state.player = player
			state.ui = ui
			state.connect("state_ended", self, "_on_State_ended", [state_name])

	_change_state('move')

	for trigger in get_tree().get_nodes_in_group("dialog_trigger"):
		if trigger is DialogTrigger:
			trigger.connect("dialog_start", self, "_on_Dialog_start")
#			trigger.connect("dialog_end", self, "_on_Dialog_end")
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _process(delta: float) -> void:
	states[current_state].process(delta)
	if Input.is_action_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		get_tree().quit()

func _physics_process(delta: float) -> void:
	states[current_state].physics_process(delta)

func _input(event: InputEvent) -> void:
	states[current_state].input(event)

func _on_Area_body_entered(body: Node) -> void:
	if body is KinematicBody:
		get_tree().reload_current_scene()

func _on_TPDown_body_entered(body: Node) -> void:
	if body is Player:
		_update_back_building(-1)
		_tp_player(Vector3(0, 2.5, 0), body)

func _on_TPUp_body_entered(body: Node) -> void:
	if body is Player:
		_update_back_building(1)
		_tp_player(Vector3(0, -2.5, 0), body)

func _tp_player(direction: Vector3, player: Player) -> void:
	player.force_move(direction)

func _update_back_building(amount: int) -> void:
		var next_lvl = clamp(lvl + amount, -4, 2)
		if lvl != next_lvl:
			street.translate(Vector3(0, 2.5, 0) * amount)
		lvl = next_lvl
		appartment.set_level(lvl)

func reset_game() -> void:
	lvl = 2
#	lvl = -2
	player_is_inside = true
	appartment.set_level(lvl)
	street.translation = Vector3(0, 2.5 * lvl, 0)
#	$Phone.ring()


func _on_BackStreetBuilding_go_to(place) -> void:
	if player_is_inside:
		player_is_inside = false
		_move_player_from_to($Appartment/In, $Appartment/Out)
	else:
		player_is_inside = true
		_move_player_from_to($Appartment/Out, $Appartment/In)

func _move_player_from_to(from: Spatial, to: Spatial) -> void:
	player.can_control(false)
	player.move_through_window()
	tween_move_player.interpolate_property(
		player,
		"translation",
		player.global_transform.origin,
		to.global_transform.origin,
		.8,
		Tween.TRANS_QUAD,
		Tween.EASE_IN)
	tween_move_player.start()

func _change_state(new_state: String) -> void:
	if current_state != new_state and states.has(new_state):
		if current_state != '':
			states[current_state].exit()
		current_state = new_state
		states[current_state].enter()

func _on_MovePlayer_tween_completed(_object: Object, _key: NodePath) -> void:
	player.can_control(true)

func _on_Dialog_start(dialog: DialogTrigger) -> void:
	states['dialog'].set_dialog(dialog)
	_change_state('dialog')

func _on_State_ended(state_name: String) -> void:
	current_state = 'move'

func _on_end_of_chapter(chapter: int) -> void:
	print("next %s" % chapter)

class GameState:
	signal state_ended
	
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


class MobileState extends GameState:

	func enter() -> void:
		player.can_control(true)

	func physics_process(delta: float) -> void:
		player.physics_process(delta)

	func input(event: InputEvent) -> void:
		player.input(event)

	func process(_delta: float) -> void:
		_check_triggers()

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
