@tool
extends EditorPlugin

var res_parser: ResourceTranslationParser
var csv_parser: CSVConfigTranslationParser
#var json_parser: JsonTranslationParser

func _enter_tree():
	# 1. 注册菜单
	add_tool_menu_item("国际化：全量更新 POT 列表", _run_full_scan)
	# 2. 注册自定义解析器
	res_parser = preload("resource_translation_parser.gd").new()
	csv_parser = preload("csv_config_translation_parser.gd").new()
	#json_parser = preload("json_parser.gd").new()
	add_translation_parser_plugin(res_parser)
	add_translation_parser_plugin(csv_parser)
	#add_translation_parser_plugin(json_parser)


func _exit_tree():
	# 清理
	remove_tool_menu_item("国际化：全量更新 POT 列表")
	remove_translation_parser_plugin(res_parser)
	remove_translation_parser_plugin(csv_parser)
	#remove_translation_parser_plugin(json_parser)


func _run_full_scan():
	var extensions = ["gd", "tscn", "tres", "csv"]
	var files: PackedStringArray = []
	_scan_dir("res://", extensions, files)
	
	ProjectSettings.set_setting("internationalization/locale/translations_pot_files", files)
	ProjectSettings.save()
	
	EditorInterface.get_base_control().accept_event() # 刷新编辑器状态
	OS.alert("已完成全量扫描，共计 %d 个文件。请前往 [项目设置 -> 本地化 -> POT生成] 点击生成按钮。" % files.size())


func _scan_dir(path: String, exts: Array, result: PackedStringArray):
	var dir = DirAccess.open(path)
	if not dir: return
	dir.list_dir_begin()
	var fn = dir.get_next()
	while fn != "":
		if dir.current_is_dir() and not fn.begins_with("."):
			_scan_dir(path + fn + "/", exts, result)
		elif fn.get_extension() in exts:
			result.append(path + fn)
		fn = dir.get_next()
