extends State

## Enemy的正常状态,允许移动

const ATTACK_DISTANCE_SQUARED: float = 14400.0
const MIN_ATTACK_DISTANCE_SQUARED: float = 256.0

var enemy: Enemy1

func _ready() -> void:
	enemy = owner


func enter() -> void:
	if is_multiplayer_authority():
		enemy.update_track_target()


func update() -> void:
	# 服务器逻辑
	if is_multiplayer_authority():
		# 如果有跟踪目标,则设置速度,向目标移动
		if enemy.has_track_target:
			enemy.velocity = enemy.global_position.direction_to(enemy.track_target) * 35
			play_move_effects.rpc(true)
			# 如果距离目标玩家距离小于一定值,准备攻击
			var squared_distance = enemy.global_position.distance_squared_to(enemy.track_target)
			if squared_distance < MIN_ATTACK_DISTANCE_SQUARED or \
				(squared_distance < ATTACK_DISTANCE_SQUARED and \
				enemy.attack_cool_down_timer.is_stopped()):
					enemy.attack_cool_down_timer.start()
					transitioned.emit("charge")
		else:
			enemy.velocity = Vector2.ZERO
			play_move_effects.rpc(false)
	# 显示/动画 -- 所有peer
	enemy.update_direction()


func exit() -> void:
	enemy.move_animation_player.play("RESET")



@rpc("authority", "call_local")
func play_move_effects(play: bool) -> void:
	if play:
		enemy.move_animation_player.play("move")
	else:
		enemy.move_animation_player.play("RESET")
