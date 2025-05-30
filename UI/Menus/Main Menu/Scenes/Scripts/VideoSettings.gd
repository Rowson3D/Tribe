extends Control

@onready var resolution_option := $ResolutionOptionButton
@onready var fullscreen_checkbox := $FullscreenCheckBox

func _ready():
	SettingsManager.load_config()

	# Load values
	var resolution = SettingsManager.get_setting("video", "resolution", "1920x1080")
	var fullscreen = SettingsManager.get_setting("video", "fullscreen", false)

	resolution_option.select(_get_index_from_resolution(resolution))
	fullscreen_checkbox.button_pressed = fullscreen

func _on_resolution_changed(index):
	var res_text = resolution_option.get_item_text(index)
	SettingsManager.set_setting("video", "resolution", res_text)
	SettingsManager.save_config()

func _on_fullscreen_toggled(pressed):
	SettingsManager.set_setting("video", "fullscreen", pressed)
	SettingsManager.save_config()

func _get_index_from_resolution(text: String) -> int:
	for i in range(resolution_option.item_count):
		if resolution_option.get_item_text(i) == text:
			return i
	return 0
