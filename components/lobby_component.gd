class_name LobbyComponent
extends Node

signal self_ready_state_changed(peer_ready: bool)
signal ready_peers_changed(ready_count: int, total_count: int)
signal all_peers_ready_checked


var ready_peers: Array[int] = []
var lobby_closed: bool = false


func _ready() -> void:
	if is_multiplayer_authority():
		multiplayer.peer_connected.connect(_on_peer_connected)
		multiplayer.peer_disconnected.connect(_on_peer_disconnected)
		ready_peers_changed.emit.call_deferred(ready_peers.size(), _total_peer_count())
	else:
		_request_ready_peers_status.rpc_id(1)


func request_peer_ready() -> void:
	_request_peer_ready.rpc_id(1)


func close_lobby() -> void:
	lobby_closed = true


func _check_all_peer_ready() -> void:
	if not is_multiplayer_authority() or lobby_closed:
		return
	if ready_peers.size() == _total_peer_count():
		_emit_all_peers_ready_checked.rpc()


@rpc("any_peer", "call_local", "reliable")
func _request_peer_ready() -> void:
	if not is_multiplayer_authority():
		return
	_try_append_ready_peer(multiplayer.get_remote_sender_id())


func _try_append_ready_peer(peer_id: int) -> void:
	if peer_id not in ready_peers:
		ready_peers.append(peer_id)
		_emit_self_ready_changed.rpc_id(peer_id, true)
		_emit_ready_peers_changed.rpc(ready_peers.size(), _total_peer_count())
		_check_all_peer_ready()


func _try_erase_ready_peer(peer_id: int) -> void:
	if peer_id in ready_peers:
		ready_peers.erase(peer_id)
	else:
		_check_all_peer_ready()


@rpc("any_peer", "call_remote", "reliable")
func _request_ready_peers_status() -> void:
	if not is_multiplayer_authority():
		return
	var sender_id := multiplayer.get_remote_sender_id()
	_emit_ready_peers_changed.rpc_id(sender_id, ready_peers.size(), _total_peer_count())
	if lobby_closed:
		_emit_all_peers_ready_checked.rpc_id(sender_id)


@rpc("authority", "call_local", "reliable")
func _emit_self_ready_changed(peer_ready: bool) -> void:
	self_ready_state_changed.emit(peer_ready)


@rpc("authority", "call_local", "reliable")
func _emit_ready_peers_changed(ready_count: int, total_count: int) -> void:
	ready_peers_changed.emit(ready_count, total_count)


@rpc("authority", "call_local", "reliable")
func _emit_all_peers_ready_checked() -> void:
	all_peers_ready_checked.emit()


func _total_peer_count() -> int:
	return multiplayer.get_peers().size() + 1


func _on_peer_connected(_peer_id: int) -> void:
	_emit_ready_peers_changed.rpc(ready_peers.size(), _total_peer_count())


func _on_peer_disconnected(peer_id: int) -> void:
	_try_erase_ready_peer(peer_id)
	_emit_ready_peers_changed.rpc(ready_peers.size(), _total_peer_count())
