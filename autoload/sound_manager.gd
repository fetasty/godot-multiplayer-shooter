extends Node

const BTN_HOVER = preload("uid://die14160gs36b")
const BTN_CLICK = preload("uid://2ndgxpoiedc")
const BTN_SELECT = preload("uid://ch7aw32nyqs4b")
const GAME_FAILED_MUSIC = preload("uid://5fopxlwgbkqa")
const GAME_WIN_MUSIC = preload("uid://3uxgm2vppewk")



@onready var hover_audio_stream_player: AudioStreamPlayer = $HoverAudioStreamPlayer
@onready var click_audio_stream_player: AudioStreamPlayer = $ClickAudioStreamPlayer
@onready var select_audio_stream_player: AudioStreamPlayer = $SelectAudioStreamPlayer
@onready var hurt_audio_stream_player: AudioStreamPlayer = $HurtAudioStreamPlayer
@onready var died_audio_stream_player: AudioStreamPlayer = $DiedAudioStreamPlayer
@onready var music_audio_stream_player: AudioStreamPlayer = $MusicAudioStreamPlayer
@onready var game_end_audio_stream_player: AudioStreamPlayer = $GameEndAudioStreamPlayer
@onready var round_audio_stream_player: AudioStreamPlayer = $RoundAudioStreamPlayer
@onready var healing_audio_stream_player: AudioStreamPlayer = $HealingAudioStreamPlayer
@onready var enemy_died_audio_stream_player: AudioStreamPlayer = %EnemyDiedAudioStreamPlayer


func register_hover(btns: Array[Button]) -> void:
	for btn in btns:
		btn.mouse_entered.connect(_on_play_hover_sfx)


func register_click(btns: Array[Button]) -> void:
	for btn in btns:
		btn.pressed.connect(_on_play_click_sfx)


func register_select(btns: Array[Button]) -> void:
	for btn in btns:
		btn.pressed.connect(_on_play_select_sfx)


func play_hover() -> void:
	hover_audio_stream_player.play()


func play_click() -> void:
	click_audio_stream_player.play()


func play_select() -> void:
	select_audio_stream_player.play()


func play_hurt() -> void:
	hurt_audio_stream_player.play()


func play_player_died() -> void:
	died_audio_stream_player.play()


func play_round_win() -> void:
	round_audio_stream_player.play()


func play_game_end(win: bool) -> void:
	music_audio_stream_player.stop()
	game_end_audio_stream_player.stream = GAME_WIN_MUSIC if win else GAME_FAILED_MUSIC
	game_end_audio_stream_player.finished.connect(func():
		await get_tree().create_timer(3.0).timeout
		music_audio_stream_player.play()
	, CONNECT_ONE_SHOT)
	game_end_audio_stream_player.play()


func play_healing() -> void:
	healing_audio_stream_player.play()


func play_enemy_died() -> void:
	enemy_died_audio_stream_player.play()


func _on_play_hover_sfx() -> void:
	play_hover()


func _on_play_click_sfx() -> void:
	play_click()


func _on_play_select_sfx() -> void:
	play_select()
