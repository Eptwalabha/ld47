class_name PlayerState
extends Node

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

func is_hint_activated() -> bool:
	return false
