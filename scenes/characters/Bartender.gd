class_name Bartender
extends Spatial

func _ready() -> void:
	$AnimationPlayer.play("bartender-loop")

func pause() -> void:
	$AnimationPlayer.stop(false)

func resume() -> void:
	$AnimationPlayer.play()
