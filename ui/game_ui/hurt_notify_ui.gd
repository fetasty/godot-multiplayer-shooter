class_name HurtNotifyUI
extends ColorRect

var tween: Tween


func play_hurt_notify() -> void:
	if is_instance_valid(tween) and tween.is_valid():
		tween.kill()
	tween = create_tween()
	tween.tween_property(material, "shader_parameter/intensity", 1.0, 0.1)
	tween.tween_property(material, "shader_parameter/intensity", 0.0, 0.2)
