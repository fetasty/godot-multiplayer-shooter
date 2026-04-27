@tool
extends EditorTranslationParserPlugin
class_name ResourceTranslationParser


# 1. 告诉 Godot 这个解析器负责处理什么后缀的文件
func _get_recognized_extensions() -> PackedStringArray:
	return ["tres", "res"]


# 2. 核心解析逻辑
func _parse_file(path: String) -> Array[PackedStringArray]:
	var ret: Array[PackedStringArray] = []
	# 加载资源文件
	var res = ResourceLoader.load(path)
	print("[ResourceTranslationParser] parse %s, res: %s" % [path, res])
	if not res:
		return ret

	# 扫描这个资源里的所有属性，只要属性名以 "_key" 结尾，就把它提取到 POT 中
	var properties = res.get_property_list()
	for prop in properties:
		var prop_name = prop["name"]
		if prop_name.ends_with("_key"):
			var key_value = res.get(prop_name)
			# 确保提取的是有效的非空字符串
			if typeof(key_value) == TYPE_STRING and key_value.strip_edges() != "":
				ret.append(PackedStringArray([key_value]))

	return ret
