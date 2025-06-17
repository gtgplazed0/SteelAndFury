class_name Character
extends CharacterBody2D

const GRAVITY := 600.0
@export var can_respawn : bool
@export var can_respawn_knives : bool
@export var can_drop_knives: bool
@export var damage : int
@export var damage_power : int
@export var duration_grounded: float
@export var duration_between_knife_respawn : int
@export var flight_speed : float
@export var has_knife : bool
@export var jump_intensity : float
@export var knockback_intensity : float
@export var knockdown_intensity : float
@export var max_health : int
@export var speed : float
@export var type: Type

@onready var hit_flash_anim: AnimationPlayer = $HitFlash
@onready var projectile_aim : RayCast2D = $ProjectileAim
@onready var animation_player := $AnimationPlayer
@onready var character_sprite := $Sprite
@onready var collateral_damage_emitter : Area2D = $CollatDamageEmitter
@onready var collision_shape := $CollisionShape2D
@onready var damage_emitter := $DamageEmitter
@onready var damage_receiver : DamageReceiver = $DamageReciver
@onready var knife_sprite := $KnifeSprite
@onready var collectible_sensor : Area2D = $CollectibleSensor
@onready var weapon_position_bottom : Node2D = $Shadow/WeaponPositionBottom
@onready var weapon_position_top : Node2D = $KnifeSprite/WeaponPositionTop
@onready var shadow : Sprite2D = $Shadow
@onready var in_wall_detection : Area2D = $InWallDetector

enum State {IDLE, WALK, ATTACK, TAKEOFF, JUMP, LAND, JUMPKICK, HURT, FALL, GROUNDED, DEATH, FLY, PREP_ATTACK, THROW,JUMPTHROW,PICKUP, RECOVER}
enum Type{PLAYER, ASHMAW, BLANCHMAW, VERDMAW, SKIVER, GOREHIDE, KINGSKIVER}
var anim_attacks := []
var anim_map := {
	State.IDLE: "idle",
	State.WALK: "walk",
	State.ATTACK: "punch",
	State.TAKEOFF: "take_off",
	State.JUMP: "jump",
	State.LAND: "landing",
	State.JUMPKICK: "jump_kick",
	State.HURT: "hurt",
	State.FALL: "fall",
	State.GROUNDED: "grounded",
	State.DEATH: "dead",
	State.FLY: "fly",
	State.PREP_ATTACK: "idle",
	State.THROW: "throw",
	State.PICKUP:'pickup',
	State.JUMPTHROW: "jump_throw",
	State.RECOVER: "recover"
}
var attack_combo_index := 0
var current_health := 0
var heading := Vector2.RIGHT
var height := 0.0
var height_speed := 0.0
var is_last_hit_successful := false
var state := State.IDLE
var time_since_grounded := Time.get_ticks_msec()
var time_since_knife_dismiss := Time.get_ticks_msec()
signal free_knife(knife: Collectible)

func _ready() -> void:
	damage_emitter.area_entered.connect(on_emit_damage.bind())
	damage_receiver.damage_received.connect(on_receive_damage.bind())
	collateral_damage_emitter.area_entered.connect(on_emit_collateral_damage.bind())
	collateral_damage_emitter.body_entered.connect(on_wall_hit.bind())
	current_health = max_health
func _process(delta: float) -> void:
	handle_input()
	handle_movement()
	handle_animations()
	handle_air_time(delta)
	handle_prep_attack()
	handle_grounded()
	handle_knife_respawn()
	handle_death(delta)
	set_heading()
	flip_sprites()
	knife_sprite.visible = has_knife
	character_sprite.position = Vector2.UP * height
	knife_sprite.position = Vector2.UP * height
	collision_shape.disabled = is_collision_disabled()
	damage_receiver.monitorable = can_get_hurt()
	move_and_slide()

func handle_movement() -> void:
	if can_move():
		if velocity.length() == 0:
			state = State.IDLE
		else:
			state = State.WALK

func handle_input() -> void:
	pass

func handle_prep_attack() -> void:
	pass

func handle_grounded() -> void:
	if state == State.GROUNDED:
		if current_health <= 0:
			state = State.DEATH
		if (Time.get_ticks_msec() - time_since_grounded > duration_grounded):
			state = State.LAND
func handle_knife_respawn() -> void:
	if can_respawn_knives and not has_knife and (Time.get_ticks_msec() - time_since_knife_dismiss > duration_between_knife_respawn):
		has_knife = true
		
	
func handle_death(delta: float) -> void:
	if state == State.DEATH and not can_respawn:
		character_sprite.set_material(null)
		modulate.a -= delta / 2.0
		if modulate.a <= 0:
			queue_free()

func handle_animations() -> void:
	if state == State.ATTACK:
		animation_player.play(anim_attacks[attack_combo_index])
	elif animation_player.has_animation(anim_map[state]):
		animation_player.play(anim_map[state])

func handle_air_time(delta: float) -> void:
	if [State.JUMP, State.JUMPKICK, State.FALL].has(state):
		height += height_speed * delta
		if height < 0:
			height = 0
			if state == State.FALL:
				state = State.GROUNDED
				time_since_grounded = Time.get_ticks_msec()
			else:
				state = State.LAND
			velocity = Vector2.ZERO
		else:
			height_speed -= GRAVITY * delta

