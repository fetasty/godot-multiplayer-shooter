class_name StateMachine
extends Node

signal state_changed(old: String, new: String)

@export var initial_state: String

# 当前状态, 空字符串表示没有状态
var current_state: String = String():
	get:
		return current_state
	set(value):
		_state_transition(value)

var states: Dictionary[String,State] = {}

func _ready() -> void:
	for child in get_children():
		if child is State:
			states[child.name.to_lower()] = child
			child.transitioned.connect(_on_state_transition)
	if initial_state:
		_state_transition(initial_state)


func _process(_delta: float) -> void:
	if current_state:
		states[current_state].update()


func _state_transition(next: String) -> void:
	if next not in states:
		push_error("Transition to a non-exists state: %s" % next)
		return
	if current_state == next:
		push_error("Transition to a same state: %s" % next)
		return
	if current_state in states:
		states[current_state].exit()
	var old_state = current_state
	current_state = next
	states[current_state].enter()
	state_changed.emit(old_state, current_state)


func _on_state_transition(next: String) -> void:
	current_state = next
