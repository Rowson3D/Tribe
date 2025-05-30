extends AnimatedSprite2D

@export var flash_count: int = 5
@export var flash_interval: float = 0.1
@export var hold_time: float = 10

func _ready():
	play("Animate")
	connect("animation_finished", Callable(self, "_on_animation_finished"))

func _on_animation_finished():
	await get_tree().create_timer(hold_time).timeout
	await flash_then_disappear()

func flash_then_disappear():
	for i in flash_count:
		visible = false
		await get_tree().create_timer(flash_interval).timeout
		visible = true
		await get_tree().create_timer(flash_interval).timeout
	
	queue_free()
