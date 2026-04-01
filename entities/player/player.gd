class_name Player
extends CharacterBody2D

signal died

const BULLET = preload("uid://clvtit5mibwed")
const MUZZLE_FLASH_EFFECT = preload("uid://ckgdgjh2c5e2s")

var input_peer_id: int
var input_display_name: String

var move_vector: Vector2 = Vector2.ZERO
var move_speed: float = 100.0
var is_dead: bool = false

@onready var player_input_multiplayer_synchronizer_component: PlayerInputMultiplayerSynchronizerComponent = $PlayerInputMultiplayerSynchronizerComponent
@onready var weapon_root: Node2D = %WeaponRoot
@onready var attack_timer: Timer = $AttackTimer
@onready var health_component: HealthComponent = $HealthComponent
@onready var visual_root: Node2D = $VisualRoot
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var attack_point: Marker2D = %AttackPoint
@onready var display_name_label: Label = $DisplayNameLabel
@onready var texture_progress_bar: TextureProgressBar = $TextureProgressBar

func _ready() -> void:
	print("[peer %s] Set player(%s) input authroity %s" % [multiplayer.get_unique_id(), name, input_peer_id])
	player_input_multiplayer_synchronizer_component.set_multiplayer_authority(input_peer_id)
	display_name_label.text = input_display_name
	if is_multiplayer_authority():
		health_component.health_depleted.connect(_on_health_depleted)
		health_component.health_changed.connect(_on_health_changed)


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
	bullet.global_position = attack_point.global_position
	bullet.direction = player_input_multiplayer_synchronizer_component.aim_vector
	bullet.rotation = bullet.direction.angle()
	get_parent().add_child(bullet, true)
	_play_attack_effect.rpc()


@rpc("authority", "call_local", "unreliable")
func _play_attack_effect() -> void:
	if animation_player.is_playing():
		animation_player.stop()
	animation_player.play("attack")
	var effect: Node2D = MUZZLE_FLASH_EFFECT.instantiate()
	effect.global_position = attack_point.global_position
	effect.global_rotation = attack_point.global_rotation
	get_parent().add_child(effect)
	if player_input_multiplayer_synchronizer_component.is_multiplayer_authority():
		GameCamera.shake()


func _player_died() -> void:
	print("[peer %s] Player %s died!" % [multiplayer.get_unique_id(), input_peer_id])
	velocity = Vector2.ZERO
	process_mode = Node.PROCESS_MODE_DISABLED
	is_dead = true
	set_player_visible.rpc(false)
	died.emit()


func revive(pos: Vector2) -> void:
	print("[peer %s] Player %s revive!" % [multiplayer.get_unique_id(), input_peer_id])
	global_position = pos
	velocity = Vector2.ZERO
	process_mode = Node.PROCESS_MODE_INHERIT
	health_component.reset()
	set_player_visible.rpc(true)
	is_dead = false


@rpc("authority", "call_local", "reliable")
func set_player_visible(enabled: bool) -> void:
	visible = enabled

@rpc("authority", "call_local", "reliable")
func set_player_health_bar(rate: float) -> void:
	texture_progress_bar.value = rate


func _on_health_depleted() -> void:
	_player_died()


func _on_health_changed(max_value: int, current_value: int) -> void:
	print("[peer %s] Player %s health change: %s / %s" % [
		multiplayer.get_unique_id(), input_peer_id, current_value, max_value
	])
	set_player_health_bar.rpc(current_value * 1.0 / max_value)
