extends Control

const MAIN_MENU = preload("uid://dkve68vq7kmiw")

@onready var title_label: Label = %TitleLabel
@onready var msg_label: Label = %MsgLabel
@onready var back_button: Button = %BackButton


func _ready() -> void:
	if Tools.is_headless_server():
		get_tree().change_scene_to_file("res://ui/menu/main_menu.tscn")
		return
	title_label.text = tr("DEFAULT_GAME_WIN_TITLE") if GameState.game_win else tr("DEFAULT_GAME_FAILED_TITLE")
	msg_label.text = tr("DEFAULT_GAME_WIN_MESSAGE") if GameState.game_win else tr("DEFAULT_GAME_FAILED_MESSAGE")
	back_button.pressed.connect(_on_back_button_pressed)
	var btns: Array[Button] = [
		back_button,
	]
	SoundManager.register_hover(btns)
	SoundManager.register_click(btns)


func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file("res://ui/menu/main_menu.tscn")
