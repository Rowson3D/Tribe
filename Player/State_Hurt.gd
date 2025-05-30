extends State
class_name State_Hurt

@onready var inventory: Inventory = preload("res://Player/Inventory/PlayerInventory.tres")

#Hurtbox
@onready var hurtbox : Area2D = $"../../Combat/Hurtbox"
@onready var blink_animation_player : AnimationPlayer = $"../../Combat/BlinkAnimationPlayer"
@onready var damage_numbers_origin : Node2D = $"../../Combat_UI/DamageNumbersOrigin"
@onready var health_bar : ProgressBar = $"../../User_Interface/Sprite2D/Healthbar"

# States
@onready var hurt : Node2D = $"../Hurt"
@onready var idle : Node2D = $"../Idle"
@onready var evade : Node2D = $"../Evade"

@onready var default_shader = preload("res://Player/WhiteColor.gdshader")

func Enter():
	health_bar.max_value = player.player_data.max_HP
	health_bar.init_health(player.player_data.HP)
	
func Exit():
	player.player_data.disconnect("no_HP", Callable(self, "playerDead"))
	
func Process(_delta : float) -> State:
	return null
	
func Physics(_delta : float) -> State: 
	#Stop Movement
	player.velocity = Vector2.ZERO
	return null
	
func takeDamage(area):
	var is_critical = false
	var critical_chance = randf()

	if critical_chance <= 0.1:
		is_critical = true
		var critical_multiplier = randf_range(1.2, 2) # Crit chance between these values
		player.player_data.HP -= area.damage * critical_multiplier # Apply critical damage
		DamageNumbers.display_number(area.damage * critical_multiplier, damage_numbers_origin.global_position, is_critical)
	else:
		player.player_data.HP -= area.damage
		DamageNumbers.display_number(area.damage, damage_numbers_origin.global_position, is_critical)
	
	# If player node is invalid or being freed, bail safely
	if player == null or !player.is_inside_tree():
		return

	# Clamp HP minimum
	if player.player_data.HP <= 0:
		player.player_data.HP = 0
		if is_instance_valid(health_bar):
			health_bar.health = 0
		GameManager.trigger_player_death()
		return

	# Safe to update health bar
	if is_instance_valid(health_bar):
		health_bar.health = player.player_data.HP
		health_bar.max_value = player.player_data.max_HP

		if player.player_data.HP < player.player_data.max_HP:
			health_bar.visible = true


		
func _on_hurtbox_area_entered(area):
	takeDamage(area)

	if area.has_method("projectile"):
		area.queue_free()

	# Calculate hit direction for blood effect
	var hit_direction: Vector2 = (area.global_position - player.global_position).normalized()

	hit_direction = Vector2.RIGHT if hit_direction.x > 0 else Vector2.LEFT


	player.spawn_blood_splatter(hit_direction)
	player.spawn_blood_puddles(hit_direction)

	hurtbox.start_invincibility(0.6)
	AudioManager.get_node("Hurt").play()


		
func _on_hurtbox_invincibility_started():
	if state_machine.current_state == evade:
		blink_animation_player.play("Evade")
	else:
		blink_animation_player.play("Start")

func _on_hurtbox_invincibility_ended():
	#player.player_sprite.material.set("shader", default_shader)
	player.sword_sprite.material.set("shader", default_shader)
	blink_animation_player.play("Stop")
