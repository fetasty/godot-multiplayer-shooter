class_name HitboxComponent
extends Area2D

signal hit(hurtbox: HurtboxComponent)

var damage: float = 1
var is_single_hit: bool = false
var hit_count: int = 0

func _ready() -> void:
	if not is_multiplayer_authority():
		process_mode = Node.PROCESS_MODE_DISABLED


func register_hit(hurtbox: HurtboxComponent) -> void:
	hit_count += 1
	hit.emit(hurtbox)
