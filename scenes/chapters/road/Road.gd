class_name Road
extends GameChapter

signal car_crashed
signal car_bounced(left)

onready var road := $Pivot as Spatial
onready var line_a := $Pivot/LineA as Spatial
onready var line_b := $Pivot/LineB as Spatial
onready var car_engine_sound := $CarEngine as AudioStreamPlayer

var sky_shader : Material
var initial_road_rotation : Vector3
var sky_angle := 0.0;

func _ready() -> void:
	sky_shader = $Sky.get_surface_material(0);
	initial_road_rotation = road.rotation
	for car in get_tree().get_nodes_in_group("road-car"):
		if car is Car:
			car.connect("crashed_on_player", self, "_on_Car_crash", [car])
	$CarEngine.stop()
	$CarCrash.stop()
#	reset()

func reset() -> void:
	for car in get_tree().get_nodes_in_group("cars"):
		if car is Car:
			car.reset()
	road.rotation = initial_road_rotation
	line_a.rotation = Vector3.ZERO
	line_b.rotation = Vector3.ZERO
	Data.reset_game(Data.CHAPTER.ROAD)
	emit_signal("fade_in_requested")
	$CarEngine.play()

func get_start_origin() -> Vector3:
	return start.global_transform.origin

func process(delta : float) -> void:
	if Data.road_car_crashed or chapter_paused:
		return
	var s := 0.0
	if Data.DEBUG and Data.DEBUG_ROAD_CONTROL:
		if Input.is_action_pressed("move_forward"):
			s = (.4 + Data.road_car_speed) * delta
		elif Input.is_action_pressed("move_backward"):
			s = -(.4 + Data.road_car_speed) * delta
		else:
			s = 0.0
	else:
		Data.road_car_speed += delta * 0.01
		car_engine_sound.pitch_scale = 1.0 + Data.road_car_speed
		s = (.4 + Data.road_car_speed) * delta
	road.rotate_y(s)
	sky_angle += s * -.8;
	sky_shader.set_shader_param("angle", sky_angle);
	line_a.rotate_y(-.2 * delta)
	line_b.rotate_y(+.2 * delta)

func crash_car() -> void:
	Data.road_car_crashed = true
	emit_signal("black_requested")
	$CarCrash.play()
	$CarEngine.stop()

func _on_Car_crash(_car: Car) -> void:
	crash_car()

func _on_Area_area_entered(area: Area) -> void:
	if area is Car:
		area.new_turn()

func _on_Right_body_entered(body: Node) -> void:
	side_road_body_entered(body, false)

func _on_Left_body_entered(body: Node) -> void:
	side_road_body_entered(body, true)

func side_road_body_entered(body: Node, left: bool) -> void:
	if body.is_in_group('player'):
		emit_signal("car_bounced", left)

func _on_CarCrash_finished() -> void:
	emit_signal("car_crashed")
