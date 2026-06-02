class_name UpgradeComponent
extends Node

signal upgrade_finished

static var instance: UpgradeComponent

@export var upgrade_options_ui: UpgradeOptionsUI

var resources_id_dict: Dictionary[String, PassiveItemResource] = {}
var avaiable_peer_resources: Dictionary[int, Array] = {}
var peer_selected_passives: Dictionary[int, Dictionary] = {}


static func get_peer_upgrade_count(peer_id: int, resource_id: String) -> int:
	return get_peer_passive_count(peer_id, resource_id)


static func get_peer_passive_count(peer_id: int, passive_id: String) -> int:
	if not is_instance_valid(instance):
		return 0
	if peer_id not in instance.peer_selected_passives:
		return 0
	var selected_passives: Dictionary = instance.peer_selected_passives[peer_id]
	return selected_passives.get(passive_id, 0)


func _ready() -> void:
	instance = self
	_refresh_passive_resources()
	upgrade_options_ui.upgrade_selected.connect(_on_upgrade_option_selected)
	if is_multiplayer_authority():
		multiplayer.peer_disconnected.connect(_on_peer_disconnected)


func generate_options() -> void:
	if not is_multiplayer_authority():
		return
	if resources_id_dict.is_empty():
		push_warning("No passive item resources loaded for upgrade options.")
		upgrade_finished.emit()
		return
	var all_peers := Tools.get_game_peers()
	avaiable_peer_resources.clear()
	for peer in all_peers:
		var copy_resources := Array(resources_id_dict.values())
		copy_resources.shuffle()
		var resources := copy_resources.slice(0, min(3, copy_resources.size()))
		avaiable_peer_resources[peer] = resources
		var resource_ids := resources.map(func(res: PassiveItemResource) -> String: return res.id)
		show_upgrade_options.rpc_id(peer, resource_ids)


func _check_upgrade_finished() -> void:
	if avaiable_peer_resources.is_empty():
		upgrade_finished.emit()


@rpc("authority", "call_local", "reliable")
func show_upgrade_options(resource_ids: Array) -> void:
	var resources := resource_ids.map(func(res_id: String) -> PassiveItemResource: return resources_id_dict[res_id])
	upgrade_options_ui.show_upgrade_options(resources)


@rpc("any_peer", "call_local", "reliable")
func select_upgrade_option(index: int) -> void:
	if not is_multiplayer_authority():
		return
	var peer_id := multiplayer.get_remote_sender_id()
	if not peer_id in avaiable_peer_resources:
		return
	var resources := avaiable_peer_resources[peer_id]
	if index < 0 or index >= resources.size():
		return
	avaiable_peer_resources.erase(peer_id)
	var selected_resource: PassiveItemResource = resources[index]
	var peer_passive_count_dic: Dictionary = peer_selected_passives.get_or_add(peer_id, {})
	var count: int = peer_passive_count_dic.get_or_add(selected_resource.id, 0)
	peer_passive_count_dic[selected_resource.id] = count + 1
	print("[peer %s] peer %s selected passive item id: %s, total count: %s" % [
		multiplayer.get_unique_id(),
		peer_id,
		selected_resource.id,
		count + 1,
	])
	_check_upgrade_finished()


func _on_upgrade_option_selected(index: int) -> void:
	# 由各peer本地触发, peer id需要传递给服务器
	select_upgrade_option.rpc_id(1, index)


func _on_peer_disconnected(peer_id: int) -> void:
	if peer_id in avaiable_peer_resources:
		avaiable_peer_resources.erase(peer_id)
		_check_upgrade_finished()
	peer_selected_passives.erase(peer_id)


func _refresh_passive_resources() -> void:
	resources_id_dict.clear()
	for res: PassiveItemResource in CSVResourceCache.get_all_passives():
		resources_id_dict[res.id] = res
