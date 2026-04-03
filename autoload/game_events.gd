extends Node

signal enemy_died
signal local_player_health_changed(rate)


func emit_enemy_died() -> void:
	enemy_died.emit()


func emit_local_player_health_changed(rate: float) -> void:
	local_player_health_changed.emit(rate)
