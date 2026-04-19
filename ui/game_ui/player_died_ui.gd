class_name PlayerDiedUI
extends Control

var tween: Tween

@onready var tip_label: Label = $TipLabel

func show_died_tip() -> void:
	# TODO 随机提示语
	modulate.a = 0.0
	if is_instance_valid(tween) and tween.is_valid():
		tween.kill()
	tween = create_tween()
	tween.tween_property(self, "modulate", Color.WHITE, 0.5)
	tween.tween_interval(3.0)
	tween.tween_property(self, "modulate", Color.TRANSPARENT, 0.2)
