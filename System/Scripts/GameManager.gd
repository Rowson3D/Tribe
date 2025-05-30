extends Node

signal player_died

func trigger_player_death():
	emit_signal("player_died")
