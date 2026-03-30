extends Control

const MAIN = preload("uid://yubvfldj7w73")

var player_name: String
var host_ip: String
var host_port: int
var join_ip: String
var join_port: int

@onready var MAIN_MENU = load("uid://yubvfldj7w73")
@onready var player_name_text_edit: TextEdit = %PlayerNameTextEdit
@onready var host_ip_text_edit: TextEdit = %HostIPTextEdit
@onready var host_port_text_edit: TextEdit = %HostPortTextEdit
@onready var host_button: Button = %HostButton
@onready var join_ip_text_edit: TextEdit = %JoinIPTextEdit
@onready var join_port_text_edit: TextEdit = %JoinPortTextEdit
@onready var join_button: Button = %JoinButton
@onready var back_button: Button = %BackButton

func _ready() -> void:
	host_button.pressed.connect(_on_host_button_pressed)
	join_button.pressed.connect(_on_join_button_pressed)
	back_button.pressed.connect(_on_back_button_pressed)
	multiplayer.connected_to_server.connect(_on_connected_to_server)
	player_name_text_edit.text_changed.connect(_on_text_changed)
	host_ip_text_edit.text_changed.connect(_on_text_changed)
	host_port_text_edit.text_changed.connect(_on_text_changed)
	join_ip_text_edit.text_changed.connect(_on_text_changed)
	join_port_text_edit.text_changed.connect(_on_text_changed)
	_validate()


func _validate() -> void:
	player_name = player_name_text_edit.text.strip_edges()
	host_ip = host_ip_text_edit.text
	join_ip = join_ip_text_edit.text
	var is_player_name_valid := not player_name.is_empty()
	var is_host_ip_valid := host_ip.is_valid_ip_address() or host_ip == "*"
	var is_host_port_valid := host_port_text_edit.text.is_valid_int()
	var is_join_ip_valid := join_ip.is_valid_ip_address()
	var is_join_port_valid := join_port_text_edit.text.is_valid_int()
	if is_host_port_valid:
		host_port = int(host_port_text_edit.text)
		if not (host_port > 0 and host_port < 65535):
			is_host_port_valid = false
	if is_join_port_valid:
		join_port = int(join_port_text_edit.text)
		if not (join_port > 0 and join_port < 65535):
			is_join_port_valid = false
	host_button.disabled = (not is_player_name_valid) or (not is_host_ip_valid) or (not is_host_port_valid)
	join_button.disabled = (not is_player_name_valid) or (not is_join_ip_valid) or (not is_join_port_valid)


func _on_text_changed() -> void:
	_validate()


func _on_host_button_pressed() -> void:
	var server_peer := ENetMultiplayerPeer.new()
	if host_ip != "*":
		server_peer.set_bind_ip(host_ip)
	server_peer.create_server(host_port)
	multiplayer.multiplayer_peer = server_peer
	get_tree().change_scene_to_packed(MAIN)


func _on_join_button_pressed() -> void:
	var client_peer := ENetMultiplayerPeer.new()
	client_peer.create_client(join_ip, join_port)
	multiplayer.multiplayer_peer = client_peer


func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_packed(MAIN_MENU)


func _on_connected_to_server() -> void:
	get_tree().change_scene_to_packed(MAIN)
