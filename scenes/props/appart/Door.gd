extends Spatial

signal door_opened

export(bool) var locked := false
export(bool) var closed := true

var initialy_locked : bool
var initialy_closed : bool
var initial_hint : String

func _ready() -> void:
	initial_hint = $door/InteractTrigger.hover_key
	initialy_closed = closed
	initialy_locked = locked

func reset() -> void:
	show()
	closed = initialy_closed
	locked = initialy_locked
	if closed:
		$door.rotation = Vector3.ZERO
	else:
		$door.rotation = Vector3(0, 179, 0)
	$door/InteractTrigger.active = true
	$door/InteractTrigger.hover_key = initial_hint

func _on_InteractTrigger_interacted_with() -> void:
	if locked and closed:
		$door/InteractTrigger.hover_key = 'door_locked'
	else:
		$door/InteractTrigger.active = false
		$AnimationPlayer.play("open")
		yield($AnimationPlayer, "animation_finished")
		emit_signal("door_opened")
		hide()
