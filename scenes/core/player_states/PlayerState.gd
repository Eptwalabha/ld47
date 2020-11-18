class_name PlayerState
extends Node

signal state_ended

#var player: Player = null
var ui : UI = null

func enter(_player: Player) -> void:
	pass

func process(_player: Player, _delta: float) -> void:
	pass

func physics_process(_player: Player, _delta: float) -> void:
	pass

func input(_player: Player, _event: InputEvent) -> void:
	pass

func exit() -> void:
	pass

func is_hint_activated() -> bool:
	return false

func pause(_player: Player, next_state: String) -> void:
	pass

func resume(_player: Player) -> void:
	pass
