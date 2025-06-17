extends Node2D
@export var player : Player
const ENEMY_MAP := {
	Character.Type.ASHMAW: preload("res://Characters/ashmaw.tscn"), 
	Character.Type.VERDMAW: preload("res://Characters/verdmaw.tscn"), 
	Character.Type.BLANCHMAW: preload("res://Characters/blanchmaw.tscn"),
	Character.Type.SKIVER: preload("res://Characters/skivermouth.tscn"), 
	Character.Type.GOREHIDE: preload("res://Characters/gorehide_the_savage.tscn"),
	Character.Type.KINGSKIVER: preload("res://Characters/skivermouth_boss.tscn")
}
var prefab_map:= {
	Collectible.Type.KNIFE: preload("res://Screens/Props/knife.tscn"),
	Collectible.Type.ENEMY_KNIFE: preload("res://Screens/Props/knife.tscn"),
	Collectible.Type.PLAYER_KNIFE: preload("res://Screens/Props/knife.tscn"),
	Collectible.Type.FOOD: preload("res://Screens/Props/food.tscn")
}
func _init() -> void:
	EntityManager.spawn_collectible.connect(_on_spawn_collectible.bind())
	EntityManager.spawn_enemy.connect(_on_spawn_enemy.bind())
	EntityManager.orphan_actor.connect(on_orphan_actor.bind())
func _on_spawn_collectible(type: Collectible.Type, initial_state: Collectible.State, collectible_global_position: Vector2, collectibel_direction: Vector2, inital_height:float):
	var collectible: Collectible = prefab_map[type].instantiate()
	collectible.state = initial_state
	collectible.height = inital_height
	collectible.global_position = collectible_global_position
	collectible.direction = collectibel_direction
	collectible.type = type
	call_deferred("add_child", collectible)

func _on_spawn_enemy(enemy_data: EnemyData):
	var enemy : Character = ENEMY_MAP[enemy_data.type].instantiate()
	enemy.global_position = enemy_data.global_position
	enemy.player = player
	add_child(enemy)

func on_orphan_actor(orphan: Node2D):
	orphan.reparent(self)
