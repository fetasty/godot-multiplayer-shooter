extends Control

const MAIN = preload("uid://yubvfldj7w73")
const CONFIRM_DIALOG = preload("uid://ch32vetv5hls8")


var is_connecting: bool = false

@onready var MAIN_MENU = load("uid://dkve68vq7kmiw")
@onready var player_name_text_edit: TextEdit = %PlayerNameTextEdit
@onready var host_ip_text_edit: TextEdit = %HostIPTextEdit
@onready var host_port_text_edit: TextEdit = %HostPortTextEdit
@onready var host_button: Button = %HostButton
@onready var join_ip_text_edit: TextEdit = %JoinIPTextEdit
@onready var join_port_text_edit: TextEdit = %JoinPortTextEdit
@onready var join_button: Button = %JoinButton
@onready var back_button: Button = %BackButton


func _ready() -> void:
	player_name_text_edit.text = MultiplayerConfig.display_name
	host_ip_text_edit.text = MultiplayerConfig.host_ip
	host_port_text_edit.text = str(MultiplayerConfig.host_port)
	join_ip_text_edit.text = MultiplayerConfig.join_ip
	join_port_text_edit.text = str(MultiplayerConfig.join_port)
	host_button.pressed.connect(_on_host_button_pressed)
	join_button.pressed.connect(_on_join_button_pressed)
	back_button.pressed.connect(_on_back_button_pressed)
	var btns: Array[Button] = [
		host_button,
		join_button,
		back_button,
	]
	SoundManager.register_hover(btns)
	SoundManager.register_click(btns)
	multiplayer.connected_to_server.connect(_on_connected_to_server)
	multiplayer.connection_failed.connect(_on_connection_failed)
	player_name_text_edit.text_changed.connect(_on_text_changed)
	host_ip_text_edit.text_changed.connect(_on_text_changed)
	host_port_text_edit.text_changed.connect(_on_text_changed)
	join_ip_text_edit.text_changed.connect(_on_text_changed)
	join_port_text_edit.text_changed.connect(_on_text_changed)
	_validate()


func _validate() -> void:
	MultiplayerConfig.display_name = player_name_text_edit.text.strip_edges()
	MultiplayerConfig.host_ip = host_ip_text_edit.text
	MultiplayerConfig.join_ip = join_ip_text_edit.text
	var is_player_name_valid := not MultiplayerConfig.display_name.is_empty()
	var is_host_ip_valid := MultiplayerConfig.host_ip.is_valid_ip_address() or MultiplayerConfig.host_ip == "*"
	var is_host_port_valid := host_port_text_edit.text.is_valid_int()
	var is_join_ip_valid := MultiplayerConfig.join_ip.is_valid_ip_address()
	var is_join_port_valid := join_port_text_edit.text.is_valid_int()
	if is_host_port_valid:
		MultiplayerConfig.host_port = int(host_port_text_edit.text)
		if not (MultiplayerConfig.host_port > 0 and MultiplayerConfig.host_port < 65535):
			is_host_port_valid = false
	if is_join_port_valid:
		MultiplayerConfig.join_port = int(join_port_text_edit.text)
		if not (MultiplayerConfig.join_port > 0 and MultiplayerConfig.join_port < 65535):
			is_join_port_valid = false
	host_button.disabled = is_connecting or (not is_player_name_valid) or (not is_host_ip_valid) or (not is_host_port_valid)
	join_button.disabled = is_connecting or (not is_player_name_valid) or (not is_join_ip_valid) or (not is_join_port_valid)


func _show_error_dialog(title: String = "Error", msg: String = "") -> void:
	var dialog = CONFIRM_DIALOG.instantiate() as ConfirmDialog
	dialog.title = title
	dialog.message = msg
	dialog.confirmd.connect(func(): _validate(), ConnectFlags.CONNECT_ONE_SHOT)
	add_child(dialog)


func _on_text_changed() -> void:
	_validate()


func _on_host_button_pressed() -> void:
	var server_peer := ENetMultiplayerPeer.new()
	if MultiplayerConfig.host_ip != "*":
		server_peer.set_bind_ip(MultiplayerConfig.host_ip)
	var err := server_peer.create_server(MultiplayerConfig.host_port)
	if err != OK:
		_show_error_dialog(tr("ERROR_DIALOG_TITLE"),
			tr("CREATE_SERVER_ERROR_MESSAGE") % [error_string(err)])
		return
	multiplayer.multiplayer_peer = server_peer
	get_tree().change_scene_to_packed(MAIN)


func _on_join_button_pressed() -> void:
	var client_peer := ENetMultiplayerPeer.new()
	var err := client_peer.create_client(MultiplayerConfig.join_ip, MultiplayerConfig.join_port)
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
