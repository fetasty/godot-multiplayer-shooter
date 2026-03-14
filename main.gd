extends Node

const PLAYER = preload("uid://dgstmloeo60yy")
const ENEMY = preload("uid://pu2c45uixpy0")

@onready var multiplayer_spawner: MultiplayerSpawner = %MultiplayerSpawner
@onready var player_spawn_marker: Marker2D = $PlayerSpawnMarker

func _ready() -> void:
	multiplayer_spawner.spawn_function = func(data):
		print("[peer %s] Spawn player: %s, pos: %s" % [multiplayer.get_unique_id(), data.peer_id, player_spawn_marker.global_position])
		var player = PLAYER.instantiate() as Player
		player.name = "Player%s" % [data.peer_id]
		player.input_peer_id = data.peer_id
		player.global_position = player_spawn_marker.global_position
		return player
	_create_player.rpc_id(1)


@rpc("any_peer", "call_local", "reliable")
func _create_player() -> void:
	var sender_id := multiplayer.get_remote_sender_id()
	multiplayer_spawner.spawn({ "peer_id": sender_id })
