class_name Flat
extends Spatial

signal door_interacted_with(door)
signal tp_entered(trigger)
signal tp_exited(trigger)
signal dialog_triggered(dialog_trigger)
signal window_triggered(window_trigger)

func _ready() -> void:
	for trigger in get_tree().get_nodes_in_group('flat-tp-trigger'):
		if trigger is TPTrigger:
			trigger.connect("player_entered", self, "emit_signal", ["tp_entered", trigger])
			trigger.connect("player_exited", self, "emit_signal", ["tp_exited", trigger])
	for trigger in get_tree().get_nodes_in_group('flat-dialog'):
		if trigger is DialogTriggerArea:
			trigger.connect("interacted_with", self, "emit_signal", ["dialog_triggered", trigger])
	for trigger in get_tree().get_nodes_in_group('flat-window'):
		if trigger is WindowTrigger:
			trigger.connect("interacted_with", self, "emit_signal", ["window_triggered", trigger])

func set_level(level: int) -> void:
	var delta_elevation : float = level * 2.5 - $BackStreetBuilding.global_transform.origin.y
	$BackStreetBuilding.translate(Vector3(0, delta_elevation, 0))
	$Appartment/Window.set_active(level == 0 || level == 2)
	print("level %s" % level)

func _on_Door_interacted_with() -> void:
	emit_signal("door_interacted_with", $Door)
