extends StaticBody2D

@export var dialogue_id := "Blacksmith Smithing"

var player_in_area: bool = false

func _ready() -> void:
	# Optional: Register the player detection signals if not connected via the editor
	$PlayerDetection.body_entered.connect(_on_player_detection_body_entered)
	$PlayerDetection.body_exited.connect(_on_player_detection_body_exited)

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("talk") and player_in_area:
		if not DialogueManager.is_dialogue_active():
			DialogueManager.start_dialogue(self, dialogue_id)

func _on_player_detection_body_entered(body: Node) -> void:
	if body is Player:
		player_in_area = true

func _on_player_detection_body_exited(body: Node) -> void:
	if body is Player:
		player_in_area = false

# Optional method called by DialogueManager when "openShop" signal is emitted
func open_shop() -> void:
	print("🛠 Blacksmith opens the shop.")
	# Replace with actual shop UI call
	# ShopManager.show_blacksmith_shop()
