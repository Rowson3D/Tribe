extends Node

@onready var logo_anim: AnimatedSprite2D = $AnimatedLogo
@onready var timer: Timer = $PlayDelayTimer

func _ready() -> void:
	logo_anim.stop()
	timer.timeout.connect(_on_timer_timeout)
	logo_anim.animation_finished.connect(_on_logo_animation_finished)

func _on_timer_timeout() -> void:
	logo_anim.play()

func _on_logo_animation_finished() -> void:
	timer.start()  # Wait again before playing next time
