extends PanelContainer


func start() -> void:
	update_list(%vb_twitch_list, await get_rewards_from_twitch(false), EntryReward.Type.TWITCH)
	update_list(%vb_local_list, get_rewards_from_disk(), EntryReward.Type.LOCAL)


func update_list(list_node: VBoxContainer, data: Array[TwitchCustomReward], type: EntryReward.Type) -> void:
	for child in list_node.get_children():
		child.queue_free()
	for reward: TwitchCustomReward in data:
		var entry: EntryReward = preload("res://instances/entries/entry_reward.tscn").instantiate()
		entry.reward = reward
		entry.type = type
		entry.pressed.connect(_on_entry_pressed)
		list_node.add_child(entry)


func get_rewards_from_twitch(only_manageable_rewards: bool) -> Array[TwitchCustomReward]:
	var opt := TwitchGetCustomReward.Opt.new()
	opt.only_manageable_rewards = only_manageable_rewards
	var res: TwitchGetCustomReward.Response = await RS.twitcher.api.get_custom_reward(opt, str(RS.settings.broadcaster_id))
	return res.data


func get_rewards_from_disk() -> Array[TwitchCustomReward]:
	var data: Array[TwitchCustomReward] = []
	var files: PackedStringArray = RSUtl.list_file_in_folder(RSSettings.get_redeems_path(), ["json"])
	for file: String in files:
		var d: Dictionary = RSUtl.load_json(RSSettings.get_redeems_path().path_join(file))
		data.append(TwitchCustomReward.from_json(d))
	return data


func _on_entry_pressed(entry: EntryReward) -> void:
	%pnl_reward_inspector.reward = entry.reward


func _on_btn_reload_from_twitch_pressed() -> void:
	update_list(%vb_twitch_list, await get_rewards_from_twitch(false), EntryReward.Type.TWITCH)


func _on_btn_reload_local_pressed() -> void:
	update_list(%vb_local_list, get_rewards_from_disk(), EntryReward.Type.LOCAL)
