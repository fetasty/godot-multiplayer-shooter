class_name Enemy
extends CharacterBody2D

@onready var track_timer: Timer = $TrackTimer
@onready var health_component: HealthComponent = $HealthComponent
@onready var visual: Node2D = $Visual
@onready var state_machine: StateMachine = $StateMachine
@onready var warning_icon: Sprite2D = $WarningIcon
@onready var attack_cool_down_timer: Timer = $AttackCoolDownTimer
@onready var charge_timer: Timer = $ChargeTimer
@onready var hit_collision_shape_2d: CollisionShape2D = %HitCollisionShape2D

var track_target: Vector2
var has_track_target: bool = false
var charge_tip_tween: Tween


func _ready() -> void:
	warning_icon.scale = Vector2.ZERO
	if is_multiplayer_authority():
		track_timer.timeout.connect(_on_track_timer_timeout)
		health_component.health_depleted.connect(_on_health_depleted)
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
	velocity = velocity.lerp(Vector2.ZERO, 1.0 - exp(-10 * get_process_delta_time()))


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


func _on_track_timer_timeout() -> void:
	update_track_target()


func _on_health_depleted() -> void:
	state_machine.current_state = "died"
