extends CharacterBody2D

class_name Player

#General (Script)
@onready var state_machine : PlayerStateMachine = $StateMachine
@onready var animation_player : AnimationPlayer = $AnimationPlayer
@onready var animation_tree : AnimationTree = $AnimationTree
@onready var animation_state = animation_tree.get("parameters/playback")
@onready var player_sprite: AnimatedSprite2D = $PlayerSprite

#General (Game)
@onready var level_up_vfx : AnimatedSprite2D = $Misc/LevelUp
@onready var check_time = null
@onready var light_source : PointLight2D = $Misc/Light_Source

#Combat
@onready var sword_sprite : Sprite2D = $Combat/Sword/SwordSprite
@onready var sword_hitbox : Node2D = $Combat/HitboxPivot/SwordHitbox
@onready var attack_timer : Timer = $Combat/AttackTimer
@onready var health_bar : ProgressBar = $User_Interface/Healthbar

@onready var cheat_menu_scene = preload("res://UI/Menus/Cheat Menu/Cheat_Menu.tscn")

@export var blood_splatter_scene: PackedScene  # Assign in inspector
@export var blood_puddle_scene: PackedScene

#Cheat System
var cheat_menu_instance: Node = null

#Save System
const save_file_path = "user://save/"
const save_file_name = "Player.tres"
var player_data = PlayerData.new()
var inventory = preload("res://Player/Inventory/PlayerInventory.tres")
var inventory_full: bool

var gold_text_scene: PackedScene = preload("res://Player/Inventory/Items/gold/FloatingGoldText.tscn")

#Directional
var input_vector : Vector2 = Vector2.ZERO
var aim_direction : Vector2 

#Changing Weapon Sprites
var weapon_equipped : bool = false
@onready var hand_sprite: Sprite2D = $Combat/Sword/SwordSprite

func _ready():
	verifySaveDirectory(save_file_path)
	randomize()
	state_machine.Initialize(self)
	inventory.use_item.connect(use_item)
	inventory.inventory_full.connect(inventoryCheck)
	check_time = DayAndNight.get_child(1)
	check_time.connect("time_tick", Callable(self, "_on_check_time"))
	animation_tree.active = true
	GameManager.player_died.connect(_on_player_died)
	
func _process(_delta):
	if Input.is_action_just_pressed("Save"):
		savePlayerData()
		saveDataToFile()
	if Input.is_action_just_pressed("Load"):
		loadSaveData()
		
	checkSelectedWeapon()	
	updateHealthBarUI()

func _physics_process(_delta):
	setMovementDirection()
	
func _input(event):
	if event.is_action_pressed("toggle_debug"):
		if cheat_menu_instance == null:
			cheat_menu_instance = cheat_menu_scene.instantiate()
			add_child(cheat_menu_instance)
		else:
			cheat_menu_instance.queue_free()
			cheat_menu_instance = null
			
	if event.is_action_pressed("take_damage"):
		var directions := [Vector2.LEFT, Vector2.RIGHT]
		var from_direction = directions[randi() % directions.size()]
		take_damage(from_direction)

		
func take_damage(from_direction: Vector2):
	spawn_blood_splatter(from_direction)
	spawn_blood_puddles(from_direction)
	
	
func spawn_blood_puddles(from_direction: Vector2):
	await get_tree().create_timer(randf_range(.25, .5)).timeout  # 💥 slight randomized delay
	if blood_puddle_scene == null:
		push_warning("Blood puddle scene not assigned!")
		return

	var num_puddles := 10 + randi() % 2  # spawn 2–3 puddles
	var direction := -from_direction.normalized()

	for i in num_puddles:
		var puddle = blood_puddle_scene.instantiate()
		get_parent().add_child(puddle)

		# Offset each puddle slightly in the direction blood is flying
		var distance = randf_range(12, 25)
		var scatter_offset = Vector2(randf_range(-2, 2), randf_range(-2, 2))  # for natural spread

		var ground_offset = Vector2(0, 15)  # pushes downward in top-down view
		puddle.global_position = global_position + direction * distance + scatter_offset + ground_offset

	
func spawn_blood_splatter(from_direction: Vector2):
	if blood_splatter_scene == null:
		push_warning("Blood splatter scene not assigned!")
		return

	var blood_instance = blood_splatter_scene.instantiate()
	add_child(blood_instance)

	# Position slightly at foot level
	blood_instance.global_position = global_position + Vector2(0, 4)

	# Flip horizontally depending on hit direction
	if from_direction.dot(Vector2.RIGHT) > 0:
		blood_instance.scale.x = -1  # Hit from left, blood flies right
	else:
		blood_instance.scale.x = 1   # Hit from right, blood flies left

func restart_level():
	var scene_path = get_tree().current_scene.scene_file_path
	get_tree().change_scene_to_file(scene_path)

	
func UpdateAnimation(state: String):
	animation_state.travel(state)
	
func setMovementDirection():
	input_vector.x = Input.get_action_strength("Move_Right") - Input.get_action_strength("Move_Left")
	input_vector.y = Input.get_action_strength("Move_Down") - Input.get_action_strength("Move_Up")
	input_vector = input_vector.normalized()
	aim_direction = (get_global_mouse_position() - global_position).normalized() # Make player face the mouse
	move_and_slide()
	
