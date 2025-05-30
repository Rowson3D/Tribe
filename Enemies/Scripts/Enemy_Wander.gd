# Enemy_Wander.gd
extends EnemyState
class_name Enemy_Wander

@onready var follow: Node2D = $"../Follow"
@onready var idle: Node2D = $"../Idle"
@onready var wander_controller: Node2D = $"../../WanderController"

func Enter():
	wander_controller.update_target_position()
	wander_controller.start_wander_timer(randf_range(1.5, 3.0))
	enemy.update_movement_anim()

func Physics(delta: float) -> EnemyState:
	if player and global_position.distance_to(player.global_position) < 100:
		return follow

	enemy.accelerate_toward(wander_controller.target_position, delta)
	enemy.face_direction(enemy.velocity)
	enemy.update_movement_anim()

	if global_position.distance_to(wander_controller.target_position) < 8:
		return idle

	enemy.move_and_slide()
	return null
