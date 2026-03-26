class_name HurtboxComponent
extends Area2D

@export var health_component: HealthComponent


func _ready() -> void:
	if is_multiplayer_authority():
		area_entered.connect(_on_area_entered, CONNECT_DEFERRED)
	else:
		process_mode = Node.PROCESS_MODE_DISABLED


func take_damage(damage: int) -> void:
	health_component.take_damage(damage)


func _on_area_entered(area: Area2D) -> void:
	if not area is HitboxComponent:
		return
	var hitbox := area as HitboxComponent
	take_damage(hitbox.damage)
	hitbox.register_hit(self)
