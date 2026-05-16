@tool
extends EditorTranslationParserPlugin
class_name CSVConfigTranslationParser


# 1. 告诉 Godot 这个解析器负责处理什么后缀的文件
func _get_recognized_extensions() -> PackedStringArray:
	return ["csv"]


# 2. 核心解析逻辑
func _parse_file(path: String) -> Array[PackedStringArray]:
	var ret: Array[PackedStringArray] = []
	var file: FileAccess = FileAccess.open(path, FileAccess.READ)
	if file == null:
		push_warning("[CSVConfigTranslationParser] failed to open %s: %s" % [path, FileAccess.get_open_error()])
		return ret

	if file.eof_reached():
		return ret

	var headers: PackedStringArray = file.get_csv_line()
	var key_column_indices: Array[int] = []
	for index in range(headers.size()):
		var header: String = headers[index].strip_edges()
		if index == 0:
			header = header.replace("\ufeff", "")
		if header.ends_with("_key"):
			key_column_indices.append(index)

	if key_column_indices.is_empty():
		return ret

	while not file.eof_reached():
		var row: PackedStringArray = file.get_csv_line()
		for column_index in key_column_indices:
			if column_index >= row.size():
				continue

			var key_value: String = row[column_index].strip_edges()
			if key_value != "":
				ret.append(PackedStringArray([key_value]))

	return ret
