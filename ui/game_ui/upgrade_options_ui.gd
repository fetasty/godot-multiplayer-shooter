class_name UpgradeOptionsUI
extends Control

signal upgrade_selected(index: int)

const UPGRADE_OPTION_ITEM = preload("uid://bokjg66q10lcd")

var selected: bool = true
var tween: Tween

@onready var items_container: HBoxContainer = %ItemsContainer

func _ready() -> void:
	visible = false
	scale = Vector2.ZERO


func show_upgrade_options(resources: Array) -> void:
	for item in items_container.get_children():
		item.queue_free()
		items_container.remove_child(item)
	for index in resources.size():
		var item: UpgradeOptionItem = UPGRADE_OPTION_ITEM.instantiate()
		item.index = index
		item.resource = resources[index]
		item.upgrade_selected.connect(_on_item_selected)
		items_container.add_child(item)
	scale = Vector2.ZERO
	visible = true
	selected = false
	tween = create_tween()
	tween.tween_property(self, "scale", Vector2.ONE, 0.3)\
		.from(Vector2.ZERO)\
		.set_ease(Tween.EASE_OUT)\
		.set_trans(Tween.TRANS_BACK)


func _on_item_selected(index: int) -> void:
	if selected:
		return
	selected = true
	upgrade_selected.emit(index)
	if tween != null and tween.is_valid():
		tween.kill()
	tween = create_tween()
	tween.tween_property(self, "scale", Vector2.ZERO, 0.3)\
		.from(Vector2.ONE)\
		.set_ease(Tween.EASE_OUT)
