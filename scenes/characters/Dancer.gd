extends Spatial

export(String, "sit-drink", "sit-idle", "idle", "bartender", "danse", "sleep") var default := "danse"

func _ready() -> void:
	$AnimationPlayer.play(default + "-loop")
	$AnimationPlayer.advance(randi() * $AnimationPlayer.current_animation_length)
