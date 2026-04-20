class_name GameWinUI
extends Control


var tween: Tween

@onready var label: Label = $Label

# TODO 随机文本
func _ready() -> void:
	visibility_changed.connect(_on_visibility_changed)


func _on_visibility_changed() -> void:
	if visible:
		if is_instance_valid(tween) and tween.is_valid():
			tween.kill()
		tween = create_tween()
		tween.set_loops(20)
		tween.tween_property(label, "rotation_degrees", -18.0, 0.2)
		tween.tween_property(label, "rotation_degrees", -12.0, 0.4)
		tween.tween_property(label, "scale", Vector2.ONE * 1.3, 0.1)
		tween.tween_property(label, "scale", Vector2.ONE, 0.1)
		tween.tween_interval(0.5)
	else:
		if is_instance_valid(tween) and tween.is_valid():
			tween.kill()
