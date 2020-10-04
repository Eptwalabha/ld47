extends Spatial

export(String) var default := "sit-drink-loop"


func _ready() -> void:
	$AnimationPlayer.play(default)
