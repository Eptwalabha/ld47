class_name Appartment
extends Spatial

func set_level(lvl: int) -> void:
	$Level/Level1.visible = lvl > -2
	$Level/Level2.visible = lvl > -1
	$Level/Level3.visible = lvl > 0
	$Level/Level4.visible = lvl > 1
