class_name Game
extends Spatial

onready var chapter_home := $ChapterHome as ChapterHome
onready var chapter_bar := $ChapterBar as ChapterBar

var current_chapter := 0
var chapters = []

func _ready() -> void:

	chapters = [
		chapter_home,
		chapter_bar,
#		'road': chapter_01,
#		'hospital': chapter_01,
	]

	for chapter in get_tree().get_nodes_in_group('chapter'):
		if chapter is Chapter:
			chapter.connect("chapter_ended", self, "_on_Chapter_Ended", [chapter])
	reset_game()
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _process(delta: float) -> void:
	chapters[current_chapter].process(delta)
	if Input.is_action_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		get_tree().quit()

func _physics_process(delta: float) -> void:
	chapters[current_chapter].physics_process(delta)

func _input(event: InputEvent) -> void:
	chapters[current_chapter].input(event)

func reset_game() -> void:
	current_chapter = 1
	chapters[current_chapter].start()

func next_chapter() -> void:
	var old_id = current_chapter
	current_chapter = (current_chapter + 1) % len(chapters)
	chapters[current_chapter].start()
	if old_id != current_chapter:
		chapters[old_id].end()

func _on_Chapter_Ended(chapter: Chapter) -> void:
	print("end of chapter %s" % chapter.name)
	next_chapter()
#	reset_game()
