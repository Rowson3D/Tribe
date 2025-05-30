extends Control

class_name Inventory_Gui

var isOpen: bool = false

signal opened
signal closed

@onready var inventory: Inventory = preload("res://Player/Inventory/PlayerInventory.tres")
@onready var ItemStackGuiClass = preload("res://Player/Inventory/Scene/itemStackGui.tscn")
@onready var hotbar_slots: Array = $NinePatchRect/HBoxContainer.get_children()
@onready var extraSlots: Array = [$Hat_Slot, $Body_Slot, $Accessory_Slot, $Trash]
@onready var slots: Array = hotbar_slots + $NinePatchRect/GridContainer.get_children() + extraSlots
@onready var player = null

var itemInHand: ItemStackGui
var oldIndex: int = -1
var locked: bool = false
var trashCanIndex = 46

func _ready():
	player = find_parent("Player")
	if player:
		print("✅ Found player:", player.name)
	else:
		print("❌ Could not find Player node!")
	connectSlots()
	inventory.updated.connect(update)
	player.connect("updateInventoryUI", Callable(self, "update"))
	update()
	
func _process(_delta):
	update()
	
func connectSlots():
	for i in range(slots.size()):
		var slot = slots[i]
		slot.index = i
		
		var callable = Callable(onSlotClicked)
		callable = callable.bind(slot)
		slot.pressed.connect(callable)

signal inventory_full		
func update():
	for i in range(min(inventory.slots.size(), slots.size())):
		var inventorySlot: InventorySlot = inventory.slots[i]
		
		if !inventorySlot.item:
			slots[i].clear()
			continue
			
		if i == trashCanIndex:
			print("Trash detected")
			inventory.remove_trash()
			continue
			
		if i == 43 and inventorySlot.item != null:
			$Hat_Slot/background/Hat_Slot_BG.visible = false
			
		if i == 44 and inventorySlot.item != null:
			$Body_Slot/background/Body_Slot_BG.visible = false
			
		if i == 45 and inventorySlot.item != null:
			$Accessory_Slot/background/Accessory_Slot_BG.visible = false
			
		var itemStackGui: ItemStackGui = slots[i].itemStackGui
		if !itemStackGui:
			itemStackGui = ItemStackGuiClass.instantiate()
			slots[i].insert(itemStackGui)
			
		itemStackGui.inventory_slot = inventorySlot
		itemStackGui.update()
		
func open():
	visible = true
	isOpen = true
	opened.emit()

func close():
	visible = false
	isOpen = false
	closed.emit()

func onSlotClicked(slot):
	if locked:
		return

	# Check if there's an item in hand and the slot clicked corresponds to a specific type
	if itemInHand:
		if slot.index == 43 and itemInHand.inventory_slot.item.isHelmet:
			handleEquipmentSlot(slot)
		elif slot.index == 44 and itemInHand.inventory_slot.item.isBody:
			handleEquipmentSlot(slot)
		elif slot.index == 45 and itemInHand.inventory_slot.item.isAccessory:
			handleEquipmentSlot(slot)
		elif slot.index < 43 or slot.index > 45:
			handleNormalSlot(slot)
	elif not itemInHand and not slot.isEmpty():
		# Handle taking an item from a slot
		takeItemFromSlot(slot)

func handleEquipmentSlot(slot):
	# Check if the slot is empty or needs swapping
	if not slot.isEmpty():
		if slot.itemStackGui.inventory_slot.item.getType() == itemInHand.inventory_slot.item.getType():
			swapItems(slot)  # Swap if same type
		else:
			print("Cannot swap: Item types do not match.")
	else:
		insertItemInSlot(slot)

func handleNormalSlot(slot):
	# Standard handling for non-equipment slots
	if slot.isEmpty():
		insertItemInSlot(slot)
	else:
		if not itemInHand:
			takeItemFromSlot(slot)
		elif slot.itemStackGui.inventory_slot.item.name == itemInHand.inventory_slot.item.name:
			stackItems(slot)
		else:
			swapItems(slot)

