class_name OptionsMenu
extends MarginContainer

signal continue_clicked
signal options_clicked
signal back_clicked

onready var dropdown := $Menu/Container/Options/List/Locales/OptionButton as OptionButton
onready var sound_slider := $Menu/Container/Options/List/Sound/HSlider as HSlider
onready var mouse_slider := $Menu/Container/Options/List/Mouse/HSlider as HSlider

var locales = []

func _ready() -> void:
	var i = 0
	locales = []
	var popup := dropdown.get_popup()
	var current_locale = TranslationServer.get_locale()
	for locale in TranslationServer.get_loaded_locales():
		popup.add_item(tr("ui_locale_%s") % locale, i)
		locales.push_back(locale)
		if current_locale.begins_with(locale):
			dropdown.select(i)
		i += 1
	mouse_slider.set_value(Data.get_mouse_sensitivity_amount())
	sound_slider.set_value(Data.get_master_bus_amount())

func open() -> void:
	visible = true

func _on_Back_pressed() -> void:
	emit_signal("back_clicked")

func _on_MenuButton_item_selected(index: int) -> void:
	TranslationServer.set_locale(locales[index])

func _on_Mouse_Slider_value_changed(value: float) -> void:
	Data.change_mouse_sensitivity(value)

func _on_Music_Slider_value_changed(value: float) -> void:
	Data.change_master_bus_volume(value)
