extends Node
class_name GoldNumbers

@export var fade_time: float = 0.6
@export var float_distance: float = 24
@export var font_color: Color = Color("#FFD700") # Gold
@export var font_size: int = 12
@export var outline_color: Color = Color(0, 0, 0)
@export var outline_size: int = 2
@export var font: Font = preload("res://UI/Font/Abaddon-Bold.ttf")

func display(amount: int, position: Vector2) -> void:
	position += Vector2(-12, 0)
	var label := Label.new()
	label.text = "+%d Ri" % amount
	label.global_position = position
	label.z_index = 80

	# Configure style
	var settings = LabelSettings.new()
	settings.font_color = font_color
	settings.font_size = font_size
	settings.outline_color = outline_color
	settings.outline_size = outline_size
	settings.font = font
	label.label_settings = settings

	get_tree().current_scene.add_child(label)

	# Animate
	var tween := get_tree().create_tween()
	tween.tween_property(label, "position:y", label.position.y - float_distance, fade_time).set_trans(Tween.TRANS_SINE)
	tween.tween_property(label, "modulate:a", 0.0, fade_time).set_delay(0.1)
	tween.tween_callback(func(): label.queue_free())
