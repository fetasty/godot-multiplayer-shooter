class_name HealthComponent
extends Node

signal health_changed(max_value: int, current_value: int)
signal health_depleted

@export var max_health: int = 5

var current_health: int = max_health:
	get:
		return current_health
	set(value):
		if value != current_health:
			current_health = value
			health_changed.emit(max_health, current_health)


func _ready() -> void:
	if is_multiplayer_authority():
		current_health = max_health


func take_damage(damage: int) -> void:
	current_health = clamp(current_health - damage, 0, max_health)
	if current_health == 0:
		health_depleted.emit()


func reset(health: int = -1) -> void:
	if health < 0:
		current_health = max_health
	else:
		current_health = clamp(health, 1, max_health)
