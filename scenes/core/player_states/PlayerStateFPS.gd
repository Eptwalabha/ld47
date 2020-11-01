class_name PlayerStateFPS
extends PlayerState

func enter() -> void:
	player.can_control(true)

func physics_process(delta: float) -> void:
	player.physics_process(delta)

func input(event: InputEvent) -> void:
	player.input(event)

func should_handle_hover() -> bool:
	return true
