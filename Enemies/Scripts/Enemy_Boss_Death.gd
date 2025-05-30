extends Enemy_Death

func Enter():
	animation_player.play("death")
	await animation_player.animation_finished
	animation_player.play("boss_slain")
	await animation_player.animation_finished
	player.player_data.gain_experience(240)
