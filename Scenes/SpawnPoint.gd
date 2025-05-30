extends Node2D
class_name SpawnPoint

## The enemy scene to instantiate at this spawn point.
@export var enemy_scene: PackedScene

## Optional: Automatically spawn on ready
@export var spawn_on_ready: bool = false

func _ready():
	if spawn_on_ready:
		spawn_enemy()

## Spawns the assigned enemy scene at this point.
func spawn_enemy():
	if enemy_scene == null:
		push_warning("No enemy_scene assigned to SpawnPoint at %s" % global_position)
		return

	var enemy_instance = enemy_scene.instantiate()
	get_tree().current_scene.add_child(enemy_instance)
	enemy_instance.global_position = global_position
