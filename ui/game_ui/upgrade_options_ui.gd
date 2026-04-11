class_name UpgradeOptionsUI
extends Control

signal upgrade_selected(index: int)

const UPGRADE_OPTION_ITEM = preload("uid://bokjg66q10lcd")

var selected: bool = true
var tween: Tween
var item_scale: Vector2:
	get:
		return item_scale
	set(value):
		item_scale = value
		for item in items_container.get_children():
			item.scale = value


@onready var items_container: HBoxContainer = %ItemsContainer

func _ready() -> void:
	visible = false


func show_upgrade_options(resources: Array) -> void:
	for item in items_container.get_children():
		item.queue_free()
		items_container.remove_child(item)
	for index in resources.size():
		var item: UpgradeOptionItem = UPGRADE_OPTION_ITEM.instantiate()
		item.index = index
		item.resource = resources[index]
		item.upgrade_selected.connect(_on_item_selected)
		item.scale = Vector2.ZERO
		items_container.add_child(item)
	visible = true
	selected = false
	items_container.process_mode = Node.PROCESS_MODE_DISABLED
	tween = create_tween()
	tween.tween_property(self, "item_scale", Vector2.ONE, 0.2)\
		.from(Vector2.ZERO)\
		.set_ease(Tween.EASE_OUT)\
		.set_trans(Tween.TRANS_BACK)
	await get_tree().create_timer(1).timeout
	items_container.process_mode = Node.PROCESS_MODE_INHERIT


func _on_item_selected(index: int) -> void:
	if selected:
		return
	selected = true
	items_container.process_mode = Node.PROCESS_MODE_DISABLED
	upgrade_selected.emit(index)
	if tween != null and tween.is_valid():
		tween.kill()
	tween = create_tween()
	tween.tween_property(self, "item_scale", Vector2.ZERO, 0.2)\
		.from(Vector2.ONE)\
		.set_ease(Tween.EASE_IN)\
		.set_trans(Tween.TRANS_BACK)
	tween.finished.connect(func(): visible = false)
