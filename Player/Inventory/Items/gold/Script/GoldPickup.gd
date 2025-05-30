extends Area2D
class_name GoldPickup

@export var pickup_data: GoldPickupData

func collect(inventory: Inventory, player_data: PlayerData, player: Node2D) -> void:
	print("GoldPickup: collect() called.")

	if pickup_data == null:
		print("❌ GoldPickup: pickup_data is null!")
		return

	if pickup_data is GoldPickupData:
		print("🪙 GoldPickup: Applying gold amount:", pickup_data.amount)

		# Apply gold
		pickup_data.apply_to_player(player_data, inventory)

		# Play pickup sound
		AudioManager.get_node("Pickup_Gold").play()

		# ✅ Use GoldNumbersOrigin for spawn point
		if player.has_node("GoldNumbersOrigin"):
			var origin = player.get_node("GoldNumbersOrigin")
			GoldPickupNumbers.display(pickup_data.amount, origin.global_position)
		else:
			push_warning("⚠️ Player is missing GoldNumbersOrigin, falling back to global_position.")
			GoldPickupNumbers.display(pickup_data.amount, player.global_position + Vector2(0, -16))
	else:
		push_warning("GoldPickup: pickup_data is not a GoldPickupData resource. Type = " + str(typeof(pickup_data)))

	queue_free()
