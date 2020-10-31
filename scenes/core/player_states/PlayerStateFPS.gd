class_name PlayerStateFPS
extends PlayerState

func enter() -> void:
	player.can_control(true)

func physics_process(delta: float) -> void:
	player.physics_process(delta)

func input(event: InputEvent) -> void:
	player.input(event)

func process(delta: float) -> void:
	_check_triggers()

func _check_triggers():
	if player.ray.is_colliding():
		var collider = player.ray.get_collider()
		if collider is InteractTrigger and collider.active:
			if Input.is_action_just_pressed("context_action"):
				collider.interact()
			else:
				ui.show_context(collider.hover_key)
		else:
			ui.hide_context()
	else:
		ui.hide_context()
