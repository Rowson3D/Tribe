extends Node2D

@onready var color_rect: ColorRect = $ColorRect
@onready var logo: Sprite2D = $ColorRect/Sprite2D
@onready var timer: Timer = $Timer

@export_file("*.tscn") var next_scene_path := "res://UI/Menus/Main Menu/Main_Menu.tscn"
@export var fade_duration := 1.0

func _ready():
	color_rect.color.a = 1.0
	logo.modulate.a = 0.0

	if !timer:
		push_error("❌ Timer node not found!")
		return

	print("✅ Timer found. Setting up fade-in sequence.")
	var tween = create_tween()
	tween.tween_property(color_rect, "color:a", 0.0, fade_duration)
	tween.tween_property(logo, "modulate:a", 1.0, 0.5).set_delay(0.3)
	tween.tween_callback(func():
		print("🕒 Starting timer (1.5s)...")
		timer.start(1.5)
	)

func _on_timer_timeout() -> void:
	print("✅ Timer timeout reached. Fading out...")
	var tween = create_tween()
	tween.tween_property(logo, "modulate:a", 0.0, 0.3)
	tween.tween_property(color_rect, "color:a", 1.0, fade_duration)
	tween.tween_callback(func():
		print("🎬 Changing scene to:", next_scene_path)
		scene_manager.change_scene(self, next_scene_path)
	)

func _unhandled_input(event):
	if event.is_pressed():
		print("⏩ Skip input detected, jumping to next scene.")
		scene_manager.change_scene(self, next_scene_path)
