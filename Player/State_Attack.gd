extends State
class_name State_Attack

@onready var attack_combo : Node2D = $"../Attack_Combo"
@onready var run : Node2D = $"../Run"
@onready var idle : Node2D = $"../Idle"

var bonus_dmg: int = 15
var attacking: bool = false

func Enter():
	player.animation_tree.set("parameters/Attack/BlendSpace2D/blend_position", player.aim_direction)
	player.animation_tree.set("parameters/Idle/blend_position", player.aim_direction) # <- same as State_Move
	player.player_data.KNOCKOUT_SPEED = 60
	player.calculateDmg(bonus_dmg)
	player.UpdateAnimation("Attack")
	player.attack_timer.start()
	player.animation_tree.animation_finished.connect(endAttack)
	attacking = true

func Exit() -> void:
	player.animation_tree.animation_finished.disconnect(endAttack)
	player.attack_timer.stop()

func Process(_delta : float) -> State:
	return null

func Physics(_delta : float) -> State:
	player.velocity = Vector2.ZERO

	if !player.attack_timer.is_stopped():
		if Input.is_action_pressed("attack") and !attacking:
			return attack_combo

		if Input.is_action_pressed("Move_Down") or Input.is_action_pressed("Move_Up") or Input.is_action_pressed("Move_Right") or Input.is_action_pressed("Move_Left"):
			if !attacking and player.attack_timer.get_time_left() <= 1.7:
				return run
		return

	if !attacking:
		return idle

	return null

func _on_attack_timer_timeout():
	state_machine.ChangeState(idle)

func endAttack(_newAnimName : String):
	attacking = false
