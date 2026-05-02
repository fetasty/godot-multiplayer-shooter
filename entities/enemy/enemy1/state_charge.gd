extends State

## Enemy进入充能攻击状态

var enemy: Enemy1

func enter() -> void:
	enemy = owner
	# 显示/动画在所有peer展示
	enemy.show_charge_tip()
	# 逻辑相关仅服务器执行
	if is_multiplayer_authority():
		enemy.charge_timer.start()


func update() -> void:
	# 物理/逻辑相关仅服务器执行
	if is_multiplayer_authority():
		enemy.velocity_down()
		if enemy.charge_timer.is_stopped():
			transitioned.emit("attack")


func exit() -> void:
	enemy.hide_charge_tip()
