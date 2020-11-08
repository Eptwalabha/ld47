class_name Road
extends GameChapter

signal car_crashed

onready var start := $StartPoint as Spatial
onready var road := $Pivot as Spatial
onready var line_a := $Pivot/LineA as Spatial
onready var line_b := $Pivot/LineB as Spatial
onready var car_engine_sound := $CarEngine as AudioStreamPlayer2D

var initial_road_rotation : Vector3

func _ready() -> void:
	initial_road_rotation = road.rotation
	for car in get_tree().get_nodes_in_group("cars"):
		if car is Car:
			car.connect("crashed_on_player", self, "crash_car")
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
	Data.reset_game(Data.LEVEL.ROAD)
	emit_signal("night_environment", true)
	$CarEngine.play()

func set_up_player(player: Player) -> void:
	player.global_transform.origin = start.global_transform.origin

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
