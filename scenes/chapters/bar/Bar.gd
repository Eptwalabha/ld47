extends Spatial

signal door_interacted_with(door)
signal tp_entered(trigger)
signal tp_exited(trigger)
signal dialog_triggered(dialog_trigger)
signal window_triggered(window_trigger)

onready var pivot := $Pivot as Spatial
onready var restroom_door := $Pivot/Door as Door

func _ready() -> void:
	for trigger in get_tree().get_nodes_in_group('bar-tp-trigger'):
		if trigger is TPTrigger:
			trigger.connect("player_entered", self, "emit_signal", ["tp_entered", trigger])
			trigger.connect("player_exited", self, "emit_signal", ["tp_exited", trigger])
	for trigger in get_tree().get_nodes_in_group('bar-dialog'):
		if trigger is DialogTriggerArea:
			trigger.connect("interacted_with", self, "emit_signal", ["dialog_triggered", trigger])
	for trigger in get_tree().get_nodes_in_group('bar-window'):
		if trigger is WindowTrigger:
			trigger.connect("interacted_with", self, "emit_signal", ["window_triggered", trigger])

func _on_Door_interacted_with() -> void:
	emit_signal("door_interacted_with", restroom_door)

func show_restroom() -> void:
	restroom_door.close()
	_set_active($RestroomLocation, true)
	_set_active($RestroomLocationReverse, true)
	_set_active($BarStorageRoom, false)

func _set_active(location: Location, active: bool) -> void:
	location.set_active(active)
	location.visible = active

func _on_ToiletWindow_went_through() -> void:
	pivot.scale.z = -1 if pivot.scale.z > 0 else 1

func is_reverted() -> bool:
	return pivot.scale.z < 0
