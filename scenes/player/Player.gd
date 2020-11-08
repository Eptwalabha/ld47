class_name Player
extends KinematicBody

onready var ray := $Head/Camera/RayCast as RayCast
onready var head := $Head as Spatial
onready var camera := $Head/Camera as Camera

export(float) var mouse_sensitivity := 0.3

var has_control : bool = true
var camera_angle : float = 0.0

func _ready() -> void:
	mouse_sensitivity = mouse_sensitivity * -1

func reset() -> void:
	pass

func make_current() -> void:
	camera.make_current()

func zeroed_velocity() -> void:
	pass

func input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		Data.using_controller = false
		head.rotate_y(deg2rad(event.relative.x * mouse_sensitivity))

		var change = event.relative.y * mouse_sensitivity
		if change + camera_angle < 90 and change + camera_angle > -90:
			camera.rotate_x(deg2rad(change))
			camera_angle = camera_angle + change
	if event is InputEventJoypadMotion or event is InputEventJoypadButton:
		Data.using_controller = true

func physics_process(_delta: float) -> void:
	pass

func can_control(control: bool) -> void:
	has_control = control

func force_move(direction: Vector3) -> void:
	translate(direction)

func force_move_to(spatial: Spatial) -> void:
	global_transform.origin = spatial.global_transform.origin
	rotation = spatial.global_transform.basis.get_euler()
	head.rotation = Vector3.ZERO
	camera.rotation = Vector3.ZERO
	camera_angle = 0.0

func get_trigger_hover() -> InteractTrigger:
	if ray.is_colliding():
		var collider = ray.get_collider()
		if collider is InteractTrigger and collider.active:
			return collider
	return null

func show_item(_item_name: String, _visible: bool) -> void:
	pass
