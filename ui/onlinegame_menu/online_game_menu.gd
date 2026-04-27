class_name OnlineGameMenu
extends Control

const MAIN = preload("uid://yubvfldj7w73")
const CONFIRM_DIALOG = preload("uid://ch32vetv5hls8")


var is_connecting: bool = false

@onready var MAIN_MENU = load("uid://dkve68vq7kmiw")
@onready var player_name_text_edit: TextEdit = %PlayerNameTextEdit
@onready var server_ip_text_edit: TextEdit = %ServerIPTextEdit
@onready var server_port_text_edit: TextEdit = %ServerPortTextEdit
@onready var join_button: Button = %JoinButton
@onready var back_button: Button = %BackButton


func _ready() -> void:
	# random name
	MultiplayerConfig.display_name = RandomUsernameGenerator.generate_username()
	player_name_text_edit.text = MultiplayerConfig.display_name
	server_ip_text_edit.text = MultiplayerConfig.server_ip
	server_port_text_edit.text = str(MultiplayerConfig.server_port)
	join_button.pressed.connect(_on_join_button_pressed)
	back_button.pressed.connect(_on_back_button_pressed)
	var btns: Array[Button] = [
		join_button,
		back_button,
	]
	SoundManager.register_hover(btns)
	SoundManager.register_click(btns)
	multiplayer.connected_to_server.connect(_on_connected_to_server)
	multiplayer.connection_failed.connect(_on_connection_failed)
	player_name_text_edit.text_changed.connect(_on_text_changed)
	server_ip_text_edit.text_changed.connect(_on_text_changed)
	server_port_text_edit.text_changed.connect(_on_text_changed)
	_validate()


func _validate() -> void:
	MultiplayerConfig.display_name = player_name_text_edit.text.strip_edges()
	MultiplayerConfig.server_ip = server_ip_text_edit.text
	var is_player_name_valid := not MultiplayerConfig.display_name.is_empty()
	var is_join_ip_valid := MultiplayerConfig.server_ip.is_valid_ip_address()
	var is_join_port_valid := server_port_text_edit.text.is_valid_int()
	if is_join_port_valid:
		MultiplayerConfig.server_port = int(server_port_text_edit.text)
		if not (MultiplayerConfig.server_port > 0 and MultiplayerConfig.server_port < 65535):
			is_join_port_valid = false
	join_button.disabled = is_connecting or (not is_player_name_valid) or (not is_join_ip_valid) or (not is_join_port_valid)


func _show_error_dialog(title: String = "Error", msg: String = "") -> void:
	var dialog = CONFIRM_DIALOG.instantiate() as ConfirmDialog
	dialog.title = title
	dialog.message = msg
	dialog.confirmd.connect(func(): _validate(), ConnectFlags.CONNECT_ONE_SHOT)
	add_child(dialog)


func _on_text_changed() -> void:
	_validate()


func _on_join_button_pressed() -> void:
	var client_peer := ENetMultiplayerPeer.new()
	var err := client_peer.create_client(MultiplayerConfig.server_ip, MultiplayerConfig.server_port)
	if err != OK:
		_show_error_dialog(tr("ERROR_DIALOG_TITLE"),
			tr("CREATE_CLIENT_ERROR_MESSAGE") % [error_string(err)])
		return
	is_connecting = true
	multiplayer.multiplayer_peer = client_peer


func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_packed(MAIN_MENU)


func _on_connected_to_server() -> void:
	is_connecting = false
	get_tree().change_scene_to_packed(MAIN)


func _on_connection_failed() -> void:
	is_connecting = false
	_show_error_dialog(tr("ERROR_DIALOG_TITLE"), tr("CONNECTION_TO_SERVER_FAILED_MESSAGE"))
