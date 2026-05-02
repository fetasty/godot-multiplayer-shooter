extends State


## Enemy进入攻击状态,冲撞玩家,可以造成伤害,攻击过程中不与其他Enemy碰撞

const ATTACK_SPEED: float = 600
const STOP_ATTACK_SPEED_SQUARED: float = 100

var enemy: Enemy1
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
		enemy.hit_collision_shape_2d.disabled = false
		# 初始攻击速度
		enemy.velocity = enemy.global_position.direction_to(enemy.track_target) * ATTACK_SPEED


func update() -> void:
	if is_multiplayer_authority():
		enemy.velocity_down()
		if enemy.velocity.length_squared() < STOP_ATTACK_SPEED_SQUARED:
			transitioned.emit("normal")


func exit() -> void:
	if is_multiplayer_authority():
		enemy.hit_collision_shape_2d.disabled = true
		enemy.collision_layer = origin_collision_layer
		enemy.collision_mask = origin_collision_mask
