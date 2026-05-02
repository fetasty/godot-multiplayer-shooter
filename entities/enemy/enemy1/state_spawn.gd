extends State

## Enemy的生成状态,播放生成动画,不进行追踪和攻击

var enemy: Enemy1

func enter() -> void:
	enemy = owner
	enemy.play_spawn_animation()
	if is_multiplayer_authority():
		enemy.velocity = Vector2.ZERO


func exit() -> void:
	if is_multiplayer_authority():
		enemy.hurt_collision_shape_2d.disabled = false
