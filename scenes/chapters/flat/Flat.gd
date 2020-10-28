class_name Flat
extends Spatial

signal door_interacted_with(door)
signal tp_entered(trigger)
signal tp_exited(trigger)
signal dialog_triggered(dialog_trigger)

func _ready() -> void:
	for trigger in $Triggers.get_children():
		if trigger is TPTrigger:
			trigger.connect("player_entered", self, "emit_signal", ["tp_entered", trigger])
			trigger.connect("player_exited", self, "emit_signal", ["tp_exited", trigger])
		elif trigger is DialogTriggerArea:
			trigger.connect("interacted_with", self, "emit_signal", ["dialog_triggered", trigger])
	var bar_trigger = $BackStreetBuilding/BarCorridor/TPTrigger
	bar_trigger.connect("player_entered", self, "emit_signal", ["tp_entered", bar_trigger])
	bar_trigger.connect("player_exited", self, "emit_signal", ["tp_exited", bar_trigger])

func _on_Door_interacted_with() -> void:
	emit_signal("door_interacted_with", $Door)
