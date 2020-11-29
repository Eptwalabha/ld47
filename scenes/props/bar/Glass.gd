class_name Glass
extends Spatial

export(bool) var is_empty := false setget empty

func empty(glass_empty: bool) -> void:
	is_empty = glass_empty
	$glass_content.visible = not is_empty
