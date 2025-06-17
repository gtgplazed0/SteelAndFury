class_name GoreHide
extends Character
const GROUNDFRICTION = 65

@export var player: Player
@export var duration_between_attacks : int
@export var distance_from_player: int
@export var duration_vulnerable: int

var knock_back_force := Vector2.ZERO
var time_since_last_attack := Time.get_ticks_msec()
var time_start_vulnerable := Time.get_ticks_msec()

func _process(delta: float) -> void:
	super._process(delta)
	knock_back_force = knock_back_force.move_toward(Vector2.ZERO, delta * GROUNDFRICTION)
func get_target_destination() -> Vector2:
	var target := Vector2.ZERO
	if position.x < player.position.x:
		target = player.position + Vector2.LEFT * distance_from_player
	else:
		target = player.position + Vector2.RIGHT * distance_from_player
	return target

func is_player_within_range() -> bool:
	var target := get_target_destination()
	return (target-position).length() < 1

func handle_input() -> void:
	if player and can_move():
		if can_attack() and projectile_aim.is_colliding():
			Music.sfx_play("bearattack")
			state = State.FLY
			velocity = heading * flight_speed
		else:
			if is_player_within_range():
				velocity = Vector2.ZERO
				state = State.IDLE
			else:
				var target_destination := get_target_destination()
				var direction = (target_destination - position).normalized()
				velocity = (direction + knock_back_force) * speed
				state = State.WALK
			
func set_heading() -> void:
	if player == null or not can_move():
		return
	heading = Vector2.LEFT if position.x > player.position.x else Vector2.RIGHT
	
func can_get_hurt():
	return true
	
func is_vulnerable():
	return state == State.RECOVER
	
func on_receive_damage(emitter, amount: int, direction: Vector2, hit_type: DamageReceiver.HitType) -> void:
	if can_get_hit_thrown(hit_type):
		if emitter is Collectible:
				emitter.delete_collectible()
		knock_back_force = direction * knockback_intensity
	else:
		if not is_vulnerable():
			knock_back_force = direction * knockback_intensity
			return
		ComboManager.register_hit
		set_health(current_health - amount)
		hit_flash_anim.play("hit")
		if current_health == 0:
			Music.sfx_play("beardead")
			state == State.DEATH
			height_speed = knockdown_intensity
			velocity = direction*knockdown_intensity
			EntityManager.death_enemy.emit(self)
		else:
			velocity = Vector2.ZERO
			state = State.HURT
			
func can_attack():
	if Time.get_ticks_msec() - time_since_last_attack < duration_between_attacks:
		return false
	return super.can_attack()
	
func on_action_complete() -> void:
	if state == State.HURT:
		state = State.RECOVER
		return
	super.on_action_complete()
	
func handle_grounded() -> void:
	if state == State.GROUNDED and current_health > 0:
		state = State.RECOVER
		time_start_vulnerable = Time.get_ticks_msec()
	elif state == State.RECOVER and Time.get_ticks_msec() -time_start_vulnerable > duration_vulnerable:
		state = State.IDLE
		time_since_last_attack = Time.get_ticks_msec()
	elif (state == State.GROUNDED or state == State.RECOVER) and current_health == 0:
		state = State.DEATH
		velocity = Vector2.ZERO
func can_get_hit_thrown(_hit_type) -> bool:
	return _hit_type == DamageReceiver.HitType.PLAYERTHROWN
func on_emit_damage(receiver: DamageReceiver) -> void:
	receiver.damage_received.emit(self, damage, heading, DamageReceiver.HitType.KNOCKDOWN)
	time_since_last_attack = Time.get_ticks_msec()
	state = State.IDLE
	
	
func on_wall_hit(_wall: AnimatableBody2D) -> void:
	if in_wall_detection.get_overlapping_bodies().size() != 0:
		return
	else:
		state = State.FALL
		height_speed = knockback_intensity
		velocity = -velocity / 2.0
