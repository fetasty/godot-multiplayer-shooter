class_name HitboxComponent
extends Area2D

signal hit(hurtbox: HurtboxComponent)

var damage: int = 1


func _ready() -> void:
	if not is_multiplayer_authority():
		process_mode = Node.PROCESS_MODE_DISABLED


func register_hit(hurtbox: HurtboxComponent) -> void:
	hit.emit(hurtbox)
