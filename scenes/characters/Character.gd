extends Spatial

export(String, "sit-drink", "sit-idle", "idle", "bartender", "danse", "sleep") var default := "sit-drink"


func _ready() -> void:
	$AnimationPlayer.play(default + "-loop")
