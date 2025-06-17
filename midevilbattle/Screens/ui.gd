class_name UI
extends CanvasLayer
#controls the ui of the game using exported and onready variables, setting visibilites
@export var health_bar_visible: int
@onready var pause = $UIContainer/Pause
@onready var enemy_name := $UIContainer/EnemyName
@onready var player_health_bar :Control = $UIContainer/PlayerHealth
@onready var enemy_health_bar :Control = $UIContainer/EnemyHealth
@onready var enemy_colour_rect: ColorRect = $UIContainer/ColorRect
@onready var enemy_av:Control = $UIContainer/EnemyAvatar
@onready var go:= $UIContainer/Go
@onready var combo:= $UIContainer/ComboIndicator
@onready var score:= $UIContainer/ScoreIndicator
@onready var start_screen = $UIContainer/StartScreen
@onready var level1_fader = $SavageDomainLevel
@onready var level2_fader = $BoneGardenLevel
@onready var instruction = $UIContainer/Instructions
@onready var gameover = $UIContainer/GameOver
var game_over = false
var current_level = 0
var time_start_health_bar := Time.get_ticks_msec()
var game_start = false
const ENEMY_PFP := {
	Character.Type.ASHMAW: preload("res://Assets/ProfilePics/Ashmaw.png"), 
	Character.Type.VERDMAW: preload("res://Assets/ProfilePics/Verdmaw.png"), 
	Character.Type.BLANCHMAW: preload("res://Assets/ProfilePics/Blanchmaw.png"),
	Character.Type.SKIVER: preload("res://Assets/ProfilePics/Skivermouth.png"), 
	Character.Type.GOREHIDE: preload("res://Assets/ProfilePics/Gorehide.png"),
	Character.Type.KINGSKIVER: preload("res://Assets/ProfilePics/Skivermouth.png"), 
}
const ENEMY_NAMES := {
	Character.Type.ASHMAW: "ASHMAW", 
	Character.Type.VERDMAW: "VERDMAW", 
	Character.Type.BLANCHMAW: "BLANCHMAW",
	Character.Type.SKIVER: "SKIVERMOUTH", 
	Character.Type.GOREHIDE: "GOREHIDE THE SAVAGE",
	Character.Type.KINGSKIVER: "NOBEL KING SKIVER", 
}
func _init() -> void:
	DamageManager.health_change.connect(on_character_health_change.bind())
	StageManager.checkpoint_complete.connect(on_checkpoint_complete.bind())
func _ready():
	enemy_health_bar.visible = false
	enemy_av.visible = false
	enemy_colour_rect.visible = false
	enemy_name.visible = false
	combo.combo_reset.connect(on_combo_reset.bind())
	starting()
func _process(delta: float) -> void:
	handle_game_over()
	if enemy_health_bar.visible == true and (Time.get_ticks_msec() - time_start_health_bar) > health_bar_visible:
		enemy_health_bar.visible = false 
		enemy_name.visible = false
		enemy_colour_rect.visible = false
		enemy_av.visible = false
	if start_screen.visible == true:
		pause.visible = false
		instruction.visible = false
		level1_fader.visible = false
		level2_fader.visible = false
		gameover.visible = false
	if Input.is_action_just_pressed("pause") and game_start:
		ui_pause()
func on_character_health_change(type: Character.Type, current_health: int, max_health: int):
	if type == Character.Type.PLAYER:
		player_health_bar.refresh(current_health, max_health, type)
	else:
		time_start_health_bar = Time.get_ticks_msec()
		enemy_health_bar.visible = true
		enemy_name.text = ENEMY_NAMES[type]
		enemy_name.visible = true
		enemy_av.visible = true
		enemy_colour_rect.visible = true
		enemy_health_bar.refresh(current_health, max_health, type)
		enemy_av.texture = ENEMY_PFP[type]
		if current_health <= 0:
			enemy_name.visible = false
			enemy_health_bar.visible = false
			enemy_av.visible = false
			enemy_colour_rect.visible = false
func on_combo_reset(points):
	score.add_combo(points)

func on_checkpoint_complete() -> void:
	go.start_flickering()

func ui_pause():
	print("pause")
	pause.visible = !pause.visible
	if pause.visible == true:
		get_tree().paused = true
	else:
		get_tree().paused = false
		
func starting():
	start_screen.visible = true
	get_tree().paused = true

func change_level():
	current_level += 1
	match current_level:
		1:
			level1_fader.visible = true
		2:
			level2_fader.visible = true

func _on_start_button_down() -> void:
	game_start = true
	change_level()
	get_tree().paused = false
	start_screen.visible = false
	pass # Replace with function body.


func _on_instructions_button_down() -> void:
	start_screen.visible = false
	instruction.visible = true
	
func _on_return_button_button_down() -> void:
	start_screen.visible = true
	instruction.visible = false

func handle_game_over():
	if game_over:
		gameover.visible = true
	if Input.is_action_just_pressed("restart"):
		game_over = false
		gameover.visible = false
		StageManager.game_restart.emit()
