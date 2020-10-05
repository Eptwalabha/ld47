class_name Game
extends Spatial

onready var chapter_home := $ChapterHome as ChapterHome
onready var chapter_bar := $ChapterBar as ChapterBar
onready var chapter_road := $ChapterRoad as ChapterRoad
onready var chapter_hospital := $ChapterHospital as ChapterHospital

onready var env := $WorldEnvironment as WorldEnvironment

var current_chapter := 0
var chapters = []

func _ready() -> void:

	chapters = [
		chapter_home,
		chapter_bar,
		chapter_road,
		chapter_hospital,
	]

	for chapter in get_tree().get_nodes_in_group('chapter'):
		if chapter is Chapter:
			chapter.connect("chapter_ended", self, "_on_Chapter_Ended", [chapter])
			chapter.connect("night_environment", self, "_on_Environment_change")
	reset_game()
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _process(delta: float) -> void:
	chapters[current_chapter].process(delta)
	# debug remove
	if Input.is_action_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		get_tree().quit()
	if Input.is_action_just_pressed("action_reset_chapter"):
		chapters[current_chapter].end()
		chapters[current_chapter].start()

func _physics_process(delta: float) -> void:
	chapters[current_chapter].physics_process(delta)

func _input(event: InputEvent) -> void:
	chapters[current_chapter].input(event)

func reset_game() -> void:
	current_chapter = 2
	chapters[current_chapter].start()

func next_chapter() -> void:
	var old_id = current_chapter
	current_chapter = (current_chapter + 1) % len(chapters)
	chapters[current_chapter].start()
	if old_id != current_chapter:
		chapters[old_id].end()

func _on_Chapter_Ended(chapter: Chapter) -> void:
	next_chapter()

func _on_Environment_change(night: bool) -> void:
	if night:
		env.environment.background_sky.sky_energy = .05
		env.environment.background_sky.sky_top_color = Color.black
	else:
		env.environment.background_sky.sky_energy = 1.0
		env.environment.background_sky.sky_top_color = Color(0.65, .83, .94)
