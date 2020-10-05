class_name Phone
extends Spatial

signal picked_up
signal end_of_message(name)

var dialog : Dialog

func _on_InteractTrigger_interacted_with() -> void:
	$Ring.stop()
	emit_signal("picked_up")
#	$Message.play()
	$AnimationPlayer.play("off")
	$InteractTrigger.set_active(false)

func reset() -> void:
	show()
	$Ring.stop()
	$AnimationPlayer.play("off")
	$InteractTrigger.reset()

func ring() -> void:
	$AnimationPlayer.play("ringing")
	$Ring.play()
	$InteractTrigger.set_active(true)

func remove() -> void:
	hide()
	$InteractTrigger.set_active(false)

func _on_Message_finished() -> void:
	emit_signal("end_of_message", "phone_intro")
