class_name CarInside
extends Spatial

onready var valve = $car_inside/valve
onready var head = $car_inside/Head
onready var camera = $car_inside/Head/Camera

export(float) var mouse_sensitivity := 0.3
var camera_angle: float = 0

func _ready() -> void:
	mouse_sensitivity = mouse_sensitivity * -1

func reset() -> void:
	head.rotation = Vector3.ZERO
	camera.rotation = Vector3.ZERO
	camera_angle = 0
	camera.make_current()

func input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		head.rotate_y(deg2rad(event.relative.x * mouse_sensitivity))

		var change = event.relative.y * mouse_sensitivity
		if change + camera_angle < 90 and change + camera_angle > -90:
			camera.rotate_x(deg2rad(change))
			camera_angle = camera_angle + change

func steer(amount: float) -> void:
	valve.rotate_object_local(Vector3.UP, 1.1 * amount)
