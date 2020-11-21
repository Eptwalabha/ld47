class_name GameChapter
extends Spatial

signal door_interacted_with(door)
signal tp_entered(trigger)
signal tp_exited(trigger)
signal dialog_triggered(dialog_trigger)
signal window_triggered(window_trigger)
signal item_picked_up(item)
signal night_environment(is_night)

onready var start := $Start as Spatial
var chapter_paused = false

func reset() -> void:
	pass

func init_chapter() -> void:
	pass

func _connect_triggers(prefix: String) -> void:
	for trigger in get_tree().get_nodes_in_group('%s-tp-trigger' % prefix):
		if trigger is TPTrigger:
			trigger.connect("player_entered", self, "emit_signal", ["tp_entered", trigger])
			trigger.connect("player_exited", self, "emit_signal", ["tp_exited", trigger])
	for trigger in get_tree().get_nodes_in_group('%s-dialog' % prefix):
		if trigger is DialogTriggerArea:
			trigger.connect("interacted_with", self, "emit_signal", ["dialog_triggered", trigger])
	for trigger in get_tree().get_nodes_in_group('%s-window' % prefix):
		if trigger is WindowTrigger:
			trigger.connect("interacted_with", self, "emit_signal", ["window_triggered", trigger])

func _set_location_active(location: Location, active: bool) -> void:
	location.set_active(active)
	location.visible = active

func process(_delta: float) -> void:
	pass

func get_start_origin() -> Vector3:
	return Vector3.ZERO

func _pause() -> void:
	chapter_paused = true
	pause()

func pause() -> void:
	pass

func _resume() -> void:
	chapter_paused = false
	resume()

func resume() -> void:
	pass
