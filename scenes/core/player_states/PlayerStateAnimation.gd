class_name PlayerStateAnimation
extends PlayerState

func enter(p: Player) -> void:
	p.can_control(false)
	p.velocity = Vector3.ZERO
	ui.hide_context()
