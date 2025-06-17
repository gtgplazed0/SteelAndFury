class_name Score
extends Label
# this is to manage the score in the top
@export var time_to_update: float
var score_to_hit :=  0
var real_score := 0
var prior_score := 0
var displayed_score := 0
var time_start_update := Time.get_ticks_msec()
func _ready() -> void:
	ComboManager.reset.connect(on_reset.bind())
	displayed_score = 0
	refresh()
func _process(delta: float) -> void:
	if real_score != displayed_score:
		var progress: = (Time.get_ticks_msec() - time_start_update) / time_to_update
		print(progress)
		if progress < 1:
			displayed_score = lerp(prior_score, real_score, progress)
		else:
			displayed_score = real_score
		refresh()
		
func add_combo(points: int):
	real_score += int((points * (points +1)) / 2)
	prior_score = displayed_score
	time_start_update = Time.get_ticks_msec()
	refresh()

func refresh():
	text = "Score:" + str(int(displayed_score))
func on_reset():
	real_score = 0
	displayed_score = 0
	refresh()
