extends Node

const ENEMY_RES := preload("res://resources/enemy_resource.gd")
const PASSIVE_RES := preload("res://resources/passive_item_resource.gd")
const PICKUP_RES := preload("res://resources/pickup_item_resource.gd")

const CSV_PATH_ENEMY := "res://config/enemy_config.csv"
const CSV_PATH_PASSIVE := "res://config/passive_item_config.csv"
const CSV_PATH_PICKUP := "res://config/pickup_item_config.csv"

var enemy_resources: Dictionary = {}
var enemy_resources_all: Array = []
var passive_resources: Dictionary = {}
var passive_resources_all: Array = []
var pickup_resources: Dictionary = {}
var pickup_resources_all: Array = []


func _ready() -> void:
	_load_enemy_csv()
	_load_passive_csv()
	_load_pickup_csv()


func _load_enemy_csv() -> void:
	var file := FileAccess.open(CSV_PATH_ENEMY, FileAccess.READ)
	if file == null:
		push_error("[CSV] Failed to open enemy CSV")
		return
	var header_map := _build_header_map(file)
	enemy_resources.clear()
	enemy_resources_all.clear()
	while not file.eof_reached():
		var row := file.get_csv_line()
		if row.size() <= 1 and row[0] == "":
			continue
		var res := ENEMY_RES.new()
		res.id = _col(row, header_map.get("id", -1))
		res.scene = _load_res(_col(row, header_map.get("scene", -1))) as PackedScene
		res.name_key = _col(row, header_map.get("name_key", -1))
		res.health_range = _to_vec2(_col(row, header_map.get("health_range", -1)))
		res.damage_range = _to_vec2(_col(row, header_map.get("damage_range", -1)))
		res.description_key = _col(row, header_map.get("description_key", -1))
		res.custom_params = _col(row, header_map.get("custom_params", -1))
		res.custom_description = _col(row, header_map.get("custom_description", -1))
		enemy_resources[res.id] = res
		enemy_resources_all.append(res)
	print("[CSV] Loaded %d enemy configs" % enemy_resources_all.size())


func _load_passive_csv() -> void:
	var file := FileAccess.open(CSV_PATH_PASSIVE, FileAccess.READ)
	if file == null:
		push_error("[CSV] Failed to open passive CSV")
		return
	var header_map := _build_header_map(file)
	passive_resources.clear()
	passive_resources_all.clear()
	while not file.eof_reached():
		var row := file.get_csv_line()
		if row.size() <= 1 and row[0] == "":
			continue
		var res := PASSIVE_RES.new()
		res.id = _col(row, header_map.get("id", -1))
		res.icon = _load_res(_col(row, header_map.get("icon", -1)))
		res.name_key = _col(row, header_map.get("name_key", -1))
		res.description_key = _col(row, header_map.get("description_key", -1))
		res.effect_type = _col(row, header_map.get("effect_type", -1))
		res.effect_params = _col(row, header_map.get("effect_params", -1))
		res.valid_count = _to_int(_col(row, header_map.get("valid_count", -1)))
		res.valid_duration = _to_float(_col(row, header_map.get("valid_duration", -1)))
		passive_resources[res.id] = res
		passive_resources_all.append(res)
	print("[CSV] Loaded %d passive item configs" % passive_resources_all.size())


func _load_pickup_csv() -> void:
	var file := FileAccess.open(CSV_PATH_PICKUP, FileAccess.READ)
	if file == null:
		push_error("[CSV] Failed to open pickup CSV")
		return
	var header_map := _build_header_map(file)
	pickup_resources.clear()
	pickup_resources_all.clear()
	while not file.eof_reached():
		var row := file.get_csv_line()
		if row.size() <= 1 and row[0] == "":
			continue
		var res := PICKUP_RES.new()
		res.id = _col(row, header_map.get("id", -1))
		res.icon = _load_res(_col(row, header_map.get("icon", -1)))
		res.name_key = _col(row, header_map.get("name_key", -1))
		res.description_key = _col(row, header_map.get("description_key", -1))
		res.effect_type = _col(row, header_map.get("effect_type", -1))
		res.effect_params = _col(row, header_map.get("effect_params", -1))
		pickup_resources[res.id] = res
		pickup_resources_all.append(res)
	print("[CSV] Loaded %d pickup item configs" % pickup_resources_all.size())


func _build_header_map(file: FileAccess) -> Dictionary:
	if file.eof_reached():
		return {}
	var raw := file.get_csv_line()
	var map := {}
	for i in raw.size():
		var header := raw[i].strip_edges()
		if i == 0:
			header = header.replace("\uFEFF", "")
		if header.begins_with("comment_"):
			continue
		map[header] = i
	return map


func _col(row: PackedStringArray, idx: int) -> String:
	if idx < 0 or idx >= row.size():
		return ""
	return row[idx].strip_edges()


func _to_vec2(raw: String) -> Vector2:
	if raw.is_empty():
		return Vector2.ZERO
	var parts := raw.split(";")
	var x := parts[0].to_float() if parts.size() > 0 else 0.0
	var y := parts[1].to_float() if parts.size() > 1 else 0.0
	return Vector2(x, y)


func _to_float(raw: String) -> float:
	if raw.is_empty():
		return 0.0
	return raw.to_float()


func _to_int(raw: String) -> int:
	if raw.is_empty():
		return 0
	return raw.to_int()


func _load_res(path: String) -> Resource:
	if path.is_empty() or not ResourceLoader.exists(path):
		return null
	return load(path)


func get_enemy(id: String) -> Resource:
	return enemy_resources.get(id, null)


func get_all_enemies() -> Array:
	return enemy_resources_all


func get_passive(id: String) -> Resource:
	return passive_resources.get(id, null)


func get_all_passives() -> Array:
	return passive_resources_all


func get_pickup(id: String) -> Resource:
	return pickup_resources.get(id, null)


func get_all_pickups() -> Array:
	return pickup_resources_all
