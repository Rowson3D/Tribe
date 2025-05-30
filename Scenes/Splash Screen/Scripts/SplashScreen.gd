extends Node2D

@onready var video_player: VideoStreamPlayer = $ColorRect/VideoStreamPlayer
@onready var label: Label = $Label

@export_file("*.tscn") var next_scene_path := "res://Scenes/Splash Screen/StudioSplashScreen.tscn"

func _ready():
	print("🎥 Starting the video stream...")
	video_player.play()
	video_player.finished.connect(_on_video_finished)

	label.modulate.a = 0.0
	var tween = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_interval(1.0)
	tween.tween_property(label, "modulate:a", 1.0, 1.5)

func _on_video_finished():
	print("🎬 Splash finished. Changing to:", next_scene_path)
	scene_manager.change_scene(self, next_scene_path)

func _unhandled_input(event):
	if event.is_pressed():
		print("⏩ Skip input detected. Jumping to:", next_scene_path)
		scene_manager.change_scene(self, next_scene_path)
