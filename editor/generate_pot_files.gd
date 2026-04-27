@tool
extends EditorScript

# 运行方式：
# 在 Godot 编辑器顶部的 "Script" 视图中打开此文件
# 点击菜单栏 "File" -> "Run" (或按快捷键 Ctrl+Shift+X)

func _run():
	# 定义需要提取翻译文本的文件扩展名
	var extensions_to_scan = ["gd", "tscn"]
	var scanned_files: PackedStringArray = []
	
	# 从项目根目录开始递归扫描
	_scan_directory("res://", extensions_to_scan, scanned_files)
	
	# Godot 存储 POT 文件列表的内部项目设置键名
	var setting_path = "internationalization/locale/translations_pot_files"
	ProjectSettings.set_setting(setting_path, scanned_files)
	
	# 强制保存写入到 project.godot 文件中
	var error = ProjectSettings.save()
	if error == OK:
		print("✅ 成功！已扫描并更新 %d 个文件到 POT 生成列表。" % scanned_files.size())
	else:
		printerr("❌ 保存项目设置失败，错误码: ", error)

func _scan_directory(path: String, extensions: Array, result: PackedStringArray):
	var dir = DirAccess.open(path)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if dir.current_is_dir():
				# 忽略隐藏目录，防止扫描庞大的 .godot 缓存文件夹
				if not file_name.begins_with("."):
					_scan_directory(path + file_name + "/", extensions, result)
			else:
				var ext = file_name.get_extension()
				if ext in extensions:
					result.append(path + file_name)
			file_name = dir.get_next()
