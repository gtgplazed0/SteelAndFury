class_name DamageReceiver
extends Area2D

enum HitType {NORMAL, KNOCKDOWN, POWER, ENEMYTHROWN, PLAYERTHROWN}

signal damage_received(emitter, damage: int, direction: Vector2, hit_type: HitType)
