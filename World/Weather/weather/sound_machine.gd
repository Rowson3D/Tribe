extends Node

@export var night_hour := 18        # Time when night starts (inclusive)
@export var day_hour := 5           # Time when day starts (inclusive)

@onready var day_jingle: AudioStreamPlayer = $DayJingle             # Transition to Day
@onready var night_jingle: AudioStreamPlayer = $NightJingle         # Transition to Night
@onready var day_soundscape: AudioStreamPlayer = $DaySoundscape     # Ambient loop during day
@onready var night_soundscape: AudioStreamPlayer = $NightSoundscape # Ambient loop during night

var last_period: String = ""  # "day" or "night"

func set_daytime(_day: int, hour: int, minute: int) -> void:
	var current_period := get_period(hour)

	# 🔄 Transition if period changed
	if current_period != last_period:
		last_period = current_period
		match current_period:
			"day":
				play_day_transition()
			"night":
				play_night_transition()

	# 🔁 Ensure appropriate soundscape is playing
	if current_period == "day":
		if not day_soundscape.playing:
			day_soundscape.play()
		if night_soundscape.playing:
			night_soundscape.stop()
	else:
		if not night_soundscape.playing:
			night_soundscape.play()
		if day_soundscape.playing:
			day_soundscape.stop()

func get_period(hour: int) -> String:
	return "night" if hour < day_hour or hour >= night_hour else "day"

func play_day_transition():
	# Play day jingle
	if not day_jingle.playing:
		day_jingle.play()
	night_soundscape.stop()
	day_soundscape.play()

func play_night_transition():
	# Play night jingle
	if not night_jingle.playing:
		night_jingle.play()
	day_soundscape.stop()
	night_soundscape.play()
