class_name Phone
extends Spatial


func _on_InteractTrigger_interacted_with() -> void:
	$Ring.stop()
	$Message.play()
	$InteractTrigger.set_active(false)

func reset() -> void:
	$AnimationPlayer.play("off")
	$InteractTrigger.set_active(false)

func ring() -> void:
	$AnimationPlayer.play("ringing")
	$Ring.play()
	$InteractTrigger.set_active(true)
