class_name StartChapter
extends Spatial

func _ready() -> void:
	if not Data.debug:
		$MeshInstance.queue_free()
