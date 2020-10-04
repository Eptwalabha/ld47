class_name Glass
extends Spatial

func empty(is_empty: bool) -> void:
	$glass_content.visible = not is_empty
