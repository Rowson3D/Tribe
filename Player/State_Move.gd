extends State
class_name State_Move

#Speed
@export var ACCELERATION : int = 500
@export var MAX_SPEED : int = 80
@export var ROLL_SPEED : int = 80
@export var FRICTION : int = 500

@onready var idle : Node2D = $"../Idle"
@onready var evade : Node2D = $"../Evade"
@onready var attack : Node2D = $"../Attack"

func Enter():
	player.UpdateAnimation("Run")
	if scene_manager.current_scene == "World": 
		AudioManager.get_node("Footsteps_Grass").play()
	elif scene_manager.current_scene == "Dungeon_1":
		AudioManager.get_node("Footsteps_Stone").play()
	
func Exit():
	AudioManager.get_node("Footsteps_Grass").stop()
	AudioManager.get_node("Footsteps_Stone").stop()
	
func Process(_delta : float) -> State:
	return null
	
func Physics(delta : float) -> State:
	
	if Input.is_action_just_pressed("evade"):
		return evade
	
	if Input.is_action_pressed("attack") and player.weapon_equipped:
		return attack
		
	move_state(delta)
	
	return null
	
func move_state(delta):
		if player.input_vector != Vector2.ZERO: 
			evade.evade_vector = player.input_vector
			player.velocity = player.velocity.move_toward(player.input_vector * MAX_SPEED, ACCELERATION * delta) # This will be the direction we move to
			player.animation_tree.set("parameters/Run/blend_position", player.input_vector)
			player.animation_tree.set("parameters/Idle/blend_position", player.input_vector)
		else:
			state_machine.ChangeState(idle)
