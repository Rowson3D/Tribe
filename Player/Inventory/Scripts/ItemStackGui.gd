extends Panel

class_name ItemStackGui

@onready var item_sprite: Sprite2D = $item
@onready var amount_label = $Label

var inventory_slot: InventorySlot

func update():
	if !inventory_slot || !inventory_slot.item: return
	
	item_sprite.visible = true
	item_sprite.texture = inventory_slot.item.texture
	
	if inventory_slot.amount > 1:
		amount_label.visible = true
		amount_label.text = str(inventory_slot.amount)
	else:
		amount_label.visible = false
		
func get_drag_data(_position):
	var preview = duplicate()
	preview.modulate = Color(1, 1, 1, 0.5)  # semi-transparent preview
	set_drag_preview(preview)
	
	return self  # Send this ItemStackGui as the drag data

func can_drop_data(_position, data) -> bool:
	# You probably won't be dropping onto the item stack itself,
	# but we return false just in case.
	return false

func drop_data(_position, data):
	# Ignore drops onto other item stacks unless you're handling merging
	pass
