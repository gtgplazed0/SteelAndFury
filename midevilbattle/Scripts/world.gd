extends Node2D

@onready var player := $Actors/Player
@onready var camera := $Camera
@onready var ui = $UI
var is_camera_locked : bool = false
var player_start_x = 35
var player_y = {
	0: 183,
	1: 583
}
var cam_y = {
	0: 128,
	1: 528
}
func _ready() -> void:
	StageManager.checkpoint_start.connect(on_checkpoint_start.bind())
	StageManager.checkpoint_complete.connect(on_checkpoint_complete.bind())
	StageManager.finalcheckpoint_complete.connect(on_final_checkpoint.bind())
	StageManager.game_restart.connect(on_restart.bind())
func _process(_delta: float) -> void:
	if player.position.x > camera.position.x and is_camera_locked == false:
		camera.position.x = player.position.x
	if ui.game_over == true:
		is_camera_locked = true
func on_checkpoint_start():
	print("starting")
	is_camera_locked = true
func on_checkpoint_complete():
	print("finished")
	is_camera_locked = false

func on_final_checkpoint():
	var map = ui.current_level
	if map == 1:
		ui.change_level()
		is_camera_locked = true
		player.position.x = player_start_x
		camera.position.x = 200
		player.position.y = player_y[map]
		camera.position.y = cam_y[map]
	else:
		is_camera_locked = true
		ui.game_over = true
	
func on_restart():
	ui.current_level = 0
	var map = ui.current_level
	ui.starting()
	is_camera_locked = true
	player.position.x = player_start_x
	camera.position.x = 200
	player.position.y = player_y[map]
	camera.position.y = cam_y[map]
