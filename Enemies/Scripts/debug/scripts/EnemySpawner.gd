extends Node
class_name EnemySpawner

func _input(event):
	if event.is_action_pressed("spawn_enemies"):
		spawn_all_enemies()

func spawn_all_enemies():
	var spawn_points = get_tree().get_nodes_in_group("enemy_spawns")
	print("Found %d spawn points" % spawn_points.size())  # 👈 Debug output
	for spawn_point in spawn_points:
		if spawn_point.has_method("spawn_enemy"):
			spawn_point.spawn_enemy()
			print("Spawned at", spawn_point.global_position)
