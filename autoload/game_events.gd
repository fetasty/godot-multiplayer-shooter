extends Node

signal enemy_died
signal local_player_health_changed(rate)
signal player_look_changed(peer_id: int, player_look_index: int)


func emit_enemy_died() -> void:
	enemy_died.emit()


func emit_local_player_health_changed(rate: float) -> void:
	local_player_health_changed.emit(rate)


func emit_player_look_changed(peer_id: int, player_look_index: int):
	player_look_changed.emit(peer_id, player_look_index)
