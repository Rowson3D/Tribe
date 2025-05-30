extends CanvasLayer
class_name debugHUD

@onready var debug_label = $DebugLabel
@onready var system_label = $SystemLabel
var player: Node = null

func _process(_delta):
	if player == null:
		player = get_tree().get_root().find_child("Player", true, false)
		if not player:
			debug_label.text = "[DEBUG] Player not found."
			system_label.text = "[SYSTEM] Player missing..."
			return

	var pd = player.player_data

	# === DEBUG HUD ===
	var debug_text := "[DEBUG HUD]\n"
	debug_text += "• Scene: " + get_tree().current_scene.name + "\n"
	debug_text += "• Position: " + str(player.global_position.round()) + "\n"
	debug_text += "• State: " + player.state_machine.current_state.name + " (" + player.state_machine.current_state.get_class() + ")\n"

	# Player stats
	debug_text += "• Level: " + str(pd.Level) + "\n"
	debug_text += "• XP: " + str(pd.current_xp) + " / " + str(pd.get_required_experience(pd.Level)) + "\n"
	debug_text += "• HP: " + str(pd.HP) + " / " + str(pd.max_HP) + "\n"
	debug_text += "• Strength: " + str(pd.Strength) + "\n"
	debug_text += "• Magic: " + str(pd.Magic) + "\n"
	debug_text += "• Agility: " + str(pd.Agility) + "\n"
	debug_text += "• Defense: " + str(pd.Defense) + "\n"

	# Combat status
	debug_text += "• Base DMG: " + str(pd.base_damage) + "\n"
	debug_text += "• Weapon Equipped: " + str(player.weapon_equipped) + "\n"
	debug_text += "• Attack Timer: " + str(player.attack_timer.time_left) + "s\n"

	# Movement and direction
	debug_text += "• Velocity: " + str(player.velocity.round()) + "\n"
	debug_text += "• Aim Dir: " + str(player.aim_direction.round()) + "\n"
	debug_text += "• Inventory Full: " + str(player.inventory_full) + "\n"

	# Time / Save Info
	debug_text += "• Time of Day: " + str(pd.time) + "\n"
	debug_text += "• Save Exists: " + str(FileAccess.file_exists(player.save_file_path + player.save_file_name)) + "\n"

	# Inventory quick peek
	var items := []
	for slot in player.inventory.slots:
		if slot.item:
			items.append(slot.item.name)
	debug_text += "• Inventory Items: " + str(items.slice(0, 3)) + "\n"

	debug_label.text = debug_text

	# === SYSTEM HUD ===
	var fps := Engine.get_frames_per_second()
	var mem := Performance.get_monitor(Performance.MEMORY_STATIC)
	var obj_count := Performance.get_monitor(Performance.OBJECT_COUNT)
	var node_count := Performance.get_monitor(Performance.OBJECT_NODE_COUNT)
	var window_size := DisplayServer.window_get_size()

	var system_text := "[SYSTEM STATS]\n"
	system_text += "• FPS: " + str(fps) + "\n"
	system_text += "• Static Mem: " + str(mem / 1024 / 1024.0).pad_decimals(2) + " MB\n"
	system_text += "• Node Count: " + str(node_count) + "\n"
	system_text += "• Object Count: " + str(obj_count) + "\n"
	system_text += "• Threads: " + str(OS.get_processor_count()) + "\n"
	system_text += "• Platform: " + OS.get_name() + "\n"
	system_text += "• Resolution: " + str(window_size) + "\n"

	system_label.text = system_text
