class_name ChapterHome
extends Chapter

onready var appartment := $Appartment as Appartment
onready var player := $Player as Player
onready var street := $Street as Spatial
onready var phone := $Phone as Phone
onready var tween_move_player := $Appartment/Tween as Tween
onready var ui := $UI as UI

var lvl = -2
var player_is_inside := true
var current_state = ""
var states = {
	'intro': IntroState.new(),
	'move': MobileState.new(),
	'dialog': DialogState.new(),
	'phone': OnPhoneState.new(),
}

var reset_player_transform :Transform

func _ready() -> void:
	hide()
	reset_player_transform = player.global_transform
	for state_name in states:
		var state = states[state_name]
		if state is GameState:
			state.player = player
			state.ui = ui
			state.connect("state_ended", self, "_on_State_ended", [state_name])
	states.intro.phone = phone
	_change_state('intro')

	for trigger in get_tree().get_nodes_in_group("dialog-home"):
		if trigger is DialogTrigger:
			trigger.connect("dialog_start", self, "_on_Dialog_start")

func end() -> void:
	hide()
	ui.hide()

func start() -> void:
	show()
	emit_signal("dot", true)
	ui.reset()
	ui.black()
	lvl = -2
	player.reset()
	emit_signal("night_environment", false)
	player.reset()
	phone.reset()
	var phone_dialog = Dialog.new()
	phone_dialog.push('voice_mail', 'dialog_1_phone_01')
	phone_dialog.push('friend', 'dialog_1_phone_02')
	if Data.first_time:
		phone_dialog.push('friend', 'dialog_1_phone_03')
	phone.dialog = phone_dialog
	for dialog in get_tree().get_nodes_in_group("dialog_trigger"):
		if dialog is DialogTrigger:
			dialog.reset()

	player.global_transform = reset_player_transform
	player_is_inside = true
	appartment.set_level(lvl)
	street.translation = Vector3(0, 2.5 * lvl, 0)
	_change_state('intro')

func process(delta: float) -> void:
	states[current_state].process(delta)

func physics_process(delta: float) -> void:
	states[current_state].physics_process(delta)

func input(event: InputEvent) -> void:
	states[current_state].input(event)

func _move_player_from_to(_from: Spatial, to: Spatial) -> void:
	player.can_control(false)
	player.move_through_window()
# warning-ignore:return_value_discarded
	tween_move_player.interpolate_property(
		player,
		"translation",
		player.global_transform.origin,
		to.global_transform.origin,
		.8,
		Tween.TRANS_QUAD,
		Tween.EASE_IN)
# warning-ignore:return_value_discarded
	tween_move_player.start()

func _on_TPTop_body_entered(body: Node) -> void:
	if body is Player:
		_update_back_building(1)
		player.force_move(Vector3(0, -2.5, 0))

func _on_TPBottom_body_entered(body: Node) -> void:
	if body is Player:
		_update_back_building(-1)
		player.force_move(Vector3(0, 2.5, 0))

func _on_Tween_tween_all_completed() -> void:
	player.can_control(true)

func _update_back_building(amount: int) -> void:
		var next_lvl = clamp(lvl + amount, -4, 2)
		if lvl != next_lvl:
			street.translate(Vector3(0, 2.5, 0) * amount)
		lvl = next_lvl
		appartment.set_level(lvl)

func _on_BackStreetBuilding_go_to(_place: String) -> void:
	if player_is_inside:
		player_is_inside = false
		_move_player_from_to($Appartment/In, $Appartment/Out)
	else:
		player_is_inside = true
		_move_player_from_to($Appartment/Out, $Appartment/In)

func _on_Dialog_start(trigger: DialogTrigger) -> void:
	states['dialog'].set_dialog(trigger.dialog)
	_change_state('dialog')

func _change_state(new_state: String) -> void:
	if current_state != new_state and states.has(new_state):
		if current_state != '':
			states[current_state].exit()
		current_state = new_state
		states[current_state].enter()

func _on_State_ended(_state_name: String) -> void:
	current_state = 'move'


class GameState:
# warning-ignore:unused_signal
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

	var dialog : Dialog = null

	func set_dialog(d: Dialog) -> void:
		dialog = d

	func enter() -> void:
		player.can_control(false)
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

class OnPhoneState extends GameState:

	var dialog : Dialog = null

	func set_dialog(d: Dialog) -> void:
		dialog = d

	func enter() -> void:
		player.can_control(false)
		ui.hide_context()
		dialog.start()
		var _a = _print_next_bit()

	func input(event: InputEvent) -> void:
		player.input(event)

	func process(_delta: float) -> void:
		if Input.is_action_just_pressed("context_action"):
			if not _print_next_bit():
				player.can_control(true)
				player.hangup_phone()
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
		if player.on_phone:
			player.hangup_phone()
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

func _on_BackStreetBuilding_end_of_chapter_one() -> void:
	emit_signal("chapter_ended")

class IntroState extends GameState:
	
	var timeout : float
	var phone : Phone
	var ring : bool
	
	func enter() -> void:
		if Data.debug:
			emit_signal("state_ended")
			ui.fade(true)
			return
		ui.black()
		timeout = 4.0
		ring = false
		player.can_control(true)

	func process(delta) -> void:
		timeout -= delta
		if timeout <= 2.0 and not ring:
			ring = true
			phone.ring()
		elif timeout <= 0.0:
			emit_signal("state_ended")
			ui.fade(true)


func _on_Phone_picked_up() -> void:
	phone.remove()
	player.answer_phone()
	states['phone'].set_dialog(phone.dialog)
	_change_state('phone')
