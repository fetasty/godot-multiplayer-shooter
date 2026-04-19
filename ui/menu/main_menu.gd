class_name MainMenu
extends Control

const MAIN = preload("uid://yubvfldj7w73")
const OPTION_MENU = preload("uid://g2x3v6dbpxfa")


@onready var MULTIPLAYER_MENU = load("uid://bscefedv8fyhc")
@onready var single_player_button: Button = $VBoxContainer/SinglePlayerButton
@onready var multiplayer_button: Button = $VBoxContainer/MultiplayerButton
@onready var options_button: Button = $VBoxContainer/OptionsButton
@onready var quit_button: Button = $VBoxContainer/QuitButton

const CURSOR = preload("uid://bf4bnwundf36w")


func _ready() -> void:
	Input.set_custom_mouse_cursor(CURSOR)
	multiplayer.multiplayer_peer = OfflineMultiplayerPeer.new()
	single_player_button.pressed.connect(_on_single_player_button_pressed)
	multiplayer_button.pressed.connect(_on_multiplayer_button_pressed)
	quit_button.pressed.connect(_on_quit_button_pressed)
	options_button.pressed.connect(_on_options_button_pressed)
	var btns: Array[Button] = [
		single_player_button,
		multiplayer_button,
		options_button,
		quit_button
	]
	SoundManager.register_hover(btns)
	SoundManager.register_click(btns)


func _on_single_player_button_pressed() -> void:
	get_tree().change_scene_to_packed(MAIN)


func _on_multiplayer_button_pressed() -> void:
	get_tree().change_scene_to_packed(MULTIPLAYER_MENU)


func _on_quit_button_pressed() -> void:
	get_tree().quit()


func _on_options_button_pressed() -> void:
	add_child(OPTION_MENU.instantiate())
