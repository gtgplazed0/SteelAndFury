class_name HealthBar
extends Control

@onready var white_border := $WhiteBorder
@onready var red_bar := $BlackBG
@onready var health_gauge := $HealthGauge

func refresh(current_health: int, max_health: int, type: Character.Type):
	var multiplier = 2 if max_health < 25 else 1
	white_border.scale.x = (max_health * multiplier) + 2
	red_bar.scale.x = (max_health ) * multiplier
	health_gauge.scale.x = (current_health) * multiplier