func insertItemInSlot(slot):
	var item = itemInHand
	remove_child(itemInHand)
	itemInHand = null
	slot.insert(item)
	oldIndex = -1
	
	# Apply stat changes based on the type of slot
	if slot.index == 43:  # Assuming 16 is the helmet slot
		$Hat_Slot/background/Hat_Slot_BG.visible = false
		print("Adding item to helmet slot")
		#player.player_data.Defense += item.inventory_slot.item.defBonus
	elif slot.index == 44:  # Body slot
		$Body_Slot/background/Body_Slot_BG.visible = false
		print("Adding item to body slot")
		#player.player_data.HP += item.inventory_slot.item.hpBonus
		#player.player_data.max_HP += item.inventory_slot.item.hpBonus
	elif slot.index == 45:  # Accessory slot
		$Accessory_Slot/background/Accessory_Slot_BG.visible = false
		print("Adding item to accessory slot")
		#player.player_data.Strength += item.inventory_slot.item.attackBonus
		
	inventory.check_inventory_full()
	AudioManager.get_node("Place_Item").play()

func takeItemFromSlot(slot):
	itemInHand = slot.takeItem()
	add_child(itemInHand)
	updateItemInHand()
	oldIndex = slot.index
	
	# Apply stat changes based on the type of slot
	if slot.index == 43:  # Assuming 16 is the helmet slot
		$Hat_Slot/background/Hat_Slot_BG.visible = true
		player.player_data.Defense -= itemInHand.inventory_slot.item.defBonus
	elif slot.index == 44:  # Body slot
		$Body_Slot/background/Body_Slot_BG.visible = true
		player.player_data.HP -= itemInHand.inventory_slot.item.hpBonus
		player.player_data.max_HP -= itemInHand.inventory_slot.item.hpBonus
	elif slot.index == 45:  # Accessory slot
		$Accessory_Slot/background/Accessory_Slot_BG.visible = true
		player.player_data.Strength -= itemInHand.inventory_slot.item.attackBonus
	inventory.check_inventory_full()
	AudioManager.get_node("Pickup_Item").play()
	
func swapItems(slot):
	var tempItem = slot.takeItem()
	
	insertItemInSlot(slot)
	
	itemInHand = tempItem
	add_child(itemInHand)
	updateItemInHand()

func stackItems(slot):
	var slotItem: ItemStackGui = slot.itemStackGui
	var maxAmount = slotItem.inventory_slot.item.max_amount_per_stack
	var totalAmount = slotItem.inventory_slot.amount + itemInHand.inventory_slot.amount
	
	if slotItem.inventory_slot.amount == maxAmount:
		swapItems(slot)
		return
		
	if totalAmount <= maxAmount:
		slotItem.inventory_slot.amount = totalAmount
		remove_child(itemInHand)
		itemInHand = null
		oldIndex = -1
	else:
		slotItem.inventory_slot.amount = maxAmount
		itemInHand.inventory_slot.amount = totalAmount - maxAmount
		
	slotItem.update()
	if itemInHand: itemInHand.update()
	
func updateItemInHand():
	if !itemInHand: return
	itemInHand.global_position = get_viewport().get_mouse_position() - itemInHand.size / 2
	
func putItemBack():
	locked = true
	if oldIndex < 0:
		var emptySlots = slots.filter(func (s): return s.isEmpty())
		if emptySlots.is_empty(): return
		
		oldIndex = emptySlots[0].index
		
	var targetSlot = slots[oldIndex]
	
	var tween = create_tween()
	var targetPosition = targetSlot.global_position + targetSlot.size / 2
	tween.tween_property(itemInHand, "global_position", targetPosition, 0.2)
	await tween.finished
	insertItemInSlot(targetSlot)
	locked = false
	
	
func _input(_event):
	if itemInHand and !locked and Input.is_action_just_pressed("rightClick"):
		putItemBack()
	
	updateItemInHand()
