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
	_init_with_resource()


func _init_with_resource() -> void:
	title_label.text = resource.option
	description_label.text = resource.description


func _on_select_button_pressed() -> void:
	upgrade_selected.emit(index)
