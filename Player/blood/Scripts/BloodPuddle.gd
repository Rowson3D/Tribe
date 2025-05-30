extends Node2D

@export var lifespan: float = 10.0
@export var radius: int = 4

@onready var sprite: Sprite2D = $BloodLayer

func _ready():
	lifespan += randf_range(-2.0, 2.0)
	var width = randi_range(2, 11)
	var height = randi_range(2, 5)
	sprite.texture = create_flat_blot_texture(width, height, Color8(140 + randi() % 30, 0, 0, 255))

	sprite.scale = Vector2.ONE  # don't scale — it's already sized
	sprite.rotation = 0  # make 100% sure there's no rotation



	# Fade out over time
	var tween = create_tween()
	tween.tween_property(sprite, "modulate:a", 0.0, lifespan).set_trans(Tween.TRANS_LINEAR)
	tween.tween_callback(Callable(self, "queue_free"))


func create_flat_blot_texture(width: int, height: int, color: Color) -> ImageTexture:
	var image = Image.create(width, height, false, Image.FORMAT_RGBA8)

	var center = Vector2(width / 2, height / 2)

	for x in width:
		for y in height:
			var dx = (x - center.x) / (width / 2)
			var dy = (y - center.y) / (height / 2)
			if dx * dx + dy * dy <= 1.0:
				image.set_pixel(x, y, color)

	return ImageTexture.create_from_image(image)
