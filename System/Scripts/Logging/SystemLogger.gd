extends Node
class_name SystemLogger

var start_time := Time.get_unix_time_from_system()
var log_dir := "user://logs/"
var log_path := ""

func _ready():
	verify_log_directory()
	var timestamp = Time.get_datetime_string_from_system().replace(":", "-").replace(" ", "_")
	log_path = log_dir + "session_" + timestamp + ".log"
	print("[Logger] Logging to: ", ProjectSettings.globalize_path(log_path))

func verify_log_directory():
	if not DirAccess.dir_exists_absolute(log_dir):
		var result = DirAccess.make_dir_absolute(log_dir)
		if result != OK:
			print("❌ Could not create log directory:", result)

func log_on_exit():
	var session_duration := Time.get_unix_time_from_system() - start_time
	var log = []

	log.append("[SYSTEM SESSION LOG]")
	log.append("• Date: " + Time.get_date_string_from_system())
	log.append("• Time: " + Time.get_time_string_from_system())
	log.append("• Duration (s): " + str(session_duration))
	log.append("• Godot Version: " + Engine.get_version_info().get("string", "Unknown"))
	log.append("• Engine Target: " + OS.get_name())
	log.append("• Display Size: " + str(DisplayServer.window_get_size()))
	log.append("• Display Scale: " + str(DisplayServer.screen_get_scale()))
	log.append("• Monitor Count: " + str(DisplayServer.get_screen_count()))
	log.append("• Fullscreen: " + str(DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN))
	log.append("• FPS: " + str(Engine.get_frames_per_second()))
	log.append("• CPU Threads: " + str(OS.get_processor_count()))
	log.append("• Language: " + OS.get_locale())
	log.append("• Project Name: " + ProjectSettings.get_setting("application/config/name"))
	log.append("• Scene: " + get_tree().current_scene.name)
	log.append("")

	log.append("[MEMORY + OBJECTS]")
	log.append("• Static Memory (MB): " + str(Performance.get_monitor(Performance.MEMORY_STATIC) / 1024 / 1024.0).pad_decimals(2))
	log.append("• Static Memory Peak (MB): " + str(Performance.get_monitor(Performance.MEMORY_STATIC_MAX) / 1024 / 1024.0).pad_decimals(2))
	log.append("• Node Count: " + str(Performance.get_monitor(Performance.OBJECT_NODE_COUNT)))
	log.append("• Object Count: " + str(Performance.get_monitor(Performance.OBJECT_COUNT)))
	log.append("• Orphaned Nodes: " + str(Performance.get_monitor(Performance.OBJECT_ORPHAN_NODE_COUNT)))
	log.append("• Resource Count: " + str(Performance.get_monitor(Performance.OBJECT_RESOURCE_COUNT)))
	log.append("")

	var player := get_tree().get_root().find_child("Player", true, false)
	if player:
		var pd = player.player_data
		log.append("[PLAYER INFO]")
		log.append("• Level: " + str(pd.Level))
		log.append("• XP: " + str(pd.current_xp) + " / " + str(pd.get_required_experience(pd.Level)))
		log.append("• HP: " + str(pd.HP) + " / " + str(pd.max_HP))
		log.append("• Strength: " + str(pd.Strength))
		log.append("• Magic: " + str(pd.Magic))
		log.append("• Agility: " + str(pd.Agility))
		log.append("• Defense: " + str(pd.Defense))
		log.append("• DMG Base: " + str(pd.base_damage))
		log.append("• Position: " + str(player.global_position.round()))
		log.append("• Weapon Equipped: " + str(player.weapon_equipped))
		log.append("• Inventory Full: " + str(player.inventory_full))

		var items := []
		for slot in player.inventory.slots:
			if slot.item:
				items.append(slot.item.name)
		log.append("• Inventory Items: " + str(items))
	else:
		log.append("[PLAYER INFO] ⚠️ Player node not found.")

	log.append("\n[SCENE NODES]")
	log.append("• Root: " + get_tree().root.name)
	for node in get_tree().get_nodes_in_group("Debug") + get_tree().get_nodes_in_group("Hotbar"):
		log.append("    - " + node.name + " [" + str(node.get_path()) + "]")

	write_to_file(log.join("\n"))
	print("📄 Logger wrote to:", ProjectSettings.globalize_path(log_path))

func write_to_file(content: String):
	var file := FileAccess.open(log_path, FileAccess.WRITE)
	if file:
		file.store_string(content)
		file.close()
