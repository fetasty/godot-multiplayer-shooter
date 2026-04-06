class_name ReadyStateUI
extends Control


@export var lobby_component: LobbyComponent

@onready var ready_label: Label = %ReadyLabel
@onready var not_ready_container: HBoxContainer = %NotReadyContainer
@onready var ready_button: Button = %ReadyButton
@onready var ready_status_label: Label = %ReadyStatusLabel


func _ready() -> void:
	ready_label.visible = false
	ready_button.pressed.connect(_on_ready_button_pressed)
	lobby_component.ready_peers_changed.connect(_on_ready_peers_changed)
	lobby_component.self_ready_state_changed.connect(_on_self_ready_state_changed)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ready"):
		lobby_component.request_peer_ready()


func _on_ready_button_pressed() -> void:
	lobby_component.request_peer_ready()


func _on_ready_peers_changed(ready_count: int, total_count: int) -> void:
	ready_status_label.text = "%s/%s READY" % [ready_count, total_count]


func _on_self_ready_state_changed(peer_ready: bool) -> void:
	ready_label.visible = peer_ready
	not_ready_container.visible = not peer_ready
