class_name UpgradeOptionItem
extends PanelContainer

# 仅在各peer端独自实例化显示,不能执行rpc

signal upgrade_selected(index: int)

var index: int
var resource: UpgradeResource

@onready var select_button: Button = %SelectButton
@onready var title_label: Label = %TitleLabel
@onready var description_label: Label = %DescriptionLabel

func _ready() -> void:
	select_button.pressed.connect(_on_select_button_pressed)
	var btns: Array[Button] = [
		select_button,
	]
	SoundManager.register_hover(btns)
	SoundManager.register_select(btns)
	_init_with_resource()


func _init_with_resource() -> void:
	title_label.text = tr(resource.name_key)
	description_label.text = tr(resource.description_key)


func _on_select_button_pressed() -> void:
	upgrade_selected.emit(index)
