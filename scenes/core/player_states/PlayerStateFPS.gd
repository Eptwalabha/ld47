class_name PlayerStateFPS
extends PlayerState

signal context_action_pressed

func enter() -> void:
	player.can_control(true)

func physics_process(delta: float) -> void:
	player.physics_process(delta)

func input(event: InputEvent) -> void:
	player.input(event)

func process(_delta: float) -> void:
	if Input.is_action_just_pressed("context_action"):
		emit_signal("context_action_pressed")

func is_hint_activated() -> bool:
	return true
