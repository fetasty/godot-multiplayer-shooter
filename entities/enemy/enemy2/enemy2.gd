class_name Enemy2
extends CharacterBody2D

const HIT_EFFECT = preload("uid://da0onk1mh08tv")
const ENEMY_DIED_EFFECT = preload("uid://bojiofob0nfl")
const BURST_EFFECT = preload("uid://ckgdgjh2c5e2s")
const MOVE_SPEED = 35.0
const BURST_RADIUS = 50.0
const BURST_DAMAGE = 2

@onready var track_timer: Timer = $TrackTimer
@onready var health_component: HealthComponent = $HealthComponent
@onready var visual: Node2D = $Visual
@onready var state_machine: StateMachine = $StateMachine
@onready var warning_icon: Sprite2D = $WarningIcon
@onready var attack_cool_down_timer: Timer = $AttackCoolDownTimer
@onready var charge_timer: Timer = $ChargeTimer
@onready var hurtbox_component: HurtboxComponent = $HurtboxComponent
@onready var flash_sprite_component: FlashSpriteComponent = $Visual/FlashSpriteComponent
@onready var move_animation_player: AnimationPlayer = %MoveAnimationPlayer
@onready var hit_audio_stream_player: AudioStreamPlayer = %HitAudioStreamPlayer
@onready var hurt_collision_shape_2d: CollisionShape2D = $HurtboxComponent/HurtCollisionShape2D
@onready var player_detect_component: PlayerDetectComponent = %PlayerDetectComponent

var track_target: Vector2
var has_track_target: bool = false
var charge_tip_tween: Tween


func _ready() -> void:
	warning_icon.scale = Vector2.ZERO
	hurt_collision_shape_2d.disabled = true
	if is_multiplayer_authority():
		track_timer.timeout.connect(_on_track_timer_timeout)
		health_component.health_depleted.connect(_on_health_depleted)
		hurtbox_component.hit.connect(_on_hit)
		state_machine.current_state = "spawn"
	else:
		track_timer.process_mode = Node.PROCESS_MODE_DISABLED


func _process(_delta: float) -> void:
	if is_multiplayer_authority():
		move_and_slide()


## 播放生成动画
func play_spawn_animation() -> void:
	var tween = create_tween()
	tween.tween_property(visual, "scale", Vector2.ONE, 0.4)\
		.from(Vector2.ZERO)\
		.set_ease(Tween.EASE_OUT)\
		.set_trans(Tween.TRANS_BACK)
	if is_multiplayer_authority():
		# 状态切换仅在服务端执行
		tween.finished.connect(func():
			state_machine.current_state = "normal"
		)


func show_charge_tip() -> void:
	charge_tip_tween = create_tween()
	charge_tip_tween.tween_property(warning_icon, "scale", Vector2.ONE, 0.2)\
		.from(Vector2.ZERO)\
		.set_ease(Tween.EASE_OUT)\
		.set_trans(Tween.TRANS_BACK)


func hide_charge_tip() -> void:
	if charge_tip_tween.is_valid():
		charge_tip_tween.kill()
	charge_tip_tween = create_tween()
	charge_tip_tween.tween_property(warning_icon, "scale", Vector2.ZERO, 0.2)\
		.from(Vector2.ONE)\
		.set_ease(Tween.EASE_OUT)\
		.set_trans(Tween.TRANS_BACK)


func velocity_down() -> void:
	velocity = velocity.lerp(Vector2.ZERO, 1.0 - exp(-6 * get_process_delta_time()))


func update_direction() -> void:
	visual.scale = Vector2.ONE\
		if track_target.x > global_position.x\
		else Vector2(-1, 1)


func update_track_target() -> void:
	var players := get_tree().get_nodes_in_group("player")
	var min_squared_distance: float
	var track_player: Node2D = null
	for player in players:
		if player.is_dead:
			continue
		if track_player == null:
			track_player = player
			min_squared_distance = track_player.global_position.distance_squared_to(global_position)
		var squared_distance = player.global_position.distance_squared_to(global_position)
		if squared_distance < min_squared_distance:
			min_squared_distance = squared_distance
			track_player = player
	if track_player != null:
		track_target = track_player.global_position
		has_track_target = true
	else:
		has_track_target = false


func burst() -> void:
	if not is_multiplayer_authority():
		return
	# 爆炸
	_play_burst_effect.rpc()
	# 爆炸伤害检测模拟
	KLogger.info("[peer %s] detected players count: %s" % [
		multiplayer.get_unique_id(),
		player_detect_component.detected_players.size()
	])
	for player in player_detect_component.detected_players:
		player.take_damage(BURST_DAMAGE)
	# 下一帧消失
	state_machine.current_state = "died"


@rpc("authority", "call_local")
func _play_burst_effect() -> void:
	var effect := BURST_EFFECT.instantiate() as Node2D
	get_parent().add_child(effect)
	effect.global_position = global_position


@rpc("authority", "call_local")
func _play_hit_effect() -> void:
	flash_sprite_component.play_flash_animation()
	hit_audio_stream_player.play()
	var effect := HIT_EFFECT.instantiate() as Node2D
	get_parent().add_child(effect)
	effect.global_position = hurtbox_component.global_position


@rpc("authority", "call_local")
func _play_died_effect() -> void:
	SoundManager.play_enemy_died()
	var effect := ENEMY_DIED_EFFECT.instantiate() as Node2D
	Main.background_effect_clip.add_child(effect)
	effect.global_position = global_position


func _on_track_timer_timeout() -> void:
	update_track_target()


func _on_health_depleted() -> void:
	_play_died_effect.rpc()
	state_machine.current_state = "died"


func _on_hit() -> void:
	_play_hit_effect.rpc()
