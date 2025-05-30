extends Node
class_name Scene_Manager

var last_scene_name: String 
var current_scene: String
var time_system_enabled := false
#var scene_dir_path := "res://UI/Menus/Main Menu/"

func _ready():
	var root_scene := get_tree().current_scene
	if root_scene:
		current_scene = root_scene.scene_file_path.get_file().trim_suffix(".tscn")
		print("[SceneManager] Auto-initialized current_scene:", current_scene)
	else:
		print("[SceneManager] ⚠️ Could not auto-detect current scene.")


func change_scene(from: Node, to_scene: String) -> void:
	last_scene_name = from.name
	current_scene = to_scene.get_file().trim_suffix(".tscn")

	var full_path: String

	# If it's a full path already, use it directly
	if to_scene.begins_with("res://") and to_scene.ends_with(".tscn"):
		full_path = to_scene
	else:
		full_path = find_scene_path_recursive("res://", to_scene)
		if full_path == "":
			print("[SceneManager] ❌ Could not find scene:", to_scene)
			return

	print("\n[SceneManager] --- Scene Transition Triggered ---")
	print("[SceneManager] Current Scene: ", last_scene_name)
	print("[SceneManager] Target Scene: ", to_scene)
	print("[SceneManager] Full Path: ", full_path)

	print("[SceneManager] Playing transition effect.")
	TransitionScene.transition() 

	print("[SceneManager] Stopping footstep audio.")
	if AudioManager.has_node("Footsteps_Grass"):
		AudioManager.get_node("Footsteps_Grass").stop()
	if AudioManager.has_node("Footsteps_Stone"):
		AudioManager.get_node("Footsteps_Stone").stop()

	if AudioManager.has_node("Scene_Transition"):
		print("[SceneManager] Playing scene transition sound.")
		AudioManager.get_node("Scene_Transition").play()
	else:
		print("[SceneManager] ⚠️ Scene_Transition sound not found.")

	print("[SceneManager] Requesting scene load...")
	from.get_tree().call_deferred("change_scene_to_file", full_path)
	
func find_scene_path_recursive(base_dir: String, scene_name: String) -> String:
	var dir = DirAccess.open(base_dir)
	if dir == null:
		print("[SceneManager] ⚠️ Could not open directory:", base_dir)
		return ""

	dir.list_dir_begin()
	while true:
		var file = dir.get_next()
		if file == "":
			break
		var full_path: String = base_dir + "/" + file

		if dir.current_is_dir():
			if file != "." and file != "..":
				var result = find_scene_path_recursive(full_path, scene_name)
				if result != "":
					return result
		elif file == scene_name + ".tscn":
			return full_path

	dir.list_dir_end()
	return ""
