extends CanvasLayer

@onready var level_spinbox      = $Control/ColorRect/HBoxContainer/VBoxContainerLeft/Level/level_spinbox
@onready var xp_spinbox         = $Control/ColorRect/HBoxContainer/VBoxContainerLeft/XP/xp_spinbox
@onready var hp_spinbox         = $Control/ColorRect/HBoxContainer/VBoxContainerLeft/HP/hp_spinbox
@onready var max_hp_spinbox     = $Control/ColorRect/HBoxContainer/VBoxContainerLeft/MaxHP/max_hp_spinbox

@onready var strength_spinbox   = $Control/ColorRect/HBoxContainer/VBoxContainerRight/Strength/strength_spinbox
@onready var magic_spinbox      = $Control/ColorRect/HBoxContainer/VBoxContainerRight/Magic/magic_spinbox
@onready var agility_spinbox    = $Control/ColorRect/HBoxContainer/VBoxContainerRight/Agility/agility_spinbox
@onready var defense_spinbox    = $Control/ColorRect/HBoxContainer/VBoxContainerRight/Defense/defense_spinbox

@onready var apply_button       = $Control/ColorRect/HBoxContainer3/VBoxContainer2/ApplyButton
@onready var cancel_button      = $Control/ColorRect/HBoxContainer3/VBoxContainer/CloseButton

@onready var player_node: Node = null

func _ready():
	set_process_mode(PROCESS_MODE_ALWAYS)

	# Freeze game but allow UI
	get_tree().paused = true
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	# Find the player node (or use autoloaded GameManager if needed)
	player_node = get_tree().get_root().find_child("Player", true, false)
	if not player_node:
		print("[CheatMenu] Could not find Player node!")
		queue_free()
		return

	populate_fields()
	apply_button.pressed.connect(_on_apply_button_pressed)
	cancel_button.pressed.connect(_on_cancel_button_pressed)

func populate_fields():
	var data = player_node.player_data
	level_spinbox.value    = data.Level
	xp_spinbox.value       = data.current_xp
	hp_spinbox.value       = data.HP
	max_hp_spinbox.value   = data.max_HP

	strength_spinbox.value = data.Strength
	magic_spinbox.value    = data.Magic
	agility_spinbox.value  = data.Agility
	defense_spinbox.value  = data.Defense

func _on_apply_button_pressed():
	var data = player_node.player_data
	
	data.Level     = int(level_spinbox.value)
	data.current_xp = int(xp_spinbox.value)
	data.set_hp(int(hp_spinbox.value))
	data.set_max_hp(int(max_hp_spinbox.value))

	data.Strength  = int(strength_spinbox.value)
	data.Magic     = int(magic_spinbox.value)
	data.Agility   = int(agility_spinbox.value)
	data.Defense   = int(defense_spinbox.value)

	data.check_level_up()
	print("[CheatMenu] Stats updated.")
	get_tree().paused = false
	queue_free()

func _on_cancel_button_pressed():
	print("[CheatMenu] Cancelled.")
	get_tree().paused = false
	queue_free()
