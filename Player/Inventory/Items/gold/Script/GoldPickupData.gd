# res://Pickups/GoldPickupData.gd
extends PickupData
class_name GoldPickupData

@export var amount: int = 10

func apply_to_player(player_data: PlayerData, inventory: Inventory) -> void:
	print("GoldPickupData: apply_to_player() called with amount:", amount)
	player_data.add_gold(amount)
