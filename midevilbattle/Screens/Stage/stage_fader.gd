extends CanvasLayer
@onready var colour = $ColorRect
@onready var label = $Label
@export var change_factor: float
func _process(delta: float) -> void:
	if visible == true:
		colour.modulate.a -= delta / change_factor
		label.modulate.a -= delta / change_factor
	if colour.modulate.a == 0:
		visible = false
		colour.modulate.a = 255
		label.modulate.a = 255
