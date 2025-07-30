
extends PanelContainer

const reward_entry_pack = preload("res://instances/entries/entry_reward.tscn")



func start() -> void:
	update_list(%vb_twitch_list, await get_rewards_from_twitch(false))


func update_list(list_node: VBoxContainer, data: Array[TwitchCustomReward]) -> void:
	for child in list_node.get_children():
		child.queue_free()
	for reward: TwitchCustomReward in data:
		var entry = reward_entry_pack.instantiate()
		entry.reward = reward
		if reward.image:
			entry.icon_img = await RS.loader.load_texture_from_url(reward.image.url_4x, false)
		list_node.add_child(entry)
		entry.owner = owner
		entry.start()


func get_rewards_from_twitch(only_manageable_rewards: bool) -> Array[TwitchCustomReward]:
	var opt := TwitchGetCustomReward.Opt.new()
	opt.only_manageable_rewards = only_manageable_rewards
	var res: TwitchGetCustomReward.Response = await RS.twitcher.api.get_custom_reward(opt, str(RS.settings.broadcaster_id))
	return res.data


func get_rewards_from_disk() -> Array[TwitchCustomReward]:
	var data: Array[TwitchCustomReward] = []
	var files: PackedStringArray = []
	for file: String in RSUtl.list_file_in_folder(RS.settings.get_redeems_path(), ["json"]):
		var d: Dictionary = RSUtl.load_json(RS.settings.get_redeems_path().path_join(file))
		data.append(TwitchCustomReward.from_json(d))
	return data


func _on_btn_reload_from_twitch_pressed() -> void:
	update_list(%vb_twitch_list, await get_rewards_from_twitch(false))


#func entry_from_data(redeem : TwitchCustomReward) -> HBoxContainer:
	#var entry := HBoxContainer.new()
	#var lb := Label.new()
	#lb.text = redeem.title
	#lb.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	#var btn := CheckButton.new()
	#btn.button_pressed = redeem.is_enabled
	#entry.add_child(lb)
	#entry.add_child(btn)
	#return entry
