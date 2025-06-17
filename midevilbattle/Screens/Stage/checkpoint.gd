class_name Checkpoints
extends Node2D
@export var simultaneous_enemies: int = 3
@export var finalcheckpoint : bool
@onready var enemys := $Enemys
@onready var player_detection_area : Area2D= $PlayerDetectionArea
var active_enemy_counter = 0
var enemy_data : Array[EnemyData] = []
var enemy_new : Array[EnemyData] = []
var is_activated := false
func _process(delta: float) -> void:
	if is_activated and can_spawn_enemy():
		var enemy : EnemyData = enemy_data.pop_front()
		EntityManager.spawn_enemy.emit(enemy)
		active_enemy_counter += 1
func can_spawn_enemy():
	return enemy_data.size() > 0 and active_enemy_counter < simultaneous_enemies
func _ready(): #loaded all signals and enemies on ready
	StageManager.game_restart.connect(on_restart.bind())
	EntityManager.death_enemy.connect(on_enemy_death.bind())
	player_detection_area.body_entered.connect(_on_player_entered.bind())
	for enemy : Character in enemys.get_children():
		enemy_data.append(EnemyData.new(enemy.type, enemy.global_position))
		enemy_new.append(EnemyData.new(enemy.type, enemy.global_position))
		enemy.queue_free()
		
func _on_player_entered(player: Player): #if the player starts the checkpoint
	if not is_activated:
		StageManager.checkpoint_start.emit()
		active_enemy_counter = 0
		is_activated = true
	
#if an enemy dies, check if we can clear the checkpoint
func on_enemy_death(enemy: Character):
	active_enemy_counter -= 1
	if active_enemy_counter == 0 and enemy_data.size() == 0:
		if finalcheckpoint:
			StageManager.finalcheckpoint_complete.emit()
		else:
			StageManager.checkpoint_complete.emit()
		#queue_free()
#on game restart
func on_restart():
	enemy_data = enemy_new
	is_activated = false
