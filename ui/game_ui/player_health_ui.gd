extends Control


@onready var player_name_label: Label = %PlayerNameLabel
@onready var health_bar: ProgressBar = %HealthBar
@onready var player_sprite: Sprite2D = %PlayerSprite


func _ready() -> void:
	GameEvents.local_player_health_changed.connect(_on_local_player_health_changed)
	GameEvents.player_look_changed.connect(_on_player_look_changed)
	if multiplayer.multiplayer_peer is OfflineMultiplayerPeer:
		player_name_label.text = "Player"
	else:
		player_name_label.text = MultiplayerConfig.display_name
	health_bar.value = 1.0


func _on_local_player_health_changed(rate: float) -> void:
	health_bar.value = rate


func _on_player_look_changed(peer_id: int, index: int) -> void:
	if not multiplayer.get_unique_id() == peer_id:
		return
	player_sprite.frame = index
