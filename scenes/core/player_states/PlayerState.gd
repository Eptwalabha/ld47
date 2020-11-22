class_name PlayerState
extends Node

signal state_ended

func enter(_player: Player) -> void:
	pass

func process(_player: Player, _delta: float) -> void:
	pass

func physics_process(_player: Player, _delta: float) -> void:
	pass

func input(_player: Player, _event: InputEvent) -> void:
	pass

func exit(_player: Player) -> void:
	pass

func is_hint_activated() -> bool:
	return false

func pause(_player: Player, next_state: int) -> void:
	pass

func resume(_player: Player, previous_state: int) -> void:
	pass
