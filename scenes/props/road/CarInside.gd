class_name CarInside
extends Spatial

onready var valve = $car_inside/valve
onready var head = $car_inside/Head
onready var camera = $car_inside/Head/Camera
onready var friend = $Friend as Character

export(bool) var friend_sleep := true
export(float) var mouse_sensitivity := 0.3
var camera_angle: float = 0
var acceleration : float = 10.0

func _ready() -> void:
	mouse_sensitivity = mouse_sensitivity * -1

func reset() -> void:
	head.rotation = Vector3.ZERO
	camera.rotation = Vector3.ZERO
	camera_angle = 0
	if friend_sleep:
		camera.make_current()
		friend.play('sleep')
	else:
		friend.play('sit-stool-idle')

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

func input_controller() -> void:
	if Data.using_controller:
		var y = (Input.get_action_strength("look_left") - Input.get_action_strength("look_right")) * acceleration
		head.rotate_y(deg2rad(y))
		var x = - (Input.get_action_strength("look_down") - Input.get_action_strength("look_up")) * acceleration
		if x + camera_angle < 90 and x + camera_angle > -90:
			camera.rotate_x(deg2rad(x))
			camera_angle = camera_angle + x

func steer(amount: float) -> void:
	valve.rotate_object_local(Vector3.UP, 1.1 * amount)

func set_current() -> void:
	camera.make_current()
