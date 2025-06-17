class_name ComboIndicator
extends Label
#handles the combo in the bottom left
# time to stop combo
@export var duration_combo_timeout: int 
#reset the combo
signal combo_reset(points: int)
var current_combo_nb
var time_since_register_hit = Time.get_ticks_msec()

func _init() -> void: # before ready, this loads signals
	ComboManager.register_hit.connect(on_register_hit.bind())
	ComboManager.player_hit.connect(on_player_hit.bind())
func _ready() -> void:
	current_combo_nb = 0
	refresh() #refresh combo on screen
#change combo when an enemy is hit
func on_register_hit():
	current_combo_nb += 1
	time_since_register_hit = Time.get_ticks_msec()
	refresh()
	
func _process(delta: float) -> void:
	if current_combo_nb > 0 and (Time.get_ticks_msec() - time_since_register_hit) > duration_combo_timeout:
		combo_reset.emit(current_combo_nb)
		current_combo_nb = 0
		refresh()
#refresh the numbers of the screen
func refresh():
	if current_combo_nb > 0:
		modulate.a = 1
		text = "x" + str(current_combo_nb)
	else:
		text = ""
#stop combo when hit
func on_player_hit():
	combo_reset.emit(current_combo_nb)
	current_combo_nb = 0
	refresh()
