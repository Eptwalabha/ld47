class_name PlayerStateAnimation
extends PlayerState

func enter() -> void:
	player.can_control(false)
	player.velocity = Vector3.ZERO
	ui.hide_context()
