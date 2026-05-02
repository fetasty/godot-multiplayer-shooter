class_name PlayerDetectComponent
extends Area2D

var detected_players: Array[Player] = []


func _ready() -> void:
	area_entered.connect(_on_area_entered)
	area_exited.connect(_on_area_exited)


func _on_area_entered(area: Area2D) -> void:
	if area.owner is not Player:
		return
	var player: Player = area.owner
	if player not in detected_players:
		detected_players.append(player)


func _on_area_exited(area: Area2D) -> void:
	if area.owner is not Player:
		return
	var player: Player = area.owner
	if player in detected_players:
		detected_players.erase(player)
