class_name PlayerStatePauseMenu
extends PlayerState

func enter(player: Player) -> void:
	AudioServer.set_bus_mute(1, true)

func exit(player: Player) -> void:
	AudioServer.set_bus_mute(1, false)
