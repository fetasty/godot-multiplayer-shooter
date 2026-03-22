class_name State
extends Node

@warning_ignore("unused_signal")
signal transitioned(next: String)

## 当进入状态时调用
func enter() -> void:
	pass


## 该状态的更新调用
func update() -> void:
	pass


# 退出状态时调用
func exit() -> void:
	pass
