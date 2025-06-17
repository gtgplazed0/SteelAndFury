class_name EnemyData
extends Resource

@export var height : int
@export var type : Character.Type
@export var global_position : Vector2
@export var state : Character.State

func _init(character_type : Character.Type, position : Vector2 = Vector2.ZERO) -> void:
	type = character_type
	global_position = position
	state = Character.State.IDLE
