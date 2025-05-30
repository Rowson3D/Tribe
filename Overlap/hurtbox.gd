extends Area2D

const HitEffect = preload("res://Effects/Scenes/hit_effect.tscn")

@export var invincible: bool = false

@onready var timer = $Timer
@onready var collision_shape = $CollisionShape2D

signal invincibility_started
signal invincibility_ended

func start_invincibility(duration: float) -> void:
	invincible = true
	emit_signal("invincibility_started")
	timer.start(duration)

func create_hit_effect(hurt_position: Vector2) -> void:
	var effect = HitEffect.instantiate()
	var main = get_tree().current_scene
	main.add_child(effect)
	effect.global_position = hurt_position

	# Try to flash the parent sprite
	var sprite = get_parent().get_node_or_null("PlayerSprite")  # Rename if needed
	if sprite and sprite is CanvasItem:
		_flash_sprite(sprite)

func _flash_sprite(sprite: CanvasItem) -> void:
	var original_color: Color = sprite.modulate
	sprite.modulate = Color(1, 1, 1, 1)  # Full white flash

	var tween = create_tween()
	tween.tween_property(sprite, "modulate", original_color, 0.25).set_trans(Tween.TRANS_SINE)

func _on_timer_timeout() -> void:
	invincible = false
	emit_signal("invincibility_ended")

func _on_invincibility_started() -> void:
	collision_shape.set_deferred("disabled", true)

func _on_invincibility_ended() -> void:
	collision_shape.disabled = false
