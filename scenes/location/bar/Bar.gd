extends Spatial

onready var pivot := $Pivot as Spatial

func reverse() -> void:
	pivot.scale.x *= -1
	pass

func reset() -> void:
	pivot.scale.x = 1
