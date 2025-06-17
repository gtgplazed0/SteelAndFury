class_name Player
extends Character
var hit
@export var max_duration_between_successful_hits: int
@onready var enemy_slots : Array = $PrimaryEnemySlots.get_children()
var time_since_last_successful_attack = Time.get_ticks_msec()
func _ready() -> void:
	super._ready()
	set_health(max_health)
	anim_attacks = ["punch", "punch_alt", "punch_alt_2", "punch_alt_3"]
func _process(delta: float) -> void:
	super._process(delta)
	process_time_between_combos()
func handle_input() -> void:
	if can_move():
		var direction := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
		velocity = direction * speed
	if can_attack() and Input.is_action_just_pressed("attack"):
		if can_pickup_collectible():
			state = State.PICKUP
		else:
			Music.sfx_play("sword")
			state = State.ATTACK
	elif can_attack() and Input.is_action_just_pressed("throw"):
		if has_knife:
			Music.sfx_play("dagger")
			state = State.THROW
			attack_combo_index = 0
	if can_jump() and Input.is_action_just_pressed("jump"):
		state = State.TAKEOFF
		attack_combo_index = 0
	if can_jumpkick() and Input.is_action_just_pressed("throw"):
		if has_knife:
			Music.sfx_play("dagger")
			state = State.JUMPTHROW
			attack_combo_index = 0
	elif can_jumpkick() and Input.is_action_just_pressed("attack"):
			Music.sfx_play("sword")
			state = State.JUMPKICK
			attack_combo_index = 0
		

func set_heading() -> void:
	if can_move():
		if velocity.x > 0:
			heading = Vector2.RIGHT
		elif velocity.x < 0:
			heading = Vector2.LEFT
		
func reserve_slot(enemy: BasicEnemy) -> EnemySlot:
	var available_slots := enemy_slots.filter(
		func(slot): return slot.is_free()
	)
	if available_slots.size() == 0:
		return null
	available_slots.sort_custom(
		func(a: EnemySlot, b: EnemySlot):
			var dist_a := (enemy.global_position - a.global_position).length()
			var dist_b := (enemy.global_position - b.global_position).length()
			return dist_a < dist_b
	)
	available_slots[0].occupy(enemy)
	return available_slots[0]

func free_slot(enemy: BasicEnemy) -> void:
	var target_slots := enemy_slots.filter(
		func(slot: EnemySlot): return slot.occupant == enemy
	)
	if target_slots.size() == 1:
		target_slots[0].free_up()

func can_get_hurt() -> bool:
	return [State.IDLE, State.WALK, State.TAKEOFF, State.LAND].has(state)

func can_get_hit_thrown(_hit_type) -> bool:
	return _hit_type == DamageReceiver.HitType.ENEMYTHROWN

func on_throw_complete() -> void:
	var knife_global_position := Vector2(weapon_position_bottom.global_position)
	var knife_height := -(weapon_position_top.global_position.y - weapon_position_bottom.global_position.y)
	state = State.IDLE
	has_knife = false
	EntityManager.spawn_collectible.emit(Collectible.Type.PLAYER_KNIFE, Collectible.State.FLY, knife_global_position, heading, knife_height)

func on_jump_throw_complete():
	var knife_global_position := Vector2(weapon_position_bottom.global_position)
	var knife_height := -(weapon_position_top.global_position.y - weapon_position_bottom.global_position.y)
	state = State.JUMP
	has_knife = false
	EntityManager.spawn_collectible.emit(Collectible.Type.PLAYER_KNIFE, Collectible.State.FLY, knife_global_position, heading, knife_height)

func process_time_between_combos():
	if Time.get_ticks_msec() - time_since_last_successful_attack > max_duration_between_successful_hits: 
		attack_combo_index = 0

func on_attack_complete():
	if is_last_hit_successful:
		attack_combo_index = (attack_combo_index + 1) % anim_attacks.size()
		time_since_last_successful_attack = Time.get_ticks_msec()
		is_last_hit_successful = false
	else:
		attack_combo_index = 0
func on_receive_damage(emitter, amount: int, direction: Vector2, hit_type: DamageReceiver.HitType) -> void:
	super.on_receive_damage(emitter, amount, direction, hit_type)
	Music.sfx_play("hurt")
	ComboManager.player_hit.emit()

func on_emit_damage(receiver: DamageReceiver) -> void:
	hit = true
	super.on_emit_damage(receiver)
	Music.sfx_play("hit")
