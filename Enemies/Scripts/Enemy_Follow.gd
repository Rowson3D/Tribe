extends EnemyState
class_name Enemy_Follow

@onready var follow : Node2D = $"../Follow"
@onready var melee : Node2D = $"../MeleeAttack"
@onready var idle : Node2D = $"../Idle"
@onready var player_detection_zone : Area2D = $"../../PlayerDetection"
@onready var soft_collision : Area2D = $"../../SoftCollision"
	
func Physics(delta : float) -> EnemyState:
		
	if player != null:
		enemy.velocity = enemy.velocity.move_toward(Vector2.ZERO, enemy.FRICTION * delta)
		accelerate_towards_point(player.global_position, delta)
	
	if owner.direction.length() <= 5:
		return melee
		
	if soft_collision.is_colliding():
		enemy.velocity += soft_collision.get_push_vector() * delta * 400
	
	enemy.move_and_slide()
	return null
			
func accelerate_towards_point(point, delta):
	var direction = global_position.direction_to(point)
	enemy.velocity = enemy.velocity.move_toward(direction * enemy.MAX_SPEED, enemy.ACCELERATION * delta)
