class_name UpgradeComponent
extends Node

@export var enemy_spawn_component: EnemySpawnComponent
@export var upgrade_options_ui: UpgradeOptionsUI
@export var upgrade_resources: Array[UpgradeResource]

var resources_id_dict: Dictionary[String, UpgradeResource] = {}
var generaged_resources_cache: Dictionary[int, Array] = {}


func _ready() -> void:
	for res in upgrade_resources:
		resources_id_dict[res.id] = res
	upgrade_options_ui.upgrade_selected.connect(_on_upgrade_option_selected)
	if is_multiplayer_authority():
		enemy_spawn_component.round_completed.connect(_on_round_completed)


func generate_options() -> void:
	if not is_multiplayer_authority():
		return
	var all_peers := multiplayer.get_peers()
	all_peers.append(1)
	generaged_resources_cache.clear()
	for peer in all_peers:
		# TODO 随机选择
		var resources = [
			upgrade_resources[0],
			upgrade_resources[0],
			upgrade_resources[0],
		]
		generaged_resources_cache[peer] = resources
		var resource_ids = resources.map(func(res: UpgradeResource): return res.id)
		show_upgrade_options.rpc_id(peer, resource_ids)


@rpc("authority", "call_local", "reliable")
func show_upgrade_options(resource_ids: Array) -> void:
	var resources := resource_ids.map(func(res_id: String): return resources_id_dict[res_id])
	upgrade_options_ui.show_upgrade_options(resources)


@rpc("any_peer", "call_local", "reliable")
func select_upgrade_option(index: int) -> void:
	if not is_multiplayer_authority():
		return
	var peer_id := multiplayer.get_remote_sender_id()
	if not peer_id in generaged_resources_cache:
		return
	var resources := generaged_resources_cache[peer_id]
	if index < 0 or index >= resources.size():
		return
	generaged_resources_cache.erase(peer_id)
	var selected_resource: UpgradeResource = resources[index]
	print("[peer %s] peer %s selected upgrade option id: %s" % [
		multiplayer.get_unique_id(),
		peer_id,
		selected_resource.id
	])


func _on_upgrade_option_selected(index: int) -> void:
	# 由各peer本地触发, peer id需要传递给服务器
	select_upgrade_option.rpc_id(1, index)


func _on_round_completed() -> void:
	generate_options()
