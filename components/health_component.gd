class_name HealthComponent
extends Node

signal health_changed(max_value: int, current_value: int)
signal health_depleted

@export var max_health: int = 3

var current_health: int = max_health


func take_damage(damage: int) -> void:
	current_health = clamp(current_health - damage, 0, max_health)
	health_changed.emit(max_health, current_health)
	if current_health == 0:
		health_depleted.emit()


func reset() -> void:
	current_health = max_health
	health_changed.emit(max_health, current_health)
