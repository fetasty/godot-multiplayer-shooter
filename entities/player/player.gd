class_name Player
extends CharacterBody2D

const BULLET = preload("uid://clvtit5mibwed")

var input_peer_id : int
var move_vector: Vector2 = Vector2.ZERO
var move_speed: float = 100.0

@onready var player_input_multiplayer_synchronizer_component: PlayerInputMultiplayerSynchronizerComponent = $PlayerInputMultiplayerSynchronizerComponent
@onready var weapon_root: Node2D = %WeaponRoot
@onready var attack_timer: Timer = $AttackTimer
@onready var health_component: HealthComponent = $HealthComponent
@onready var visual_root: Node2D = $VisualRoot

func _ready() -> void:
	print("[peer %s] Set player(%s) input authroity %s" % [multiplayer.get_unique_id(), name, input_peer_id])
	player_input_multiplayer_synchronizer_component.set_multiplayer_authority(input_peer_id)
	if is_multiplayer_authority():
		health_component.health_depleted.connect(_on_health_depleted)


func _process(_delta: float) -> void:
	_update_aim_direction()
	if is_multiplayer_authority():
		var input := player_input_multiplayer_synchronizer_component.move_vector
		velocity = input * move_speed
		move_and_slide()
		if player_input_multiplayer_synchronizer_component.is_attack_pressing:
			_try_to_attack()


func _update_aim_direction() -> void:
	var aim_vector := player_input_multiplayer_synchronizer_component.aim_vector
	visual_root.scale = Vector2.ONE if aim_vector.x >= 0 else Vector2(-1.0, 1.0)
	weapon_root.look_at(weapon_root.global_position + aim_vector)


func _try_to_attack() -> void:
	if not attack_timer.is_stopped():
		return
	attack_timer.start()
	var bullet := BULLET.instantiate() as Bullet
	bullet.global_position = weapon_root.global_position
	bullet.direction = player_input_multiplayer_synchronizer_component.aim_vector
	bullet.rotation = bullet.direction.angle()
	get_parent().add_child(bullet, true)


func _on_health_depleted() -> void:
	print("[peer %s] Player %s died!" % [multiplayer.get_unique_id(), input_peer_id])
