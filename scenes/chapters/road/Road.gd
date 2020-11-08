class_name Road
extends GameChapter

signal car_crashed

onready var start := $StartPoint as Spatial
onready var road := $Pivot as Spatial
onready var line_a := $Pivot/LineA as Spatial
onready var line_b := $Pivot/LineB as Spatial
onready var car_engine_sound := $CarEngine as AudioStreamPlayer2D

var reset_line_a_transform : Transform
var reset_line_b_transform : Transform
var reset_road_transform : Transform

func _ready() -> void:
	reset_line_a_transform = line_a.global_transform
	reset_line_b_transform = line_b.global_transform
	reset_road_transform = road.global_transform
	for car in get_tree().get_nodes_in_group("cars"):
		if car is Car:
			car.connect("crashed_on_player", self, "crash_car")
	$CarEngine.stop()
	$CarCrash.stop()
	reset()

func start() -> void:
	$CarEngine.play()
	emit_signal("night_environment", true)
	reset()

func reset() -> void:
	for car in get_tree().get_nodes_in_group("cars"):
		if car is Car:
			car.reset()
	line_a.global_transform = reset_line_a_transform
	line_b.global_transform = reset_line_b_transform
	road.global_transform = reset_road_transform
	Data.reset_game(Data.LEVEL.ROAD)

func process(delta : float) -> void:
	if Data.road_car_crashed:
		return
	Data.road_car_speed += delta * 0.01
	car_engine_sound.pitch_scale = 1.0 + Data.road_car_speed
	road.rotate_y((.4 + Data.road_car_speed) * delta)
	line_a.rotate_y(-.2 * delta)
	line_b.rotate_y(+.2 * delta)

func crash_car() -> void:
	emit_signal("car_crashed")
	Data.road_car_crashed = true
	$CarCrash.play()
	$CarEngine.stop()

func _on_Area_body_entered(body: Node) -> void:
	if body.is_in_group('player'):
		crash_car()

func _on_Car_crash() -> void:
	crash_car()

func _on_Area_area_entered(area: Area) -> void:
	if area is Car:
		area.new_turn()
