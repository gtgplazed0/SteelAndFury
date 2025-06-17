class_name Stage
extends Node2D
@onready var containers := $Containers
@onready var container = []
func _ready() -> void:
	for container :Node2D in containers.get_children():
		EntityManager.orphan_actor.emit(container)
