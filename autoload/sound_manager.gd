extends Node

const BTN_HOVER = preload("uid://die14160gs36b")
const BTN_CLICK = preload("uid://2ndgxpoiedc")
const BTN_SELECT = preload("uid://ch7aw32nyqs4b")

@onready var hover_audio_stream_player: AudioStreamPlayer = $HoverAudioStreamPlayer
@onready var click_audio_stream_player: AudioStreamPlayer = $ClickAudioStreamPlayer
@onready var select_audio_stream_player: AudioStreamPlayer = $SelectAudioStreamPlayer


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


func _on_play_hover_sfx() -> void:
	play_hover()


func _on_play_click_sfx() -> void:
	play_click()


func _on_play_select_sfx() -> void:
	play_select()
