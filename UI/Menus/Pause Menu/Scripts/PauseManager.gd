extends Node

## Pause menu singleton that manages showing, hiding, and routing button input.
## Works with UI layout:
## PauseMenu > Control > Option Menu > [LoadButton, OptionButton, MenuButton, QuitButton]

var pause_menu_instance: Node = null
var pause_menu_scene := preload("res://UI/Menus/Pause Menu/pause menu.tscn")
## List of scene paths where the pause menu is disabled
var pause_disabled_scenes := [
	"res://UI/Menus/Main Menu/Main_Menu.tscn",
	"res://Scenes/Splash Screen/MadeWithGodot.tscn",
	"res://Scenes/Splash Screen/StudioSplashScreen.tscn"
]


func _ready() -> void:
	set_process_mode(PROCESS_MODE_ALWAYS)
	print("[PauseManager] Initialized")

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		if _can_pause():
			print("[PauseManager] Pausing...")
			toggle_pause()
		else:
			print("[PauseManager] Pause is disabled in this scene.")
			
func _can_pause() -> bool:
	var current_scene := get_tree().current_scene
	if current_scene == null:
		return true

	var scene_path := current_scene.scene_file_path
	return not pause_disabled_scenes.has(scene_path)

func show_pause_menu() -> void:
	if pause_menu_instance == null:
		pause_menu_instance = pause_menu_scene.instantiate()
		pause_menu_instance.set_process_mode(PROCESS_MODE_ALWAYS)
		get_tree().root.add_child(pause_menu_instance)

		# Connect all button signals based on the scene structure
		var button_callbacks = {
			"Control/ColorRect/Option Menu/LoadButton": _on_load_button_pressed,
			"Control/ColorRect/Option Menu/OptionButton": _on_option_button_pressed,
			"Control/ColorRect/Option Menu/MenuButton": _on_menu_button_pressed,
			"Control/ColorRect/Option Menu/QuitButton": _on_quit_button_pressed,
		}

		for path in button_callbacks.keys():
			_connect_button(path, button_callbacks[path])

	get_tree().paused = true
	pause_menu_instance.visible = true
	print("[PauseManager] Pause menu shown.")

func hide_pause_menu() -> void:
	if pause_menu_instance:
		pause_menu_instance.visible = false
	get_tree().paused = false
	print("[PauseManager] Pause menu hidden.")

func toggle_pause() -> void:
	if get_tree().paused:
		hide_pause_menu()
	else:
		show_pause_menu()

func _connect_button(path: String, callback: Callable) -> void:
	var button = pause_menu_instance.get_node_or_null(path)
	if button:
		if not button.pressed.is_connected(callback):
			button.pressed.connect(callback)
			print("[PauseManager] Connected:", path)
		else:
			print("[PauseManager] Already connected:", path)
	else:
		push_warning("❌ PauseManager: Could not find button at path: " + path)

## ------------------------
## Button Action Callbacks
## ------------------------

func _on_quit_button_pressed() -> void:
	print("[PauseManager] Quit button pressed")
	get_tree().quit()

func _on_menu_button_pressed() -> void:
	print("[PauseManager] Menu button pressed")
	get_tree().paused = false
	get_tree().change_scene_to_file("res://UI/Menus/Main Menu/Main_Menu.tscn")
	hide_pause_menu()

func _on_option_button_pressed() -> void:
	print("[PauseManager] Option button pressed")
	#var options_menu_scene := preload("res://UI/Menus/Options Menu/OptionsMenu.tscn")
	#var options_menu := options_menu_scene.instantiate()
	#options_menu.set_process_mode(PROCESS_MODE_ALWAYS)
	#get_tree().root.add_child(options_menu)
	#options_menu.z_index = 100  # Ensures it appears on top

func _on_load_button_pressed() -> void:
	print("[PauseManager] Load button pressed")
	#if "LoadManager" in ProjectSettings.get_setting("autoload"):
		#LoadManager.load_last_save()
	#else:
		#push_warning("❌ LoadManager autoload not found.")
