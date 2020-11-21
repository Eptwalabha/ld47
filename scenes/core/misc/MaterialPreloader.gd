extends Spatial

var materials := []
var count = 0

func _ready() -> void:

	var dir = Directory.new()
	var path = "res://assets/models"
	dir.open(path)

	_load_materials(dir)

	for material in materials:
		var mesh = MeshInstance.new()
		mesh.mesh = QuadMesh.new()
		mesh.mesh.set_material(material)
		mesh.visible = true
		$Materials.add_child(mesh)

	set_process(true)

func _load_materials(dir: Directory) -> void:
	dir.list_dir_begin(true, true)
	var file = dir.get_next()
	while file != "":
		var file_path = dir.get_current_dir() + "/" + file
		if dir.current_is_dir():
			var dir2 = Directory.new()
			dir2.open(file_path)
			_load_materials(dir2)
		elif file.ends_with(".material"):
			materials.append(load(file_path))
		file = dir.get_next()

func _process(_delta: float) -> void:
	count += 1
	if count > 10:
		hide()
		set_process(false)
