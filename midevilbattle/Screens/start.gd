extends Node2D
var game_is_on = false
func _ready() -> void:
	get_tree().paused = true
	
func _process(delta: float) -> void:
	start_game()

func start_game():
	if Input.is_anything_pressed() and game_is_on == false:
		game_is_on == true
	if game_is_on == false:
		get_tree().paused = true
	else:
		print("upaused")
		get_tree().paused = false
