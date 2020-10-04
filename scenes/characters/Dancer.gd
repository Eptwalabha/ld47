extends Spatial

func _ready() -> void:
	$AnimationPlayer.play("danse-loop")
	$AnimationPlayer.advance(randi() * $AnimationPlayer.current_animation_length)
