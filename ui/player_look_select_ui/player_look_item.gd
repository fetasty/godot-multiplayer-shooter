class_name PlayerLookItem
extends TextureRect

signal player_look_selected(index: int)

const PLAYER_LOOK_TEXTURES: Array = [
	preload("uid://dnrhxo7viwn0f"),
	preload("uid://cevbo8dl1aicm"),
	preload("uid://y6klcw3ep8s5"),
	preload("uid://ci740syg3etmn"),
]

@export var player_look_index: int = 0

@onready var select_box: NinePatchRect = %SelectBox
@onready var indicator: TextureRect = %Indicator


func _ready() -> void:
	texture = PLAYER_LOOK_TEXTURES[player_look_index]
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and \
		event.button_index == MouseButton.MOUSE_BUTTON_LEFT and \
		event.pressed and indicator.visible:
			get_viewport().set_input_as_handled()
			player_look_selected.emit(player_look_index)
			SoundManager.play_click()
			set_selected(true)


func set_selected(selected: bool) -> void:
	select_box.visible = selected


func _on_mouse_entered() -> void:
	indicator.visible = true
	SoundManager.play_hover()


func _on_mouse_exited() -> void:
	indicator.visible = false