func set_heading() -> void:
	pass

func flip_sprites() -> void:
	if heading == Vector2.RIGHT:
		character_sprite.flip_h = false
		damage_emitter.scale.x = 1
		damage_receiver.scale.x = 1
		collateral_damage_emitter.scale.x = 1
		in_wall_detection.scale.x = 1
		projectile_aim.scale.x = 1
		knife_sprite.scale.x = 1
		shadow.scale.x = 1
		
	else:
		character_sprite.flip_h = true
		damage_emitter.scale.x = -1
		damage_receiver.scale.x = -1
		collateral_damage_emitter.scale.x = -1
		in_wall_detection.scale.x = -1
		projectile_aim.scale.x = -1
		knife_sprite.scale.x = -1
		shadow.scale.x = -1
func can_move() -> bool:
	return state == State.IDLE or state == State.WALK

func can_attack() -> bool:
	return state == State.IDLE or state == State.WALK

func can_jump() -> bool:
	return state == State.IDLE or state == State.WALK

func can_jumpkick() -> bool:
	return state == State.JUMP
	
func can_get_hurt() -> bool:
	return false
	
func can_get_hit_thrown(_hit_type) -> bool:
	return false
	
func can_pickup_collectible() -> bool:
	var collectible_areas := collectible_sensor.get_overlapping_areas()
	if collectible_areas.size() == 0:
		return false
	var collectible : Collectible = collectible_areas[0]
	if collectible.type == collectible.Type.KNIFE and not has_knife:
		return true
	if collectible.type == collectible.Type.FOOD and current_health < max_health:
		return true
	return false
	
func pickup_collectible():
	if can_pickup_collectible():
		var collectible_areas := collectible_sensor.get_overlapping_areas()
		var collectible : Collectible = collectible_areas[0]
		if collectible.type == collectible.Type.KNIFE and not has_knife:
			has_knife = true
			can_drop_knives = true
		if collectible.type == collectible.Type.FOOD and can_pickup_collectible():
			Music.sfx_play("eat")
			set_health(max_health)
		collectible.queue_free()

func is_collision_disabled() -> bool:
	return [State.GROUNDED, State.DEATH, State.FLY].has(state)

func on_action_complete() -> void:
	state = State.IDLE

func on_throw_complete() -> void:
	pass
	
func on_jump_throw_complete():
	pass

func on_takeoff_complete() -> void:
	state = State.JUMP
	height_speed = jump_intensity

func on_land_complete() -> void:
	state = State.IDLE

func on_pickup_complete():
	state = State.IDLE
	pickup_collectible()

func on_receive_damage(emitter, amount: int, direction: Vector2, hit_type: DamageReceiver.HitType) -> void:
	if can_get_hit_thrown(hit_type):
		if emitter is Collectible:
			emitter.delete_collectible()
		if current_health <= 0:
			state = State.FALL
			height_speed = knockdown_intensity
			velocity = direction * knockback_intensity
		state = State.FALL
		height_speed = knockdown_intensity
		velocity = direction * knockback_intensity
	else:
		if can_get_hurt():
			hit_flash_anim.play("hit")
			attack_combo_index = 0
			if has_knife:
				has_knife = false
				if can_drop_knives:
					can_drop_knives = false
					EntityManager.spawn_collectible.emit(Collectible.Type.KNIFE, Collectible.State.FALL, global_position, Vector2.ZERO, 0.0)				
				time_since_knife_dismiss = Time.get_ticks_msec()
			set_health(current_health-amount)
			if hit_type not in [DamageReceiver.HitType.PLAYERTHROWN, DamageReceiver.HitType.ENEMYTHROWN]:
				if current_health <= 0 or hit_type == DamageReceiver.HitType.KNOCKDOWN:
					state = State.FALL
					height_speed = knockdown_intensity
					velocity = direction * knockback_intensity
				elif hit_type == DamageReceiver.HitType.POWER:
					state = State.FLY
					velocity = direction * flight_speed
				else:
					state = State.HURT
					velocity = direction * knockback_intensity

func on_emit_damage(receiver: DamageReceiver) -> void:
	var hit_type := DamageReceiver.HitType.NORMAL
	var direction := Vector2.LEFT if receiver.global_position.x < global_position.x else Vector2.RIGHT
	var current_damage = damage
	if state == State.JUMPKICK:
		hit_type = DamageReceiver.HitType.KNOCKDOWN
		current_damage = current_damage
	elif attack_combo_index == anim_attacks.size() - 1:
		hit_type = DamageReceiver.HitType.POWER
		current_damage = damage_power
	receiver.damage_received.emit(self, current_damage, direction, hit_type)
	if not receiver.is_in_group("props"):
		is_last_hit_successful = true

func on_emit_collateral_damage(receiver: DamageReceiver) -> void:
	if receiver != damage_receiver:
		var direction := Vector2.LEFT if receiver.global_position.x < global_position.x else Vector2.RIGHT
		receiver.damage_received.emit(self, 0, direction, DamageReceiver.HitType.KNOCKDOWN)

func on_wall_hit(_wall: AnimatableBody2D) -> void:
	state = State.FALL
	height_speed = knockback_intensity
	velocity = -velocity / 2.0
	
func set_health(health):
	current_health = clamp(health, 0, max_health)
	DamageManager.health_change.emit(type, current_health, max_health)
