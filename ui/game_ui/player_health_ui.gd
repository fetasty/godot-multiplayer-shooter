extends Control


@onready var player_name_label: Label = %PlayerNameLabel
@onready var health_bar: ProgressBar = %HealthBar


func _ready() -> void:
	GameEvents.local_player_health_changed.connect(_on_local_player_health_changed)
	if multiplayer.multiplayer_peer is OfflineMultiplayerPeer:
		player_name_label.visible = false
	else:
		player_name_label.text = MultiplayerConfig.display_name
	health_bar.value = 1.0


func _on_local_player_health_changed(rate: float) -> void:
	health_bar.value = rate
