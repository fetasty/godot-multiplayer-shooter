@tool
extends EditorPlugin

var parser: ResourceTranslationParser

func _enter_tree():
	# 实例化并添加自定义解析器
	parser = ResourceTranslationParser.new()
	add_translation_parser_plugin(parser)
	print("✅ 自定义 Resource 翻译解析器已挂载")


func _exit_tree():
	# 退出插件时清理
	if parser:
		remove_translation_parser_plugin(parser)
		parser = null
