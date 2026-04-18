class_name PlayerLookSelectUI
extends Control


signal player_look_selected(index: int)

const PLAYER_LOOK_ITEM = preload("uid://061gn8pmi477")

@onready var items_container: HBoxContainer = %ItemsContainer
@onready var confirm_button: Button = %ConfirmButton


func _ready() -> void:
	confirm_button.pressed.connect(_on_confirm_button_pressed)
	var btns: Array[Button] = [confirm_button]
	SoundManager.register_hover(btns)
	SoundManager.register_click(btns)
	GameEvents.player_look_changed.connect(_on_player_look_changed)
	for i in range(4):
		var item: PlayerLookItem = PLAYER_LOOK_ITEM.instantiate()
		item.player_look_index = i
		item.player_look_selected.connect(_on_player_look_selected)
		item.name = "Item%s" % i
		items_container.add_child(item)


func _on_player_look_selected(index: int) -> void:
	player_look_selected.emit(index)


func _on_player_look_changed(peer_id: int, index: int) -> void:
	if multiplayer.get_unique_id() != peer_id:
		return
	print("[peer %s] select ui %s change look to %s" % [
		multiplayer.get_unique_id(),
		peer_id,
		index,
	])
	for item in items_container.get_children():
		if item is PlayerLookItem:
			item.set_selected(item.player_look_index == index)


func _on_confirm_button_pressed() -> void:
	visible = false
