extends PanelContainer


func start() -> void:
	update_local_list()
	RS.twitcher.connected_to_twitch.connect(update_twitch_list)


#region Update
func update_twitch_list() -> void:
	_update_list(%vb_twitch_list, await _get_entries_rewards_from_twitch(false))


func update_local_list() -> void:
	_update_list(%vb_local_list, _get_entries_rewards_from_disk())


func _update_list(list_node: VBoxContainer, entries: Array[EntryReward]) -> void:
	for child in list_node.get_children():
		child.queue_free()
	for entry: EntryReward in entries:
		list_node.add_child(entry)
#endregion


#region Getters
func get_rewards_from_twitch(only_manageable_rewards: bool) -> Array[TwitchCustomReward]:
	var opt := TwitchGetCustomReward.Opt.new()
	opt.only_manageable_rewards = only_manageable_rewards
	var res: TwitchGetCustomReward.Response = await RS.twitcher.api.get_custom_reward(opt, str(RS.settings.broadcaster_id))
	return res.data


func _get_entries_rewards_from_twitch(only_manageable_rewards: bool) -> Array[EntryReward]:
	var entries: Array[EntryReward] = []
	var data: Array[TwitchCustomReward] = await get_rewards_from_twitch(only_manageable_rewards)
	for reward: TwitchCustomReward in data:
		var entry: EntryReward = preload("res://instances/entries/entry_reward.tscn").instantiate()
		entry.reward = reward
		entry.type = EntryReward.Type.TWITCH
		entry.pressed.connect(_on_entry_pressed)
		entries.append(entry)
	return entries


func _get_entries_rewards_from_disk() -> Array[EntryReward]:
	var entries: Array[EntryReward] = []
	var files: PackedStringArray = RSUtl.list_file_in_folder(RSSettings.get_redeems_path(), ["json"])
	for file: String in files:
		var d: Dictionary = RSUtl.load_json(RSSettings.get_redeems_path().path_join(file))
		var reward: TwitchCustomReward = TwitchCustomReward.from_json(d)
		var entry: EntryReward = preload("res://instances/entries/entry_reward.tscn").instantiate()
		entry.reward = reward
		entry.type = EntryReward.Type.LOCAL
		entry.local_filepath = file
		# entry.local_icon_filepath # TODO
		entry.pressed.connect(_on_entry_pressed)
		entries.append(entry)
	return entries
#endregion


#region Signals
func _on_entry_pressed(entry: EntryReward) -> void:
	%pnl_reward_inspector.entry = entry


func _on_btn_reload_from_twitch_pressed() -> void: update_twitch_list()
func _on_btn_reload_local_pressed() -> void: update_local_list()
#endregion
