class_name BasicEnemy
extends Character

const EDGE_SCREEN_BUFFER := 30
#attack timers and player 
@export var duration_between_melee_attacks : int
@export var duration_between_range_attacks : int
@export var duration_prep_melee_attack : int
@export var duration_prep_range_attack : int
@export var player : Player

var player_slot : EnemySlot = null
#timers
var time_since_last_melee_attack := Time.get_ticks_msec()
var time_since_prep_melee_attack := Time.get_ticks_msec()
var time_since_last_range_attack := Time.get_ticks_msec()
var time_since_prep_range_attack := Time.get_ticks_msec()
signal hit_by_knife(knife: Collectible)
func _ready() -> void:
	super._ready()
	anim_attacks = ["punch", "punch_alt"]
	
func handle_input() -> void:
	if player != null and can_move():
		if can_respawn_knives:
			goto_range_position()
		else:
			goto_melee_position()
# for ranged enemies movement
func goto_range_position() -> void:
	var camera := get_viewport().get_camera_2d()
	var screen_width := get_viewport_rect().size.x
	var screen_left_edge := camera.position.x - screen_width / 2
	var screen_right_edge := camera.position.x + screen_width / 2
	
	var left_destination := Vector2(screen_left_edge + EDGE_SCREEN_BUFFER, player.position.y)
	var right_destination := Vector2(screen_right_edge - EDGE_SCREEN_BUFFER, player.position.y)
	var closest_destination := Vector2.ZERO
	if (left_destination - position).length() < (right_destination - position).length():
		closest_destination = left_destination
	else:
		closest_destination = right_destination
	if (closest_destination - position).length() < 1:
		velocity = Vector2.ZERO
	else:
		velocity = (closest_destination - position).normalized() * speed
	
	if can_throw() and has_knife and projectile_aim.is_colliding():
		state = State.THROW
		time_since_knife_dismiss = Time.get_ticks_msec()
		time_since_last_range_attack = Time.get_ticks_msec()
# for mele movement
func goto_melee_position() -> void:
	if player_slot == null:
		player_slot = player.reserve_slot(self)
	
	if player_slot != null:
		var direction := (player_slot.global_position - global_position).normalized()
		if is_player_within_range():
			velocity = Vector2.ZERO
			if can_attack():
				state = State.PREP_ATTACK
				time_since_prep_melee_attack = Time.get_ticks_msec()
		else:
			velocity = direction * speed
# prepe the attack state
func handle_prep_attack() -> void:
	if state == State.PREP_ATTACK and (Time.get_ticks_msec() - time_since_prep_melee_attack > duration_prep_melee_attack):
		state = State.ATTACK
		time_since_last_melee_attack = Time.get_ticks_msec()
		anim_attacks.shuffle()
# close enough to player?? (mele)
func is_player_within_range() -> bool:
	return (player_slot.global_position - global_position).length() < 1

func can_attack() -> bool: # can we attack?
	if Time.get_ticks_msec() - time_since_last_melee_attack < duration_between_melee_attacks:
		return false
	return super.can_attack()

func can_throw() -> bool: #can we throw the knife? 
	if not has_knife:
		time_since_last_range_attack = Time.get_ticks_msec()
	if Time.get_ticks_msec() - time_since_last_range_attack < duration_between_range_attacks and has_knife:
		return false
	return super.can_attack()
func can_get_hit_thrown(_hit_type) -> bool:
	return _hit_type == DamageReceiver.HitType.PLAYERTHROWN
	
func set_heading() -> void:
	if player == null or not can_move():
		return
	heading = Vector2.LEFT if position.x > player.position.x else Vector2.RIGHT
func can_get_hurt() -> bool:
	return [State.IDLE, State.WALK, State.TAKEOFF, State.LAND, State.ATTACK, State.PREP_ATTACK].has(state)


func on_throw_complete() -> void:
	var knife_global_position := Vector2(weapon_position_bottom.global_position)
	var knife_height := -(weapon_position_top.global_position.y - weapon_position_bottom.global_position.y)
	state = State.IDLE
	has_knife = false
	EntityManager.spawn_collectible.emit(Collectible.Type.ENEMY_KNIFE, Collectible.State.FLY, knife_global_position, heading, knife_height)

func on_jump_throw_complete():
	var knife_global_position := Vector2(weapon_position_bottom.global_position)
	var knife_height := -(weapon_position_top.global_position.y - weapon_position_bottom.global_position.y)
	state = State.JUMP
	has_knife = false
	EntityManager.spawn_collectible.emit(Collectible.Type.ENEMY_KNIFE, Collectible.State.FLY, knife_global_position, heading, knife_height)


func on_receive_damage(emitter, amount: int, direction: Vector2, hit_type: DamageReceiver.HitType) -> void:
	super.on_receive_damage(emitter, amount, direction, hit_type)
	ComboManager.register_hit.emit()
	if current_health <= 0:
		play_sound(type)
		player.free_slot(self)
		EntityManager.death_enemy.emit(self)

func play_sound(type): # play death sounds
	if [Character.Type.ASHMAW, Character.Type.VERDMAW, Character.Type.BLANCHMAW].has(type):
		print("playing")
		Music.sfx_play("wolf")
	elif type == Character.Type.SKIVER or type == Character.Type.KINGSKIVER:
		Music.sfx_play("skeleton")
