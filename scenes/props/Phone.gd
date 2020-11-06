class_name Phone
extends Spatial

signal picked_up
signal end_of_message(name)

onready var trigger := $InteractTrigger as InteractTrigger
onready var ring_tone := $Ring as AudioStreamPlayer3D
onready var animation := $AnimationPlayer as AnimationPlayer

var dialog : Dialog

func _on_InteractTrigger_interacted_with() -> void:
	ring_tone.stop()
	emit_signal("picked_up")
	animation.play("off")
	trigger.set_active(false)

func ring() -> void:
	animation.play("ringing")
	ring_tone.play()
	trigger.set_active(true)

func set_active(active: bool) -> void:
	visible = active
	trigger.set_active(active)
