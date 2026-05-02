class_name EnemySpawnComponent
extends Node

signal round_changed(round_count: int)
signal round_completed
signal max_round_end

const ENEMYS = [
	[preload("uid://c5v88ha30yaov"), 0.5],
	[preload("uid://pu2c45uixpy0"), 0.5],
]

const BASE_ROUND_TIME: float = 10
const ROUND_TIME_GROWTH: float = 5
const BASE_MIN_SPAWN_INTERVAL: float = 2.0
const BASE_MAX_SPAWN_INTERVAL: float = 5.0
const SPAWN_INTERVAL_GROWTH: float = -0.1
const MAX_ROUND: int = 10

@export var spawn_root: Node2D
@export var spawn_rect: ReferenceRect
@export var uprade_component: UpgradeComponent
@export var multiplayer_spawner: MultiplayerSpawner

var round_count: int = 0:
	get:
		return round_count
	set(value):
		round_count = value
		round_changed.emit(value)
var round_min_spawn_interval: float = BASE_MIN_SPAWN_INTERVAL
var round_max_spawn_interval: float = BASE_MAX_SPAWN_INTERVAL
var enemy_count: int = 0

@onready var spawn_timer: Timer = $SpawnTimer
@onready var round_timer: Timer = $RoundTimer

func _ready() -> void:
	for config in ENEMYS:
		var packed_scene: PackedScene = config[0]
		multiplayer_spawner.add_spawnable_scene(packed_scene.resource_path)
	if is_multiplayer_authority():
		spawn_timer.timeout.connect(_on_spawn_timer_timeout)
		round_timer.timeout.connect(_on_round_timer_timeout)
		GameEvents.enemy_died.connect(_on_enemy_died)
		uprade_component.upgrade_finished.connect(_on_upgrade_finished)


func start() -> void:
	if is_multiplayer_authority():
		_start_round()


func _start_round() -> void:
	round_count += 1
	print("Round %s start" % round_count)
	round_min_spawn_interval = BASE_MIN_SPAWN_INTERVAL + (round_count - 1) * SPAWN_INTERVAL_GROWTH
	round_max_spawn_interval = BASE_MAX_SPAWN_INTERVAL + (round_count - 1) * SPAWN_INTERVAL_GROWTH
	round_min_spawn_interval = clamp(round_min_spawn_interval, 0, round_min_spawn_interval)
	round_max_spawn_interval = clamp(round_max_spawn_interval, round_min_spawn_interval, BASE_MAX_SPAWN_INTERVAL)
	round_timer.start(BASE_ROUND_TIME + (round_count - 1) * ROUND_TIME_GROWTH)
	spawn_timer.start(randf_range(round_min_spawn_interval, round_max_spawn_interval))
	synchronize()


func _check_round_completed() -> void:
	if !round_timer.is_stopped():
		return
	if enemy_count == 0:
		print("Round %s completed!" % round_count)
		if round_count < MAX_ROUND:
			round_completed.emit()
		else:
			await get_tree().create_timer(1.0).timeout
			max_round_end.emit()
		#_start_round()


func _get_random_position() -> Vector2:
	var pos := Vector2(
		randf_range(0, spawn_rect.size.x),
		randf_range(0, spawn_rect.size.y),
	)
	pos += spawn_rect.global_position
	return pos


func get_round_time_left() -> float:
	return round_timer.time_left


func synchronize(peer_id: int = -1) -> void:
	if not is_multiplayer_authority():
		return
	var data = {
		"round_count": round_count,
		"round_timer_time_left": round_timer.time_left,
		"round_timer_running": not round_timer.is_stopped()
	}
	if peer_id < 0:
		_synchronize.rpc(data)
	elif peer_id > 1:
		_synchronize.rpc_id(peer_id, data)


@rpc("authority", "call_remote", "reliable")
func _synchronize(data: Dictionary) -> void:
	round_count = data.round_count
	var wait_time: float = data.round_timer_time_left
	if wait_time > 0:
		round_timer.wait_time = wait_time
	if data.round_timer_running:
		round_timer.start()


func _spawn_one_enemy() -> void:
	# 随机概率
	var rand := randf()
	var config_rate := 0.0
	var enemy_scene: PackedScene = null
	for config in ENEMYS:
		config_rate += config[1]
		if rand <= config_rate:
			enemy_scene = config[0]
			break
	if enemy_scene == null:
		enemy_scene = ENEMYS.back()[0]
	var enemy := enemy_scene.instantiate() as Node2D
	#print("[peer %s] enemy spawn pos: %s" % [multiplayer.get_unique_id(), enemy.global_position])
	spawn_root.add_child(enemy, true)
	enemy.global_position = _get_random_position()
	enemy_count += 1


func _spawn_enemy() -> void:
	var peers := Tools.get_game_peers_count()
	var multi_enemy_rate := randf_range(0.0, 0.1 * peers + 0.05 * round_count)
	var is_multi_enemy_spawn := randf() < multi_enemy_rate
	var spawn_count := randi_range(peers, int((peers + round_count * peers))) if is_multi_enemy_spawn else 1
	#var max_enemy_count := round_count * peers * 3
	for i in spawn_count:
		_spawn_one_enemy()
	spawn_timer.start(randf_range(round_min_spawn_interval, round_max_spawn_interval))


func _on_spawn_timer_timeout() -> void:
	_spawn_enemy()


func _on_round_timer_timeout() -> void:
	print("Round %s end" % round_count)
	spawn_timer.stop()
	_check_round_completed()


func _on_enemy_died() -> void:
	enemy_count -= 1
	_check_round_completed()


func _on_upgrade_finished() -> void:
	_start_round()