func savePlayerData():
	#Save Scene and Location
	#player_data.loadSavedPosition(self.position)	
	player_data.updateInventory(inventory.slots)
	player_data.updateBaseDMG(sword_hitbox.damage)
	player_data.updateTime(DayAndNight.canvas_modulate.time)
	
func saveDataToFile():
	var save_path = save_file_path + save_file_name
	verifySaveDirectory(save_path)
	print("Saving to: ", save_path)
	ResourceSaver.save(player_data, save_path)

func loadSaveData():
	if FileAccess.file_exists(save_file_path + save_file_name):
		player_data = ResourceLoader.load(save_file_path + save_file_name).duplicate(true)
		gameStarted()
		print("Save Loaded")
	else:
		print("File not found. Press O to save!")

signal updateInventoryUI
func gameStarted():
	#Load the data we saved in.
	inventory.slots = player_data.slots
	inventory.check_inventory_full()
	emit_signal("updateInventoryUI")
	sword_hitbox.damage = player_data.base_damage
	DayAndNight.canvas_modulate.time = player_data.time
	#Reload the last scene and position
	#self.position = player_data.savedPosition
	
func verifySaveDirectory(path: String):
	DirAccess.make_dir_absolute(path)
	
func _on_check_time(_day, hour, _minute):
	#24 hour Clock
	if (hour >= 19 and hour <= 23) or (hour >= 0 and hour < 5):
		if scene_manager.current_scene != "Dungeon_1":
			light_source.visible = true
	else:
		light_source.visible = false
	
func calculateDmg(dmgBoostStat):
	sword_hitbox.damage = (player_data.Strength * 0.5) + dmgBoostStat
		
func _on_level_up():
	level_up_vfx.play("level_up")
	AudioManager.get_node("Level_Up").play()	
	
func updateHealthBarUI():
	health_bar.health = player_data.HP
	#health_bar.max_value = player_data.max_HP
	#if health_bar.health == player_data.max_HP:
		#health_bar.visible = false
			
func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.has_method("collect") and !inventory_full:
		area.collect(inventory, player_data, self)  # ✅ include `self` as player
	print("Entered area:", area.name, " Has collect:", area.has_method("collect"))
		
func increase_health(amount: int) -> void:
	player_data.HP += amount
	
func use_item(item: InventoryItem) -> void:
	item.use(self)
	
func inventoryCheck(full):
	if full:
		inventory_full = true
	else:
		inventory_full = false

func _on_hp_recovery_timeout():
	if player_data.HP < player_data.max_HP:
		$Combat/HpRecovery.start()
		player_data.HP += 1
		
var base_strength = 10  # Base strength without any weapons
var equipped_weapon = null  # Reference to the currently equipped weapon

# Assuming player_data and equipped_weapon are already defined elsewhere in your player class
func checkSelectedWeapon():
	var hotbar_instance = get_tree().get_first_node_in_group("Hotbar")
	var selected_index = hotbar_instance.currently_selected

	# Reset defaults
	hand_sprite.texture = null
	weapon_equipped = false
	
	# Validate index and ensure there is an item
	if selected_index < hotbar_instance.inventory.slots.size():
		var selected_slot = hotbar_instance.inventory.slots[selected_index]
		
		if selected_slot.item:
			hand_sprite.texture = selected_slot.item.texture
			weapon_equipped = selected_slot.item.isWeapon
			
			if weapon_equipped:
				# Equip new weapon if different from the currently equipped weapon
				if equipped_weapon != selected_slot.item:
					if equipped_weapon:
						# Remove bonus of the old weapon
						player_data.Strength -= equipped_weapon.attackBonus
					equipped_weapon = selected_slot.item
					# Add bonus of the new weapon
					player_data.Strength += equipped_weapon.attackBonus
			else:
				if equipped_weapon:
					# Remove bonus if previously equipped item was a weapon and now selecting a non-weapon
					player_data.Strength -= equipped_weapon.attackBonus
					equipped_weapon = null
		else:
			# No item is selected, so remove bonus if any weapon was equipped
			if equipped_weapon:
				player_data.Strength -= equipped_weapon.attackBonus
				equipped_weapon = null
				
func _on_player_died():
	print("💀 Player has died")

	# Prevent physics and input processing
	set_physics_process(false)
	set_process(false)

	# Disable animation tree to stop blend states
	animation_tree.active = false

	# Disable state machine tick if needed
	if state_machine.has_method("set_process"):
		state_machine.set_process(false)
	if state_machine.has_method("set_physics_process"):
		state_machine.set_physics_process(false)

	# Optionally: block inventory, UI, or dash states if needed here

	# Play death animation if available
	if animation_player.has_animation("death"):
		animation_player.play("death")

	# Wait 60 seconds for death animation / stylized delay
	await get_tree().create_timer(60.0).timeout

	# Then show Game Over UI
	print("🪦 Showing Game Over screen")
	get_tree().change_scene_to_file("res://UI/GameOverUI.tscn")

	
func _on_save_timeout():
	savePlayerData()
	saveDataToFile()
