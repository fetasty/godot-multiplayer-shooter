class_name Main
extends Node

const PLAYER = preload("uid://dgstmloeo60yy")
const ENEMY = preload("uid://pu2c45uixpy0")
const MAIN_MENU = preload("uid://dkve68vq7kmiw")

static var background_effect: Node
static var background_effect_clip: Node

var player_dict: Dictionary[int, Player] = {}
var died_peers: Array[int] = []

@onready var multiplayer_spawner: MultiplayerSpawner = %MultiplayerSpawner
@onready var player_spawn_marker: Marker2D = $PlayerSpawnMarker
@onready var enemy_spawn_component: EnemySpawnComponent = $EnemySpawnComponent
@onready var _background_effect: Node2D = $BackgroundEffect
@onready var _background_effect_clip: Sprite2D = %BackgroundEffectClip



func _ready() -> void:
	background_effect = _background_effect
	background_effect_clip = _background_effect_clip
	multiplayer_spawner.spawn_function = func(data):
		print("[peer %s] Spawn player: %s, pos: %s" % [multiplayer.get_unique_id(), data.peer_id, player_spawn_marker.global_position])
		var player = PLAYER.instantiate() as Player
		player.name = "Player%s" % [data.peer_id]
		player.input_peer_id = data.peer_id
		player.global_position = player_spawn_marker.global_position
		player.input_display_name = data.display_name
		if is_multiplayer_authority():
			player.died.connect(_on_player_died.bind(data.peer_id))
			player_dict[data.peer_id] = player
		return player
	if is_multiplayer_authority():
		enemy_spawn_component.round_completed.connect(_on_round_completed)
		multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	else:
		multiplayer.server_disconnected.connect(_on_server_disconnected)
	_peer_ready.rpc_id(1, { "display_name": MultiplayerConfig.display_name })


@rpc("any_peer", "call_local", "reliable")
func _peer_ready(player_data: Dictionary) -> void:
	var sender_id := multiplayer.get_remote_sender_id()
	multiplayer_spawner.spawn({ "peer_id": sender_id, "display_name": player_data.display_name })
	enemy_spawn_component.synchronize(sender_id)


func _end_game() -> void:
	multiplayer.multiplayer_peer = OfflineMultiplayerPeer.new()
	get_tree().change_scene_to_file("res://ui/menu/main_menu.tscn")


func _check_game_over() -> void:
	# multiplayer.get_peers 返回所有已连接的peer,不包含自身
	var all_peers := multiplayer.get_peers()
	all_peers.append(multiplayer.get_unique_id())
	var is_game_over := true
	for peer_id in all_peers:
		if not died_peers.has(peer_id):
			is_game_over = false
			break
	if is_game_over:
		_end_game()


func _on_player_died(peer_id: int) -> void:
	died_peers.append(peer_id)
	_check_game_over()


func _on_round_completed() -> void:
	for peer_id in died_peers:
		var player := player_dict[peer_id]
		player.revive(player_spawn_marker.global_position)
	died_peers.clear()


func _on_server_disconnected() -> void:
	_end_game()


func _on_peer_disconnected(peer_id: int) -> void:
	print("[peer %s] on peer %s disconnected!" % [multiplayer.get_unique_id(), peer_id])
	player_dict[peer_id].queue_free()
	player_dict.erase(peer_id)
	if peer_id in died_peers:
		died_peers.erase(peer_id)
	_check_game_over()
