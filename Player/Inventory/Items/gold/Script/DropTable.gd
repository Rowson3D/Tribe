# res://Loot/DropTable.gd
extends Resource
class_name DropTable

@export var gold_min: int = 5
@export var gold_max: int = 15

func roll_gold_amount() -> int:
	return randi_range(gold_min, gold_max)
