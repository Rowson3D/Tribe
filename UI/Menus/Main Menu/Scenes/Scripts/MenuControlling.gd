extends Control

@onready var video_button = $Background/HBoxContainer/VideoButton
@onready var audio_button = $Background/HBoxContainer/AudioButton
@onready var controls_button = $Background/HBoxContainer/ControlsButton

@onready var video_tab = $Background/VideoTab
@onready var audio_tab = $Background/AudioTab
@onready var controls_tab = $Background/ControlsTab

signal close_requested

func _ready():
	video_button.pressed.connect(show_video_tab)
	audio_button.pressed.connect(show_audio_tab)
	controls_button.pressed.connect(show_controls_tab)

func _unhandled_input(event):
	if event.is_action_pressed("ui_cancel"):
		close_requested.emit()
		queue_free()
		print("Queue has been freed...")

	show_video_tab()  # default
	
func set_active_tab(active_button: Button):
	var all_buttons = [video_button, audio_button, controls_button]
	for btn in all_buttons:
		btn.disabled = false
		btn.modulate = Color.WHITE
	active_button.disabled = true

func show_video_tab():
	video_tab.visible = true
	audio_tab.visible = false
	controls_tab.visible = false
	set_active_tab(video_button)

func show_audio_tab():
	video_tab.visible = false
	audio_tab.visible = true
	controls_tab.visible = false
	set_active_tab(audio_button)

func show_controls_tab():
	video_tab.visible = false
	audio_tab.visible = false
	controls_tab.visible = true
	set_active_tab(controls_button)


func _on_cancel_button_pressed() -> void:
	close_requested.emit()
