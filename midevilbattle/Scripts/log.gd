extends StaticBody2D

@onready var damage_receiver := $DamageReciver
@onready var sprite := $Sprite2D

@export var overide_content_type: bool = false
@export var knockback_intensity : float
@export var content_type: Collectible.Type = Collectible.Type.NONE
const GRAVITY := 600.0

enum State {IDLE, DESTROYED}

var height := 0.0
var height_speed := 0.0
var state := State.IDLE
var velocity := Vector2.ZERO
var rng = RandomNumberGenerator.new()
var type_arr := [Collectible.Type.KNIFE, Collectible.Type.FOOD, Collectible.Type.NONE]
var weights = PackedFloat32Array([1.5, 1, 3])
func _ready() -> void:
	damage_receiver.damage_received.connect(on_receive_damage.bind())

func _process(delta: float) -> void:
	position += velocity * delta
	sprite.position = Vector2.UP * height
	handle_air_time(delta)

func on_receive_damage(_emitter, _damage: int, direction: Vector2, _hit_type: DamageReceiver.HitType) -> void:
	if state == State.IDLE:
		sprite.texture = load("res://Assets/Props/SnowyLog/SnowyLogHit.png")
		height_speed = knockback_intensity * 2
		state = State.DESTROYED
		if not overide_content_type:
			content_type = type_arr[rng.rand_weighted(weights)]
		if content_type not in [Collectible.Type.ENEMY_KNIFE, Collectible.Type.PLAYER_KNIFE, Collectible.Type.NONE]:
			EntityManager.spawn_collectible.emit(content_type, Collectible.State.FALL, global_position, Vector2.ZERO, 0.0)
		velocity = direction * knockback_intensity

func handle_air_time(delta: float) -> void:
	if state == State.DESTROYED:
		modulate.a -= delta
		height += height_speed * delta
		if height < 0:
			height = 0
			queue_free()
		else:
			height_speed -= GRAVITY * delta
