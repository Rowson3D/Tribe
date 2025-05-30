extends StaticBody2D

@export var dialogue_id := "roy_talk_1"

var player_in_area: bool = false

func _ready() -> void:
	print("[Roy] Ready. Dialogue ID:", dialogue_id)
	$PlayerDetection.body_entered.connect(_on_player_detection_body_entered)
	$PlayerDetection.body_exited.connect(_on_player_detection_body_exited)

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("talk"):
		print("[Roy] Talk input detected.")
		if player_in_area:
			print("[Roy] Player is in area.")
			if not DialogueManager.is_dialogue_active():
				print("[Roy] No dialogue in progress. Starting dialogue.")
				DialogueManager.start_dialogue(self, dialogue_id)
			else:
				print("[Roy] Dialogue already in progress.")
		else:
			print("[Roy] Player is not nearby.")

func _on_player_detection_body_entered(body: Node) -> void:
	if body is Player:
		print("[Roy] Player entered interaction area.")
		player_in_area = true

func _on_player_detection_body_exited(body: Node) -> void:
	if body is Player:
		print("[Roy] Player exited interaction area.")
		player_in_area = false
