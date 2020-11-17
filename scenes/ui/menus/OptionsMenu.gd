class_name OptionsMenu
extends MarginContainer

signal continue_clicked
signal options_clicked
signal back_clicked

onready var dropdown := $Menu/Container/Options/List/Locales/OptionButton as OptionButton

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

func open() -> void:
	visible = true

func _on_Back_pressed() -> void:
	emit_signal("back_clicked")

func _on_MenuButton_item_selected(index: int) -> void:
	TranslationServer.set_locale(locales[index])
