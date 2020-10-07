class_name Chapter
extends Spatial

# warning-ignore:unused_signal
signal tp_player(direction)
# warning-ignore:unused_signal
signal move_player_from_to(from, to)
# warning-ignore:unused_signal
signal chapter_ready
# warning-ignore:unused_signal
signal chapter_ended
# warning-ignore:unused_signal
signal night_environment(night)
# warning-ignore:unused_signal
signal dot(visible)


func start() -> void:
	pass

func process(_delta: float) -> void:
	pass

func physics_process(_delta: float) -> void:
	pass

func input(_event: InputEvent) -> void:
	pass

func end() -> void:
	hide()
