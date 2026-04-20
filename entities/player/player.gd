class_name Player
extends CharacterBody2D

signal died
signal player_hurt

const BULLET = preload("uid://clvtit5mibwed")
const MUZZLE_FLASH_EFFECT = preload("uid://ckgdgjh2c5e2s")
const HEALING_EFFECT = preload("uid://di1t1xvv6tgy7")


const REVIVE_HEALTH: int = 1
const BASE_MOVE_SPEED: float = 100
const BASE_FIRE_RATE: float = 0.5
const BASE_BULLET_DAMAGE: int = 1

var input_peer_id: int
var input_display_name: String

var player_look_index: int = 0

var move_vector: Vector2 = Vector2.ZERO
var is_dead: bool = false

@onready var player_input_multiplayer_synchronizer_component: PlayerInputMultiplayerSynchronizerComponent = $PlayerInputMultiplayerSynchronizerComponent
@onready var weapon_root: Node2D = %WeaponRoot
@onready var attack_timer: Timer = $AttackTimer
@onready var health_component: HealthComponent = $HealthComponent
@onready var visual_root: Node2D = $VisualRoot
@onready var weapon_animation_player: AnimationPlayer = %WeaponAnimationPlayer
@onready var attack_point: Marker2D = %AttackPoint
@onready var display_name_label: Label = %DisplayNameLabel
@onready var health_progress_bar: TextureProgressBar = %TextureProgressBar
@onready var player_info: VBoxContainer = %PlayerInfo
@onready var move_animation_player: AnimationPlayer = %MoveAnimationPlayer
@onready var hurtbox_component: HurtboxComponent = $HurtboxComponent
@onready var flash_sprite_component: FlashSpriteComponent = %FlashSpriteComponent
@onready var collision_shape_2d: CollisionShape2D = $HurtboxComponent/CollisionShape2D
@onready var audio_stream_player: AudioStreamPlayer = %AudioStreamPlayer
@onready var healing_effect: HealingEffect = %HealingEffect


func _ready() -> void:
	print("[peer %s] Set player(%s) input authroity %s" % [multiplayer.get_unique_id(), name, input_peer_id])
	player_input_multiplayer_synchronizer_component.set_multiplayer_authority(input_peer_id)
	var is_peer_authority = multiplayer.get_unique_id() == input_peer_id
	player_info.visible = not is_peer_authority
	flash_sprite_component.frame = player_look_index
	GameEvents.player_look_changed.connect(_on_player_look_changed)
	if not is_peer_authority:
		display_name_label.text = input_display_name
	if is_multiplayer_authority():
		health_component.health_depleted.connect(_on_health_depleted)
		health_component.health_changed.connect(_on_health_changed)
		hurtbox_component.hit.connect(_on_hit)


func _process(delta: float) -> void:
	_update_aim_direction()
	var input := player_input_multiplayer_synchronizer_component.move_vector
	if is_zero_approx(input.length_squared()):
		move_animation_player.play("RESET")
	elif not move_animation_player.is_playing():
		move_animation_player.play("move")
	if is_multiplayer_authority():
		var target_velocity = input * _get_move_speed()
		velocity = velocity.lerp(target_velocity, 1.0 - exp(-20.0 * delta))
		move_and_slide()
		if player_input_multiplayer_synchronizer_component.is_attack_pressing:
			_try_to_attack()


func _update_aim_direction() -> void:
	var aim_vector := player_input_multiplayer_synchronizer_component.aim_vector
	visual_root.scale = Vector2.ONE if aim_vector.x >= 0 else Vector2(-1.0, 1.0)
	weapon_root.look_at(weapon_root.global_position + aim_vector)


func _get_move_speed() -> float:
	var upgrade_count := UpgradeComponent.get_peer_upgrade_count(
		input_peer_id,
		"move_speed"
	)
	return BASE_MOVE_SPEED * (1.0 + 0.1 * upgrade_count)


func _get_fire_rate() -> float:
	var upgrade_count := UpgradeComponent.get_peer_upgrade_count(
		input_peer_id,
		"fire_rate"
	)
	return BASE_FIRE_RATE * clamp(1.0 - 0.08 * upgrade_count, 0, 100)



func _get_bullet_damage() -> int:
	var upgrade_count := UpgradeComponent.get_peer_upgrade_count(
		input_peer_id,
		"damage"
	)
	return BASE_BULLET_DAMAGE + upgrade_count


func _try_to_attack() -> void:
	if not attack_timer.is_stopped():
		return
	attack_timer.wait_time = _get_fire_rate()
	attack_timer.start()
	var bullet := BULLET.instantiate() as Bullet
	bullet.global_position = attack_point.global_position
	bullet.direction = player_input_multiplayer_synchronizer_component.aim_vector
	bullet.rotation = bullet.direction.angle()
	bullet.damage = _get_bullet_damage()
	get_parent().add_child(bullet, true)
	_play_attack_effect.rpc()


@rpc("authority", "call_local", "unreliable")
func _play_attack_effect() -> void:
	if weapon_animation_player.is_playing():
		weapon_animation_player.stop()
	weapon_animation_player.play("attack")
	audio_stream_player.play()
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
	set_player_visible.rpc(false)
	died.emit()


func revive(pos: Vector2) -> void:
	print("[peer %s] Player %s revive!" % [multiplayer.get_unique_id(), input_peer_id])
	global_position = pos
	velocity = Vector2.ZERO
	process_mode = Node.PROCESS_MODE_INHERIT
	healing(REVIVE_HEALTH)
	set_player_visible.rpc(true)
	is_dead = false


func healing(value: int) -> void:
	if not is_multiplayer_authority():
		return
	health_component.healing(value)
	play_player_healing_effect.rpc()


@rpc("authority", "call_local")
func play_player_healing_effect() -> void:
	healing_effect.play()
	if multiplayer.get_unique_id() == input_peer_id:
		SoundManager.play_healing()


@rpc("authority", "call_local", "reliable")
func set_player_visible(enabled: bool) -> void:
	visible = enabled


@rpc("authority", "call_local", "reliable")
func set_player_health_bar(rate: float) -> void:
	health_progress_bar.value = rate
	if multiplayer.get_unique_id() == input_peer_id:
		GameEvents.emit_local_player_health_changed(rate)


@rpc("authority", "call_local")
func play_hit_effects() -> void:
	flash_sprite_component.play_flash_animation()
	if is_multiplayer_authority():
		collision_shape_2d.disabled = true
	var tween := create_tween()
	tween.set_loops(10)
	tween.tween_property(flash_sprite_component, "visible", false, 0.1)
	tween.tween_property(flash_sprite_component, "visible", true, 0.1)
	if is_multiplayer_authority():
		tween.finished.connect(func():
			collision_shape_2d.disabled = false
		)


func _on_health_depleted() -> void:
	if not is_dead:
		is_dead = true
		_player_died.call_deferred()


func _on_health_changed(max_value: int, current_value: int) -> void:
	print("[peer %s] Player %s health change: %s / %s" % [
		multiplayer.get_unique_id(), input_peer_id, current_value, max_value
	])
	set_player_health_bar.rpc(current_value * 1.0 / max_value)


func _on_hit() -> void:
	if not is_dead:
		play_hit_effects.rpc()
		player_hurt.emit()


func _on_player_look_changed(peer_id: int, index: int) -> void:
	if peer_id != input_peer_id:
		return
	print("[peer %s] player %s change look to %s" % [
		multiplayer.get_unique_id(),
		input_peer_id,
		index,
	])
	player_look_index = index
	flash_sprite_component.frame = index
