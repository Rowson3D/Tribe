extends Control

@onready var inventory_button: TextureButton = $InventoryButton
@onready var stats_button: TextureButton = $StatsButton
@onready var tree_button: TextureButton = $TreeButton

var tab_buttons: Array[TextureButton]

func _ready():
	tab_buttons = [inventory_button, stats_button, tree_button]
	for button in tab_buttons:
		button.connect("pressed", _on_tab_pressed.bind(button))

	# Select the default tab
	select_tab(inventory_button)


func _on_tab_pressed(clicked_button: TextureButton) -> void:
	select_tab(clicked_button)


func select_tab(selected_button: TextureButton) -> void:
	for button in tab_buttons:
		if button == selected_button:
			button.frame = 1  # SELECTED (pressed)
			# TODO: Show selected tab content here
		else:
			button.frame = 0  # UNSELECTED
