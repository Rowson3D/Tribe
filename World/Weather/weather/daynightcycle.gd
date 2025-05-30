extends CanvasModulate

const MINUTES_PER_DAY = 1440
const MINUTES_PER_HOUR = 60
const INGAME_TO_REAL_MINUTE_DURATION = (2 * PI) / MINUTES_PER_DAY
const IGNORE_SCENES := ["Main_Menu", "SplashScreen", "StudioSplashScreen"]
const DUNGEON_SCENES := ["Dungeon_1", "Dungeon_2"]

signal time_tick(day:int, hour:int, minute:int)

@export var gradient_texture:GradientTexture1D
@export var INGAME_SPEED = 10
@export var INITIAL_HOUR = 17:
	set(h):
		INITIAL_HOUR = h
		time = INGAME_TO_REAL_MINUTE_DURATION * MINUTES_PER_HOUR * INITIAL_HOUR

var time:float= 0.0
var past_minute:int= -1

func _ready() -> void:
	time = INGAME_TO_REAL_MINUTE_DURATION * MINUTES_PER_HOUR * INITIAL_HOUR

func _process(delta: float) -> void:

	var scene := scene_manager.current_scene
	
	if not scene_manager.time_system_enabled:
		visible = false
		return

	# Case 1: Ignore splash/menu scenes (no time or visuals)
	if IGNORE_SCENES.has(scene_manager.current_scene):
		visible = false
		return

	# Case 2: Dungeon — update time, but hide visuals
	elif DUNGEON_SCENES.has(scene_manager.current_scene):
		visible = false
	else:
		# Case 3: Gameplay — time and color visible
		visible = true

	# Time updates for dungeons + gameplay
	time += delta * INGAME_TO_REAL_MINUTE_DURATION * INGAME_SPEED

	# Only update canvas color if visible
	if visible:
		var value = (sin(time - PI / 2.0) + 1.0) / 2.0
		self.color = gradient_texture.gradient.sample(value)

	_recalculate_time()

		
func _recalculate_time() -> void:
	var total_minutes = int(time / INGAME_TO_REAL_MINUTE_DURATION)
	@warning_ignore("integer_division") 
	var day = int(total_minutes / MINUTES_PER_DAY)

	var current_day_minutes = total_minutes % MINUTES_PER_DAY
	@warning_ignore("integer_division") 
	var hour = int(current_day_minutes / MINUTES_PER_HOUR)
	var minute = int(current_day_minutes % MINUTES_PER_HOUR)
	
	if past_minute != minute:
		past_minute = minute
		time_tick.emit(day, hour, minute)
