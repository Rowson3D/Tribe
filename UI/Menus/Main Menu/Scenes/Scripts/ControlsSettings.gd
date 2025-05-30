extends Control

@onready var keybind_list := $Background/ControlsTab/VBoxContainer
@onready var keybind_template := keybind_list.get_node("KeybindTemplate")

var actions := [
	"move_up", "move_down", "move_left", "move_right",
	"attack", "interact", "pause"
]

var waiting_for_action: String = ""
var label_map := {}  # action_name → Label node

func _ready():
	# Hide the template from display
	keybind_template.visible = false

	for action in actions:
		var row = keybind_template.duplicate()
		row.visible = true
		keybind_list.add_child(row)

		var action_label := row.get_child(0)
		var key_label := row.get_child(1)
		var rebind_button := row.get_child(2)

		action_label.text = action.capitalize()
		key_label.text = _get_action_key_text(action)
		rebind_button.text = "Rebind"

		rebind_button.pressed.connect(func():
			waiting_for_action = action
			key_label.text = "Press a key..."
		)

		label_map[action] = key_label

func _get_action_key_text(action: String) -> String:
	var events := InputMap.action_get_events(action)
	for e in events:
		if e is InputEventKey:
			return OS.get_keycode_string(e.keycode)
	return "None"

func _unhandled_input(event):
	if waiting_for_action and event is InputEventKey and event.pressed:
		var action := waiting_for_action
		InputMap.action_erase_events(action)
		InputMap.action_add_event(action, event)
		label_map[action].text = OS.get_keycode_string(event.keycode)
		waiting_for_action = null
