extends Area2D
class_name ItemPickup  # optional but useful

@export var itemRes: InventoryItem

func collect(inventory: Inventory, player_data: PlayerData, player: Node2D) -> void:
	inventory.insert(itemRes)
	queue_free()
