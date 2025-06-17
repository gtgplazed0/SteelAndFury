class_name Collectible
extends Area2D

const GRAVITY := 600.0 
#exported editable vars
@export var speed : float
@export var type := Type.KNIFE
@export var damage : int
@export var knockdown_intensity: float
#object vars
@onready var animation_player := $AnimationPlayer
@onready var collectible_sprite := $CollectibleSprite
@onready var damage_emitter: Area2D = $DamageEmitter
#enum maps
enum State {FALL, GROUNDED, FLY}
enum Type{KNIFE, ENEMY_KNIFE, PLAYER_KNIFE, FOOD, NONE}# type of colelctible
var anim_map := {
	State.FALL: "fall", 
	State.GROUNDED: "grounded", 
	State.FLY: "fly"
}
#sprites
var food_sprites := ["res://Assets/Props/Food/Apple.png","res://Assets/Props/Food/Bread.png", "res://Assets/Props/Food/TurkeyLeg.png"]
#height for falling
var height := 0.0
var height_speed := 0.0
#current state
var state = State.FALL
var direction := Vector2.ZERO
var velocity:= Vector2.ZERO
#type of hit for knives
var hit_type: DamageReceiver.HitType

func _ready() -> void:
	#called on ready, load correct sprite, and state
	if type == Type.FOOD:
		food_sprites.shuffle()
		collectible_sprite.texture = load(food_sprites[0])
	height_speed = knockdown_intensity
	if state == State.FLY:
		handle_animations()
		velocity = direction*speed
	damage_emitter.area_entered.connect(_on_emit_damage.bind())
	damage_emitter.body_exited.connect(_on_body_exit.bind())
func _process(delta: float) -> void:
	handle_fall(delta)
	handle_animations()
	flip_scales()
	#set positions
	collectible_sprite.position = Vector2.UP * height
	damage_emitter.position = Vector2.UP * height
	damage_emitter.monitoring = can_do_damage()
	position += velocity * delta


func flip_scales():
	collectible_sprite.flip_h = velocity.x < 0
	if velocity.x > 0: 
		damage_emitter.scale.x = 1
	elif velocity.x < 0: 
		damage_emitter.scale.x = -1
func handle_fall(delta):
	if state == State.FALL:
		height += height_speed * delta
		if height <= 0:
			height = 0
			state = State.GROUNDED
		else:
			height_speed -= GRAVITY * delta
			
func can_do_damage():
	return state == State.FLY
func handle_animations():
	animation_player.play(anim_map[state])

func _on_emit_damage(reciever: DamageReceiver): # emitting damage to the player
	if type == Type.PLAYER_KNIFE:
		hit_type = DamageReceiver.HitType.PLAYERTHROWN
	elif type == Type.ENEMY_KNIFE:
		hit_type = DamageReceiver.HitType.ENEMYTHROWN
	reciever.damage_received.emit(self, damage, direction, hit_type)
	
func _on_body_exit(_wall: AnimatableBody2D):
	queue_free() # delete object

func delete_collectible():
	call_deferred("queue_free")
# delete object, after frames are finished (proper loading of new ones)
