class_name Flat
extends Spatial

signal door_interacted_with(door)
signal tp_entered(trigger)
signal tp_exited(trigger)

func _ready() -> void:
	$Corridor/TPUp.connect("player_entered", self, "emit_signal", ["tp_entered", $Corridor/TPUp])
	$Corridor/TPUp.connect("player_exited", self, "emit_signal", ["tp_exited", $Corridor/TPUp])
	$Corridor/TPDown.connect("player_entered", self, "emit_signal", ["tp_entered", $Corridor/TPDown])
	$Corridor/TPDown.connect("player_exited", self, "emit_signal", ["tp_exited", $Corridor/TPDown])

func _on_Door_interacted_with() -> void:
	emit_signal("door_interacted_with", $Door)
