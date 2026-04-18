class_name PauseMenu
extends CanvasLayer

signal quit_requested

const OPTION_MENU = preload("uid://g2x3v6dbpxfa")

var current_pause_peer: int = -1

@onready var back_to_main_button: Button = %BackToMainButton
@onready var resume_button: Button = %ResumeButton
@onready var options_button: Button = %OptionsButton


func _ready() -> void:
	back_to_main_button.pressed.connect(_on_back_to_main_button_pressed)
	resume_button.pressed.connect(_on_resume_button_pressed)
	options_button.pressed.connect(_on_options_button_pressed)
	var btns: Array[Button] = [
		back_to_main_button,
		resume_button,
		options_button,
	]
	SoundManager.register_hover(btns)
	SoundManager.register_click(btns)
	if is_multiplayer_authority():
		multiplayer.peer_disconnected.connect(_on_peer_disconnected)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		if get_tree().paused:
			request_resume.rpc_id(1)
		else:
			request_pause.rpc_id(1)
		get_viewport().set_input_as_handled()


@rpc("any_peer", "call_local", "reliable")
func request_pause() -> void:
	if current_pause_peer != -1:
		return
	var sender_id := multiplayer.get_remote_sender_id()
	current_pause_peer = sender_id
	pause.rpc(sender_id)


@rpc("any_peer", "call_local", "reliable")
func request_resume() -> void:
	if current_pause_peer != multiplayer.get_remote_sender_id():
		return
	resume.rpc()


@rpc("authority", "call_local", "reliable")
func pause(pause_peer_id: int) -> void:
	current_pause_peer = pause_peer_id
	resume_button.disabled = pause_peer_id != multiplayer.get_unique_id()
	options_button.disabled = pause_peer_id != multiplayer.get_unique_id()
	get_tree().paused = true
	visible = true


@rpc("authority", "call_local", "reliable")
func resume() -> void:
	current_pause_peer = -1
	get_tree().paused = false
	visible = false


func _on_back_to_main_button_pressed() -> void:
	quit_requested.emit()


func _on_resume_button_pressed() -> void:
	request_resume.rpc_id(1)


func _on_peer_disconnected(peer_id: int) -> void:
	if current_pause_peer == peer_id:
		resume.rpc()


func _on_options_button_pressed() -> void:
	add_child(OPTION_MENU.instantiate())
