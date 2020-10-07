extends Control

func _ready() -> void:
	$AnimationPlayer.play("fade-in")

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("ui_accept") or Input.is_action_just_pressed("ui_cancel"):
		pass

func _on_AnimationPlayer_animation_finished(_anim_name: String) -> void:
	get_tree().change_scene("res://scenes/Game.tscn")
