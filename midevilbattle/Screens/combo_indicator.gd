class_name ComboIndicator
extends Label

@export var duration_combo_timeout: int 

signal combo_reset(points: int)
var current_combo_nb
var time_since_register_hit = Time.get_ticks_msec()

func _init() -> void:
	ComboManager.register_hit.connect(on_register_hit.bind())
	ComboManager.player_hit.connect(on_player_hit.bind())
func _ready() -> void:
	current_combo_nb = 0
	refresh()
	
func on_register_hit():
	current_combo_nb += 1
	time_since_register_hit = Time.get_ticks_msec()
	refresh()
	
func _process(delta: float) -> void:
	if current_combo_nb > 0 and (Time.get_ticks_msec() - time_since_register_hit) > duration_combo_timeout:
		combo_reset.emit(current_combo_nb)
		current_combo_nb = 0
		refresh()

func refresh():
	if current_combo_nb > 0:
		modulate.a = 1
		text = "x" + str(current_combo_nb)
	else:
		text = ""
		
func on_player_hit():
	combo_reset.emit(current_combo_nb)
	current_combo_nb = 0
	refresh()
