extends Node2D
class_name EnemyState

@export var enemy : Enemy_Base
@onready var state_machine : EnemyStateMachine = $".."
@onready var animation_player : AnimationPlayer = owner.find_child("AnimationPlayer")
var player

func _ready():
	player = get_tree().get_first_node_in_group("Player")

func Enter() -> void:
	pass
	
func Exit() -> void:
	pass
	
func Process(_delta : float) -> EnemyState:
	return null
	
func Physics( _delta : float) -> EnemyState:
	return null

func HandleInput(_event: InputEvent) -> EnemyState:
	return null
