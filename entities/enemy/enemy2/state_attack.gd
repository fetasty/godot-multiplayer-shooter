extends State


## Enemy进入攻击状态, 原地爆炸, 检测碰撞, 尝试伤害玩家

var enemy: Enemy2
var origin_collision_layer: int
var origin_collision_mask: int

func enter() -> void:
	enemy = owner
	if is_multiplayer_authority():
		origin_collision_layer = enemy.collision_layer
		origin_collision_mask = enemy.collision_mask
		enemy.collision_layer = 0
		# 仅检测墙体碰撞
		enemy.collision_mask = (1 << 0)
		# 允许伤害玩家
		# enemy.hit_collision_shape_2d.disabled = false
		# 爆炸调用
		enemy.burst()
