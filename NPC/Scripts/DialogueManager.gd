extends Node

var current_npc: Node = null
var dialogue_active: bool = false
var input_blocked: bool = false

func _ready():
	print("[DialogueManager] Ready. Connecting Dialogic signals...")
	Dialogic.signal_event.connect(_on_dialogue_signal)
	Dialogic.timeline_ended.connect(_on_dialogue_end)
	print("[DialogueManager] Signal connections complete.")

func start_dialogue(npc: Node, dialogue_id: String) -> void:
	print("[DialogueManager] Requested to start dialogue:", dialogue_id)
	print("[DialogueManager] From NPC:", npc.name)
	current_npc = npc
	dialogue_active = true

	var actual_id = _resolve_contextual_dialogue(npc, dialogue_id)
	print("[DialogueManager] Resolved dialogue ID:", actual_id)

	Dialogic.start(actual_id)
	print("[DialogueManager] Dialogic.start() called with:", actual_id)

func _resolve_contextual_dialogue(npc: Node, base_id: String) -> String:
	print("[DialogueManager] Resolving contextual dialogue for NPC:", npc.name)
	# Example logic you can expand later:
	# if time == night: return base_id + "_Night"
	# if QuestManager.has_flag("intro_done"): return base_id + "_PostIntro"
	return base_id

func _on_dialogue_signal(arg: String) -> void:
	print("[DialogueManager] Received signal from Dialogic:", arg)
	match arg:
		"openShop":
			print("[DialogueManager] 'openShop' signal received from", current_npc.name)
			if current_npc and current_npc.has_method("open_shop"):
				print("[DialogueManager] Calling current_npc.open_shop()")
				current_npc.open_shop()
			else:
				push_warning("[DialogueManager] NPC has no 'open_shop' method!")
		_:
			print("[DialogueManager] Unhandled signal:", arg)

func _on_dialogue_end(timeline_name: String) -> void:
	print("[DialogueManager] Dialogue ended:", timeline_name)
	print("[DialogueManager] Resetting dialogue state and NPC.")
	dialogue_active = false
	current_npc = null

func is_dialogue_active() -> bool:
	print("[DialogueManager] Checking dialogue_active:", dialogue_active)
	return dialogue_active
