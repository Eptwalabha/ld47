class_name Character
extends Spatial

onready var glass := $Armature/Skeleton/Hand/Glass

export(String, "sit-drink", "sit-idle", "sit-stool-idle", "sit-stool-drink",
			   "idle", "bartender", "danse", "sleep") var default := "sit-drink"

func _ready() -> void:
	play(default)

func sit_drink() -> void: play("sit-drink")
func sit_idle() -> void: play("sit-idle")
func sit_stool_idle() -> void: play("sit-stool-idle")
func sit_stool_drink() -> void: play("sit-stool-drink")
func idle() -> void: play("idle")
func danse() -> void: play("danse")
func sleep() -> void: play("sleep")

func play(animation: String) -> void:
	animation = animation + ("" if animation.ends_with("-loop") else "-loop")
	glass.visible = (animation == "sit-stool-drink-loop")
	$AnimationPlayer.play(animation)

func pause() -> void:
	$AnimationPlayer.stop(false)

func resume() -> void:
	$AnimationPlayer.play()
