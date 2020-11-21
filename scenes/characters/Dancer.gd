extends Spatial

onready var glass := $Armature/Skeleton/Hand/Glass

export(String, "sit-drink", "sit-idle", "sit-stool-idle", "sit-stool-drink",
			   "idle", "bartender", "danse", "sleep") var default := "danse"
export(bool) var synchronized := false

func _ready() -> void:
	play(default)

func play(animation: String) -> void:
	animation = animation + ("" if animation.ends_with("-loop") else "-loop")
	glass.visible = (animation == "sit-stool-drink-loop")
	$AnimationPlayer.play(animation)
	if not synchronized:
		$AnimationPlayer.advance(randi() * $AnimationPlayer.current_animation_length)

func pause() -> void:
	$AnimationPlayer.stop(false)

func resume() -> void:
	$AnimationPlayer.play()
