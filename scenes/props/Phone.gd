class_name Phone
extends Spatial

signal end_of_message(name)

func _on_InteractTrigger_interacted_with() -> void:
	$Ring.stop()
	$Message.play()
	$AnimationPlayer.play("off")
	$InteractTrigger.set_active(false)

func reset() -> void:
	$AnimationPlayer.play("off")
	$InteractTrigger.set_active(false)

func ring() -> void:
	$AnimationPlayer.play("ringing")
	$Ring.play()
	$InteractTrigger.set_active(true)


func _on_Message_finished() -> void:
	emit_signal("end_of_message", "phone_intro")
