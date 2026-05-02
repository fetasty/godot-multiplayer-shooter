extends State

## Enemy进入充能攻击状态

const TRIGGER_ATTACK_MIN_DISTANCE_SQUARED: float = 1024.0

var enemy: Enemy2

func _ready() -> void:
	enemy = owner


func enter() -> void:
	# 显示/动画在所有peer展示
	enemy.show_charge_tip()
	# 逻辑相关仅服务器执行
	if is_multiplayer_authority():
		enemy.charge_timer.start()


func update() -> void:
	# 物理/逻辑相关仅服务器执行
	if is_multiplayer_authority():
		# 判断距离, 距离很近了, 攻击(爆炸)
		if enemy.has_track_target:
			var squared_distance = enemy.global_position.distance_squared_to(enemy.track_target)
			if squared_distance < TRIGGER_ATTACK_MIN_DISTANCE_SQUARED:
				transitioned.emit("attack")
			else:
				enemy.velocity = enemy.global_position.direction_to(enemy.track_target) * enemy.MOVE_SPEED * 2.0
				play_move_effects.rpc(true)
		else:
			enemy.velocity = Vector2.ZERO
			play_move_effects.rpc(false)

		if enemy.charge_timer.is_stopped():
			transitioned.emit("attack")


func exit() -> void:
	play_move_effects.rpc(false)
	enemy.hide_charge_tip()
	if is_multiplayer_authority():
		enemy.charge_timer.stop()


@rpc("authority", "call_local")
func play_move_effects(play: bool) -> void:
	if play:
		enemy.move_animation_player.speed_scale = 1.0
		enemy.move_animation_player.play("move")
	else:
		enemy.move_animation_player.play("RESET")
