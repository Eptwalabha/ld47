extends CanvasLayer

var CeilingLight = preload('res://assets/models/bar-v2/ceiling-light.material')
var MirrorGlass = preload('res://assets/models/bar-v2/mirror-glass.material')
var ToiletSign = preload('res://assets/models/bar-v2/ToiletSign.material')
var BuildingCity = preload('res://assets/models/road/building-city.material')
var PhoneGlass = preload('res://assets/models/appartment/phone_glass.material')

var materials := [
	CeilingLight,
	MirrorGlass,
	ToiletSign,
	BuildingCity,
	PhoneGlass,
]

func _ready() -> void:
	for material in materials:
		var mesh = MeshInstance.new()
		mesh.mesh = QuadMesh.new()
		mesh.set_surface_material(0, material)
		$Spatial.add_child(mesh)
