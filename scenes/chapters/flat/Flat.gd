class_name Flat
extends Spatial

signal door_interacted_with(door)
signal tp_entered(trigger)
signal tp_exited(trigger)

func _ready() -> void:
	for trigger in $Triggers.get_children():
		if trigger is TPTrigger:
			trigger.connect("player_entered", self, "emit_signal", ["tp_entered", trigger])
			trigger.connect("player_exited", self, "emit_signal", ["tp_exited", trigger])

func _on_Door_interacted_with() -> void:
	emit_signal("door_interacted_with", $Door)
