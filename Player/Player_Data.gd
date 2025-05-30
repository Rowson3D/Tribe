@tool
extends Resource
class_name PlayerData

@export_category("Player Stats")

#General
@export var time : float

#Stats
const MAX_LEVEL = 4
@export var Level: int = 1
@export var current_xp: int = 0
@export var xp_table_data: Dictionary = {}
@export var HP: int = 0
@export var max_HP: int = 100
@export var stamina: int = 0
@export var max_stamina: int = 100
@export var Strength: int = 0
@export var Magic: int = 0
@export var Agility: int = 0
@export var Defense: int = 0

#Combat
@export var KNOCKOUT_SPEED: int = 0
@export var base_damage: int

#Rogue Dungeon
@export var dungeon_floor: int = 1
@export var temp_str: int = 0
@export var temp_def: int = 0
@export var temp_agi: int = 0

#Inventory
@export var slots: Array[InventorySlot] = []
@export var gold: int = 0

#Scene and Position
@export var savedPosition: Vector2

var rpg_class = null

func _init():
	load_xp_data()
	rpg_class = Warrior.new() 
	rpg_class.set_base_stat(self)

func updateInventory(value: Array[InventorySlot]):
	slots = value.duplicate()
	
func add_gold(amount: int):
	gold += amount

func loadSavedPosition(value: Vector2):
	savedPosition = value

func gain_experience(amount: int):
	if Level >= MAX_LEVEL:
		return
	current_xp += amount
	check_level_up()

func check_level_up():
	while current_xp >= get_required_experience(Level) and Level < MAX_LEVEL:
		current_xp -= get_required_experience(Level)
		Level += 1
		rpg_class.stat_growth(self)

func set_hp(new_hp: int):
	HP = new_hp

func set_max_hp(new_max_hp: int):
	max_HP = new_max_hp
	
func updateBaseDMG(value: int):
	base_damage = value
	
func updateTime(value: float):
	time = value

func get_required_experience(level: int) -> int:
	return xp_table_data[str(level)]["need"]

func load_xp_data():
	var file = FileAccess.open("res://Player/LevelDatabase.json", FileAccess.READ)
	var data = JSON.parse_string(file.get_as_text())
	xp_table_data = data
