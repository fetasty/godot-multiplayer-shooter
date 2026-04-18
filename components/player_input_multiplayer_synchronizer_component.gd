class_name PlayerInputMultiplayerSynchronizerComponent
extends MultiplayerSynchronizer

@export var aim_root : Node2D

var aim_vector : Vector2 = Vector2.RIGHT
var move_vector : Vector2 = Vector2.ZERO
var is_attack_pressing : bool

func _process(_delta: float) -> void:
	if is_multiplayer_authority():
		move_vector = Input.get_vector("move_left", "move_right", "move_up", "move_down")
		aim_vector = aim_root.global_position.direction_to(aim_root.get_global_mouse_position())


func _unhandled_input(event: InputEvent) -> void:
	if is_multiplayer_authority():
		if event.is_action_pressed("attack"):
			is_attack_pressing = true
		elif event.is_action_released("attack"):
			is_attack_pressing = false
