class_name UI
extends Control

# warning-ignore:unused_signal
signal blink

onready var dialog := $VBoxContainer/Dialog as UIDialog
onready var context := $VBoxContainer/Context as UIContext
onready var dot := $Dot as CenterContainer
onready var mouse_capture := $MouseCapture as MarginContainer

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

func is_mouse_captured() -> bool:
	return not mouse_capture.visible

func show_mouse_capture() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	mouse_capture.visible = true

func capture_mouse() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	mouse_capture.visible = Input.get_mouse_mode() != Input.MOUSE_MODE_CAPTURED

func _on_Button_pressed() -> void:
	capture_mouse()
