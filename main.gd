class_name Main
extends Node

const PLAYER = preload("uid://dgstmloeo60yy")
const ENEMY = preload("uid://pu2c45uixpy0")
const MAIN_MENU = preload("uid://dkve68vq7kmiw")
const GAME_END_MENU = preload("uid://b0vdjj5stvrav")

static var background_effect: Node
static var background_effect_clip: Node

var player_dict: Dictionary[int, Player] = {}
var died_peers: Array[int] = []

@onready var multiplayer_spawner: MultiplayerSpawner = %MultiplayerSpawner
@onready var player_spawn_marker: Marker2D = $PlayerSpawnMarker
@onready var enemy_spawn_component: EnemySpawnComponent = $EnemySpawnComponent
@onready var _background_effect: Node2D = $BackgroundEffect
@onready var _background_effect_clip: Sprite2D = %BackgroundEffectClip
@onready var pause_menu: PauseMenu = $PauseMenu
@onready var round_timer_ui: MarginContainer = %RoundTimerUI
@onready var ready_state_ui: ReadyStateUI = %ReadyStateUI
@onready var lobby_component: LobbyComponent = %LobbyComponent
@onready var enemy_died_audio_stream_player: AudioStreamPlayer = %EnemyDiedAudioStreamPlayer


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
	pause_menu.quit_requested.connect(_on_quit_requested)
	lobby_component.all_peers_ready_checked.connect(_on_all_peers_ready_checked)
	if is_multiplayer_authority():
		enemy_spawn_component.round_completed.connect(_on_round_completed)
		enemy_spawn_component.max_round_end.connect(_on_max_round_end)
		multiplayer.peer_disconnected.connect(_on_peer_disconnected)
		GameEvents.enemy_died.connect(_on_enemy_died)
	else:
		multiplayer.server_disconnected.connect(_on_server_disconnected)
	_create_player.rpc_id(1, { "display_name": MultiplayerConfig.display_name })
	var is_single_player := multiplayer.multiplayer_peer is OfflineMultiplayerPeer
	round_timer_ui.visible = is_single_player
	ready_state_ui.visible = not is_single_player
	if is_single_player:
		enemy_spawn_component.start()


@rpc("any_peer", "call_local", "reliable")
func _create_player(player_data: Dictionary) -> void:
	var sender_id := multiplayer.get_remote_sender_id()
	multiplayer_spawner.spawn({ "peer_id": sender_id, "display_name": player_data.display_name })
	enemy_spawn_component.synchronize(sender_id)


func _end_game() -> void:
	get_tree().paused = false
	multiplayer.multiplayer_peer = OfflineMultiplayerPeer.new()
	get_tree().change_scene_to_file("res://ui/menu/main_menu.tscn")


@rpc("authority", "call_local", "reliable")
func _game_completed(win: bool) -> void:
	GameState.game_win = win
	get_tree().paused = false
	multiplayer.multiplayer_peer = OfflineMultiplayerPeer.new()
	get_tree().change_scene_to_packed(GAME_END_MENU)


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
		_game_completed.rpc(false)


@rpc("authority", "call_local")
func _play_enemy_died_effects() -> void:
	enemy_died_audio_stream_player.play()


func _on_player_died(peer_id: int) -> void:
	died_peers.append(peer_id)
	_check_game_over()


func _on_round_completed() -> void:
	for peer_id in died_peers:
		var player := player_dict[peer_id]
		player.revive(player_spawn_marker.global_position)
	died_peers.clear()


func _on_max_round_end() -> void:
	_game_completed.rpc(true)


func _on_server_disconnected() -> void:
	_end_game()


func _on_peer_disconnected(peer_id: int) -> void:
	print("[peer %s] on peer %s disconnected!" % [multiplayer.get_unique_id(), peer_id])
	player_dict[peer_id].queue_free()
	player_dict.erase(peer_id)
	if peer_id in died_peers:
		died_peers.erase(peer_id)
	_check_game_over()


func _on_quit_requested() -> void:
	_end_game()


func _on_all_peers_ready_checked() -> void:
	round_timer_ui.visible = true
	ready_state_ui.visible = false
	if is_multiplayer_authority():
		lobby_component.close_lobby()
		enemy_spawn_component.start()


func _on_enemy_died() -> void:
	_play_enemy_died_effects.rpc()
