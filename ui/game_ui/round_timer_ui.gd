extends Control

@export var enemy_spawn_component: EnemySpawnComponent

@onready var round_label: Label = %RoundLabel
@onready var timer_label: Label = %TimerLabel

func _ready() -> void:
	enemy_spawn_component.round_changed.connect(_on_round_changed)


func _process(_delta: float) -> void:
	var time_left := enemy_spawn_component.get_round_time_left()
	timer_label.text = str(ceili(time_left))


func _on_round_changed(round_count: int) -> void:
	round_label.text = "Round %s" % round_count
