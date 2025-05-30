extends Node2D

@onready var new_game_button = $"Camera2D/Control/ColorRect/Main Menu/NewButton"
@onready var load_game_button = $"Camera2D/Control/ColorRect/Main Menu/LoadButton"
@onready var options_button = $"Camera2D/Control/ColorRect/Main Menu/OptionButton"
@onready var quit_button = $"Camera2D/Control/ColorRect/Main Menu/QuitButton"
@onready var version_label = $Camera2D/Control/ColorRect/VersionLabel
@onready var menu_buttons = $"Camera2D/Control/ColorRect/Main Menu"

@onready var options_popup_scene := preload("res://UI/Menus/Main Menu/Scenes/OptionsPopup.tscn")
@onready var newgame_popup_scene := preload("res://UI/Menus/Main Menu/Scenes/NewGamePopup.tscn")
@onready var loadgame_popup_scene := preload("res://UI/Menus/Main Menu/Scenes/LoadGamePopup.tscn")

func _ready():
	new_game_button.pressed.connect(_on_new_game_pressed)
	load_game_button.pressed.connect(_on_load_game_pressed)
	options_button.pressed.connect(_on_options_pressed)
	quit_button.pressed.connect(_on_quit_pressed)
	
	version_label.text = "Version " + ProjectSettings.get_setting("application/config/version")

func _on_new_game_pressed():
	print("🆕 New Game selected")
	scene_manager.change_scene(self, "Debug")

func _on_load_game_pressed():
	print("📂 Load Game selected")
	# Instance options
	var popup = loadgame_popup_scene.instantiate()

	# Hide menu
	menu_buttons.visible = false

	# Connect close signal so we know when to show menu again
	popup.close_requested.connect(func():
		popup.queue_free()
		menu_buttons.visible = true
	)

	# Add to UI
	$Camera2D/Control/ColorRect.add_child(popup)

func _on_options_pressed():
	print("⚙️ Options selected")

	# Instance options
	var popup = options_popup_scene.instantiate()

	# Hide menu
	menu_buttons.visible = false

	# Connect close signal so we know when to show menu again
	popup.close_requested.connect(func():
		popup.queue_free()
		menu_buttons.visible = true
	)

	# Add to UI
	$Camera2D/Control/ColorRect.add_child(popup)

func _on_quit_pressed():
	print("🚪 Quit selected")
	get_tree().quit()
