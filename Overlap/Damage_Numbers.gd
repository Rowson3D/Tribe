extends Node

# Preload font resources
var default_font: Font = preload("res://UI/Font/Abaddon-Bold.ttf")

# Configuration
@export_category("Appearance")
@export var default_font_size: int = 16
@export var critical_font_size: int = 24
@export var miss_font_size: int = 14
@export var heal_font_size: int = 16
@export var fade_time: float = 0.75
@export var float_distance: float = 40
@export var float_time: float = 0.75
@export var shake_intensity: float = 2.0

@export_category("Colors")
@export var normal_color: Color = Color("#FFFFFF")
@export var critical_color: Color = Color("#FF2222")
@export var miss_color: Color = Color("#FFFFFF88")
@export var heal_color: Color = Color("#22FF22")
@export var poison_color: Color = Color("#AA22FF")
@export var fire_color: Color = Color("#FF8800")
@export var ice_color: Color = Color("#00CCFF")
@export var outline_color: Color = Color("#000000")
@export var outline_size: int = 3

@export_category("Effects")
@export var use_particles: bool = true
@export var critical_shake: bool = true

# Enums for damage types
enum DamageType {NORMAL, CRITICAL, MISS, HEAL, POISON, FIRE, ICE}

func _ready():
	# Check if we need to load default font
	if default_font == null and ResourceLoader.exists("res://default_theme.tres"):
		var theme = load("res://default_theme.tres")
		if theme is Theme:
			default_font = theme.get_default_font()

## Display damage number with enhanced visual effects
## 
## Parameters:
## - value: The number to display (int or float)
## - position: World position to show the number
## - damage_type: Type of damage from DamageType enum
## - custom_color: Optional custom color override
## - custom_scale: Optional custom scale for the number
func display_number(value, position: Vector2, damage_type: int = DamageType.NORMAL, custom_color: Color = Color.TRANSPARENT, custom_scale: float = 1.0):
	# Create label instance
	var number = Label.new()
	number.global_position = position
	number.z_index = 5
	number.label_settings = LabelSettings.new()
	
	# Apply font if available
	if default_font != null:
		number.label_settings.font = default_font
	
	# Format the value
	if value is int:
		number.text = str(value)
	elif value is float:
		number.text = "%.1f" % value
	else:
		number.text = str(value)
	
	# Add prefix for healing
	if damage_type == DamageType.HEAL:
		number.text = "+" + number.text
	
	# Configure appearance based on damage type
	var color = normal_color
	var font_size = default_font_size
	var particle_color = normal_color
	var should_shake = false
	
	match damage_type:
		DamageType.CRITICAL:
			color = critical_color
			font_size = critical_font_size
			should_shake = critical_shake
			number.text = number.text + "!"
		DamageType.MISS:
			color = miss_color
			font_size = miss_font_size
			number.text = "MISS"
		DamageType.HEAL:
			color = heal_color
			font_size = heal_font_size
		DamageType.POISON:
			color = poison_color
		DamageType.FIRE:
			color = fire_color
		DamageType.ICE:
			color = ice_color
	
	# Override with custom color if provided
	if custom_color != Color.TRANSPARENT:
		color = custom_color
	
	# Apply color and font settings
	number.label_settings.font_color = color
	number.label_settings.font_size = font_size * custom_scale
	number.label_settings.outline_color = outline_color
	number.label_settings.outline_size = outline_size
	
	# Add to scene
	call_deferred("add_child", number)
	
	# Wait until the label is properly sized
	await number.resized
	
	# Center the number
	number.pivot_offset = Vector2(number.size / 2)
	
	# Apply initial effects
	number.scale = Vector2.ONE * 0.5
	
	# Create particles if enabled
	if use_particles and damage_type != DamageType.MISS:
		_create_particles(number.global_position, color, damage_type)
	
	# Create the animation tween
	var tween = get_tree().create_tween()
	tween.set_parallel(true)
	
	# Pop-in animation
	tween.tween_property(number, "scale", Vector2.ONE * custom_scale, 0.1).set_ease(Tween.EASE_OUT)
	
	# Apply shake for critical hits
	if should_shake:
		_apply_shake(number, tween)
	
	# Float upward animation
	var random_x_offset = randf_range(-10, 10) # Add some horizontal randomness
	tween.tween_property(
		number, "position:y", number.position.y - float_distance, float_time
	).set_ease(Tween.EASE_OUT)
	tween.tween_property(
		number, "position:x", number.position.x + random_x_offset, float_time
	).set_ease(Tween.EASE_OUT)
	
	# Fade out animation
	tween.tween_property(
		number, "modulate:a", 0.0, fade_time
	).set_ease(Tween.EASE_IN).set_delay(float_time - 0.2)
	
	# Clean up when finished
	await tween.finished
	number.queue_free()

## Create particle effects for damage numbers
func _create_particles(pos: Vector2, color: Color, damage_type: int):
	var particles = CPUParticles2D.new()
	particles.global_position = pos
	particles.z_index = 4
	particles.emitting = true
	particles.one_shot = true
	particles.explosiveness = 0.9
	particles.amount = 6
	particles.lifetime = 0.6
	particles.speed_scale = 1.5
	particles.direction = Vector2(0, -1)
	particles.spread = 70.0
	particles.gravity = Vector2(0, 98)
	particles.initial_velocity_min = 20.0
	particles.initial_velocity_max = 40.0
	particles.color = color
	
	# Customize based on damage type
	if damage_type == DamageType.CRITICAL:
		particles.amount = 10
		particles.lifetime = 0.8
	elif damage_type == DamageType.HEAL:
		particles.texture = _create_heal_particle_texture()
		particles.scale_amount = 2.0
	
	call_deferred("add_child", particles)
	
	# Remove when done
	await get_tree().create_timer(particles.lifetime * 1.5).timeout
	particles.queue_free()

## Apply shake effect to the number
func _apply_shake(label: Label, tween: Tween):
	var original_pos = label.position
	
	for i in range(5):
		var shake_offset = Vector2(
			randf_range(-shake_intensity, shake_intensity),
			randf_range(-shake_intensity, shake_intensity)
		)
		tween.tween_property(
			label, "position", original_pos + shake_offset, 0.05
		).set_delay(i * 0.05)
	
	tween.tween_property(
		label, "position", original_pos, 0.05
	).set_delay(0.25)

## Create a simple texture for heal particles
func _create_heal_particle_texture() -> Texture2D:
	var img = Image.create(4, 4, false, Image.FORMAT_RGBA8)
	img.fill(Color(1, 1, 1, 1))
	var texture = ImageTexture.create_from_image(img)
	return texture

## Display a damage number - simplified version of the main function
func display_simple_number(value: int, position: Vector2, is_critical: bool = false):
	var damage_type = DamageType.NORMAL
	if is_critical:
		damage_type = DamageType.CRITICAL
	elif value == 0:
		damage_type = DamageType.MISS
	
	display_number(value, position, damage_type)

## Display healing number
func display_healing(value: int, position: Vector2):
	display_number(value, position, DamageType.HEAL)

## Display element-based damage
func display_elemental_damage(value: int, position: Vector2, element_type: int):
	display_number(value, position, element_type)

## Display damage with custom color
func display_custom_damage(value: int, position: Vector2, color: Color):
	display_number(value, position, DamageType.NORMAL, color)

## Display a combo counter (larger scale, custom animation)
func display_combo(combo_count: int, position: Vector2):
	var combo_scale = min(1.0 + (combo_count * 0.05), 2.0)
	display_number("x" + str(combo_count), position, DamageType.NORMAL, Color("#FFCC00"), combo_scale)
