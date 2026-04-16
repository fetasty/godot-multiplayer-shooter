extends Control

const MAIN_MENU = preload("uid://dkve68vq7kmiw")

@onready var title_label: Label = %TitleLabel
@onready var msg_label: Label = %MsgLabel
@onready var back_button: Button = %BackButton


func _ready() -> void:
	title_label.text = "Congratulations!" if GameState.game_win else "Try Again"
	msg_label.text = "Game Win ~" if GameState.game_win else "Game Lost!"
	back_button.pressed.connect(_on_back_button_pressed)
	var btns: Array[Button] = [
		back_button,
	]
	SoundManager.register_hover(btns)
	SoundManager.register_click(btns)


func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file("res://ui/menu/main_menu.tscn")
