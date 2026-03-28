class_name GameCamera
extends Camera2D

static var instance: GameCamera

@export var noise: FastNoiseLite

var progress: float = 0.0
var sample_x: float = 0.0
var sample_y: float = 0.0
var sample_step: float = 400
var strength: float = 8
var progress_reduce_step: float = 5.0


func _ready() -> void:
	instance = self


func _process(delta: float) -> void:
	if is_zero_approx(progress):
		return
	sample_x += sample_step * delta
	sample_y += sample_step * delta
	offset = Vector2(
		noise.get_noise_2d(sample_x, 0.0),
		noise.get_noise_2d(0.0, sample_y)
	) * strength * progress * progress
	progress -= progress_reduce_step * delta
	progress = clamp(progress, 0.0, 1.0)


static func shake(shake_progress: float = 1.0) -> void:
	if not instance == null and is_instance_valid(instance):
		instance.progress = clamp(shake_progress, 0.0, 1.0)
