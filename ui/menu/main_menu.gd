class_name MainMenu
extends Control

const MAIN = preload("uid://yubvfldj7w73")
const OPTION_MENU = preload("uid://g2x3v6dbpxfa")



@onready var MULTIPLAYER_MENU = load("uid://bscefedv8fyhc")
@onready var ONLINE_GAME_MENU = load("uid://vbp8gv45a5mu")

@onready var single_player_button: Button = $VBoxContainer/SinglePlayerButton
@onready var multiplayer_button: Button = $VBoxContainer/MultiplayerButton
@onready var options_button: Button = $VBoxContainer/OptionsButton
@onready var quit_button: Button = $VBoxContainer/QuitButton
@onready var online_game_button: Button = $VBoxContainer/OnlineGameButton
@onready var language_button: Button = $LanguageButton


func _ready() -> void:
	if Tools.is_headless_server():
		await get_tree().create_timer(1.0).timeout
		_start_headless_server()
		return
	multiplayer.multiplayer_peer = OfflineMultiplayerPeer.new()
	single_player_button.pressed.connect(_on_single_player_button_pressed)
	multiplayer_button.pressed.connect(_on_multiplayer_button_pressed)
	quit_button.pressed.connect(_on_quit_button_pressed)
	options_button.pressed.connect(_on_options_button_pressed)
	online_game_button.pressed.connect(_on_online_game_button_pressed)
	language_button.pressed.connect(_on_language_button_pressed)
	var btns: Array[Button] = [
		single_player_button,
		multiplayer_button,
		options_button,
		quit_button,
		online_game_button,
		language_button,
	]
	SoundManager.register_hover(btns)
	SoundManager.register_click(btns)


func _start_headless_server() -> void:
	if multiplayer.multiplayer_peer is not ENetMultiplayerPeer:
		var server_peer := ENetMultiplayerPeer.new()
		if MultiplayerConfig.host_ip != "*":
			server_peer.set_bind_ip(MultiplayerConfig.host_ip)
		var err := server_peer.create_server(MultiplayerConfig.host_port)
		if err != OK:
			push_error("Error",
				"Creating server error: %s" % [error_string(err)])
			get_tree().quit(1)
		multiplayer.multiplayer_peer = server_peer
	get_tree().change_scene_to_packed(MAIN)


func _on_single_player_button_pressed() -> void:
	get_tree().change_scene_to_packed(MAIN)


func _on_multiplayer_button_pressed() -> void:
	get_tree().change_scene_to_packed(MULTIPLAYER_MENU)


func _on_quit_button_pressed() -> void:
	get_tree().quit()


func _on_options_button_pressed() -> void:
	add_child(OPTION_MENU.instantiate())


func _on_online_game_button_pressed() -> void:
	get_tree().change_scene_to_packed(ONLINE_GAME_MENU)


func _on_language_button_pressed() -> void:
	var current_locale := TranslationServer.get_locale()
	match current_locale:
		"zh_CN":
			TranslationServer.set_locale("en_US")
		_:
			TranslationServer.set_locale("zh_CN")
	# Godot 会自动通知所有 UI 控件更新文本，无需重启场景
