extends Button

class_name Slot_Gui

@onready var backgroundSprite: Sprite2D = $background
@onready var container: CenterContainer = $CenterContainer

@onready var inventory = preload("res://Player/Inventory/PlayerInventory.tres")

var itemStackGui: ItemStackGui
var index: int

func insert(isg: ItemStackGui):
	# Identify if this is the trash slot
	var is_trash := name.to_lower().contains("trash")  # e.g. node name is "TrashSlot" or "trash_bin"

	if is_trash:
		if !isg or !isg.inventory_slot:
			push_warning("❌ Tried to trash an invalid or empty item!")
			return

		#if isg.inventory_slot.item:
			#print("🗑️ Trashing item: %s" % isg.inventory_slot.item.item_name)
		#else:
			#print("🗑️ Trashing unknown item (item was null)")

		inventory.removeSlot(isg.inventory_slot)
		isg.queue_free()
		itemStackGui = null
		backgroundSprite.frame = 0
		print("✅ Item destroyed.\n")
		return

	# 🔁 Transfer logic for normal slots
	if isg.get_parent() is Slot_Gui:
		var previous_slot := isg.get_parent() as Slot_Gui
		previous_slot.clear()
		inventory.removeSlot(isg.inventory_slot)

	itemStackGui = isg
	backgroundSprite.frame = 1
	container.add_child(itemStackGui)

	if index >= inventory.slots.size():
		push_warning("Slot index %d out of bounds. Inventory only has %d slots." % [index, inventory.slots.size()])
		return

	if !itemStackGui.inventory_slot or inventory.slots[index] == itemStackGui.inventory_slot:
		return

	inventory.insertSlot(index, itemStackGui.inventory_slot)
	print("📦 Moved item to slot %d" % index)


	
func takeItem():
	var item = itemStackGui
	
	inventory.removeSlot(itemStackGui.inventory_slot)
	
	return item
	
func isEmpty():
	return !itemStackGui
	
func clear() -> void:
	if itemStackGui:
		container.remove_child(itemStackGui)
		itemStackGui = null
		
	backgroundSprite.frame = 0
