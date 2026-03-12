class_name EnemySpawnComponent
extends Node

const ENEMY = preload("uid://pu2c45uixpy0")

@export var spawn_root: Node2D
@export var spawn_rect: ReferenceRect


@onready var spawn_timer: Timer = $SpawnTimer

func _ready() -> void:
	if is_multiplayer_authority():
		spawn_timer.timeout.connect(_on_spawn_timer_timeout)
	else:
		spawn_timer.process_mode = Node.PROCESS_MODE_DISABLED


func _get_random_position() -> Vector2:
	var pos := Vector2(
		randf_range(0, spawn_rect.size.x),
		randf_range(0, spawn_rect.size.y),
	)
	pos += spawn_rect.global_position
	return pos


func _on_spawn_timer_timeout() -> void:
	var enemy := ENEMY.instantiate() as Node2D
	enemy.global_position = _get_random_position()
	#print("[peer %s] enemy spawn pos: %s" % [multiplayer.get_unique_id(), enemy.global_position])
	spawn_root.add_child(enemy, true)
	spawn_timer.start(randf_range(1.0, 5.0))
