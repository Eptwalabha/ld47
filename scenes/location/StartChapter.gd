class_name StartChapter
extends Spatial

func _ready() -> void:
	if not Data.DEBUG:
		$MeshInstance.queue_free()
