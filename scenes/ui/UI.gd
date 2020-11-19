class_name UI
extends Control

# warning-ignore:unused_signal
signal blink
signal game_resumed
signal game_paused

onready var dialog := $VBoxContainer/Dialog as UIDialog
onready var context := $VBoxContainer/Context as UIContext
onready var dot := $Dot as CenterContainer
onready var pause := $PauseMenu as PauseMenu
onready var options := $OptionsMenu as OptionsMenu

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _process(_delta: float) -> void:
	if not is_menu_open() and Input.get_mouse_mode() != Input.MOUSE_MODE_CAPTURED:
		open_pause_menu()

func _input(event: InputEvent) -> void:
	if event.is_action_released('ui_cancel'):
		if not is_menu_open():
			open_pause_menu()
		else:
			switch_menu()

func reset() -> void:
	show()

func show_context(key: String) -> void:
	context.display(key)

func hide_context() -> void:
	context.hide()

func display_dialog(who: String, what: String) -> void:
	hide_context()
	dialog.display(who, what)

func hide_dialog() -> void:
	dialog.hide()

func blink() -> void:
	$AnimationPlayer.play("blink")

func fade(fade_in: bool) -> void:
	if fade_in:
		$AnimationPlayer.play("fade-in")
	else:
		$AnimationPlayer.play("fade-out")

func black() -> void:
	$ColorRect.color.a = 1.0

func show_dot(is_dot_visible: bool) -> void:
	dot.visible = is_dot_visible

func quit_game() -> void:
	get_tree().quit()

func open_pause_menu() -> void:
	emit_signal("game_paused")
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	show_dot(false)
	pause.open()

func switch_menu() -> void:
	if options.visible:
		options.hide()
		pause.open()

func is_menu_open() -> bool:
	return pause.visible or options.visible

func _on_PauseMenu_continue_clicked() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	show_dot(true)
	pause.hide()
	emit_signal("game_resumed")

func _on_PauseMenu_quit_clicked() -> void:
	quit_game()

func _on_OptionsMenu_back_clicked() -> void:
	pause.open()
	options.hide()

func _on_PauseMenu_options_clicked() -> void:
	pause.visible = false
	options.open()
