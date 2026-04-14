class_name Bullet
extends Node2D


const SPEED: float = 600.0

var direction: Vector2
var damage: int

@onready var timer: Timer = $Timer
@onready var hitbox_component: HitboxComponent = $HitboxComponent


func _ready() -> void:
	if is_multiplayer_authority():
		timer.timeout.connect(_on_life_timer_timeout)
		hitbox_component.damage = damage
		hitbox_component.is_single_hit = true
		hitbox_component.hit.connect(_on_hit)
	else:
		timer.process_mode = Node.PROCESS_MODE_DISABLED


func _process(delta: float) -> void:
	global_position += direction * SPEED * delta


func _on_life_timer_timeout() -> void:
	queue_free()


func _on_hit(_hurtbox: HurtboxComponent) -> void:
	queue_free()
