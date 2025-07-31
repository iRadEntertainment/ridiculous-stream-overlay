@tool
extends PanelContainer
class_name PnlReward

@warning_ignore("unused_private_class_variable")
@export_tool_button("pop") var _pop: Callable = _run_editor_populate

var reward: TwitchCustomReward:
	set(val):
		if reward == val:
			return
		reward = val
		_populate()
var type: EntryReward.Type = EntryReward.Type.TWITCH:
	set(val):
		type = val
		if not is_node_ready(): await ready
		%btn_save_to_disk.visible = type in [EntryReward.Type.LOCAL, EntryReward.Type.TWITCH]
		%btn_delete.visible = type == EntryReward.Type.LOCAL
		%btn_update_twitch.visible = type == EntryReward.Type.TWITCH
var local_filepath: String
var entry: EntryReward:
	set(val):
		if entry == val:
			return
		entry = val
		if not entry: return
		type = entry.type
		local_filepath = entry.local_filepath
		reward = entry.reward

signal entry_saved(entry: EntryReward)
signal entry_deleted(entry: EntryReward)


#region Update
func _populate() -> void:
	if not reward:
		clear()
		return
	%btn_file_path.text = entry.local_filepath
	
	%ln_broadcaster_id.text = reward.broadcaster_id
	%ln_broadcaster_login.text = reward.broadcaster_login
	%ln_broadcaster_name.text = reward.broadcaster_name
	%ln_id.text = reward.id
	%ln_title.text = reward.title
	%ln_prompt.text = reward.prompt
	%ln_cost.text = str(reward.cost)
	# TwitchCustomReward.TwitchImage
	#reward.image.url_1x
	#reward.image.url_2x
	#reward.image.url_4x
	# TwitchCustomReward.DefaultImage
	#reward.default_image.url_1x
	#reward.default_image.url_2x
	#reward.default_image.url_4x
	%cl_background_color.color = Color(reward.background_color)
	%ck_is_enabled.button_pressed = reward.is_enabled
	%ck_is_user_input_required.button_pressed = reward.is_user_input_required
	# TwitchCustomReward.MaxPerStreamSetting
	#reward.max_per_stream_setting.is_enabled
	#reward.max_per_stream_setting.max_per_stream
	# TwitchCustomReward.MaxPerUserPerStreamSetting
	#reward.max_per_user_per_stream_setting.is_enabled
	#reward.max_per_user_per_stream_setting.max_per_user_per_stream
	# TwitchCustomReward.GlobalCooldownSetting
	#reward.global_cooldown_setting.is_enabled
	#reward.global_cooldown_setting.global_cooldown_seconds
	%ck_is_paused.button_pressed = reward.is_paused
	%ck_is_in_stock.button_pressed = reward.is_in_stock
	%ck_should_redemptions_skip_request_queue.button_pressed = reward.should_redemptions_skip_request_queue
	%ln_redemptions_redeemed_current_stream.text = str(reward.redemptions_redeemed_current_stream)
	%ln_cooldown_expires_at.text = reward.cooldown_expires_at


func clear() -> void:
	entry = null
	local_filepath = ""
	
	%ln_broadcaster_id.text = ""
	%ln_broadcaster_login.text = ""
	%ln_broadcaster_name.text = ""
	%ln_id.text = ""
	%ln_title.text = ""
	%ln_prompt.text = ""
	%ln_cost.text = ""
	%cl_background_color.color = Color.TRANSPARENT
	%ck_is_enabled.button_pressed = false
	%ck_is_user_input_required.button_pressed = false
	%ck_is_paused.button_pressed = false
	%ck_is_in_stock.button_pressed = false
	%ck_should_redemptions_skip_request_queue.button_pressed = false
	%ln_redemptions_redeemed_current_stream.text = ""
	%ln_cooldown_expires_at.text = ""
#endregion


#region Utilities
func save_to_disk() -> void:
	var filepath: String = %btn_file_path.text
	if filepath.is_empty():
		filepath = RSSettings.get_redeems_path().path_join(filename_from_reward(reward))
	if not filepath.get_file().is_valid_filename():
		return
	RSUtl.save_to_json(filepath, reward.to_dict())
	if entry:
		entry_saved.emit(entry)
func delete() -> void:
	if entry:
		entry.queue_free()
	if FileAccess.file_exists(local_filepath):
		OS.move_to_trash(local_filepath)
	clear()
func update_twitch() -> void:
	pass
#endregion


#region Getters
func get_reward_from_fields() -> TwitchCustomReward:
	var new_reward := TwitchCustomReward.create(
		%ln_broadcaster_id.text,
		%ln_broadcaster_login.text,
		%ln_broadcaster_name.text,
		%ln_id.text,
		%ln_title.text,
		%ln_prompt.text,
		int(%ln_cost.text),
		TwitchCustomReward.TwitchImage.create(
			reward.image.url_1x,
			reward.image.url_2x,
			reward.image.url_4x,
		),
		TwitchCustomReward.DefaultImage.create(
			reward.default_image.url_1x,
			reward.default_image.url_2x,
			reward.default_image.url_4x,
		),
		%cl_background_color.color.to_html(),
		%ck_is_enabled.button_pressed,
		%ck_is_user_input_required.button_pressed,
		TwitchCustomReward.MaxPerStreamSetting.create(
			reward.max_per_stream_setting.is_enabled,
			reward.max_per_stream_setting.max_per_stream,
		),
		TwitchCustomReward.MaxPerUserPerStreamSetting.create(
			reward.max_per_user_per_stream_setting.is_enabled,
			reward.max_per_user_per_stream_setting.max_per_user_per_stream,
		),
		TwitchCustomReward.GlobalCooldownSetting.create(
			reward.global_cooldown_setting.is_enabled,
			reward.global_cooldown_setting.global_cooldown_seconds,
		),
		%ck_is_paused.button_pressed,
		%ck_is_in_stock.button_pressed,
		%ck_should_redemptions_skip_request_queue.button_pressed,
		int(%ln_redemptions_redeemed_current_stream.text),
		%ln_cooldown_expires_at.text,
	)
	return new_reward
#endregion


#region Tool to populate properties
func _run_editor_populate() -> void:
	create_entries_from_properties(%vb, properties, 200, "reward")
var properties := {
	"broadcaster_id": "String",
	"broadcaster_login": "String",
	"broadcaster_name": "String",
	"id": "String",
	"title": "String",
	"prompt": "String",
	"cost": "int",
	"image": "TwitchImage",
	"default_image": "DefaultImage",
	"background_color": "String",
	"is_enabled": "bool",
	"is_user_input_required": "bool",
	"max_per_stream_setting": "MaxPerStreamSetting",
	"max_per_user_per_stream_setting": "MaxPerUserPerStreamSetting",
	"global_cooldown_setting": "GlobalCooldownSetting",
	"is_paused": "bool",
	"is_in_stock": "bool",
	"should_redemptions_skip_request_queue": "bool",
	"redemptions_redeemed_current_stream": "int",
	"cooldown_expires_at": "String",
}
static func create_entries_from_properties(
			container_node: Container,
			_properties: Dictionary,
			_lb_min_x: float = 0.0,
			_print_key: String = "",
		) -> void:
	for child in container_node.get_children():
		child.free()
	var to_print: Array[String] = []
	for key: String in _properties:
		var _type: String = _properties[key]
		if _type in ["String", "int"]:
			var hb := HBoxContainer.new()
			hb.name = "hb_%s" % key
			var lb := Label.new()
			lb.name = "lb"
			if _lb_min_x != 0.0:
				lb.custom_minimum_size.x = _lb_min_x
			lb.text = key.capitalize()
			var ln := LineEdit.new()
			ln.name = "ln_%s" % key
			ln.placeholder_text = key
			ln.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			hb.add_child(lb)
			hb.add_child(ln)
			container_node.add_child(hb)
			if Engine.is_editor_hint():
				hb.owner = container_node.owner
				lb.owner = container_node.owner
				ln.owner = container_node.owner
				ln.unique_name_in_owner = true
				to_print.append("%%%s.text = %s.%s" % [ln.name, _print_key, key])
		elif _type == "bool":
			var ck := CheckBox.new()
			ck.name = "ck_%s" % key
			ck.text = key.capitalize()
			ck.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			container_node.add_child(ck)
			if Engine.is_editor_hint():
				ck.owner = container_node.owner
				ck.unique_name_in_owner = true
				to_print.append("%%%s.value = %s.%s" % [ck.name, _print_key, key])
		else:
			var btn_collapse: BtnCollapse = preload("res://instances/utils/btn_collapse.tscn").instantiate()
			btn_collapse.name = "btn_collapse_%s" % key
			btn_collapse.text = key.capitalize()
			btn_collapse.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			container_node.add_child(btn_collapse)
			if Engine.is_editor_hint():
				btn_collapse.owner = container_node.owner
				to_print.append("# %s.%s: %s" % [_print_key, key, _type])
	
	print("==")
	for string: String in to_print:
		print(string)
#endregion


#region Utilities
func popup_filepath_selection() -> void:
	#file_dialog_show(title: String, current_directory: String, filename: String, show_hidden: bool, mode: FileDialogMode, filters: PackedStringArray, callback: Callable)
	var title: String = "Select save location for Reward to json"
	var current_directory: String = RSSettings.get_redeems_path()
	var filename: String
	if local_filepath:
		filename = local_filepath.get_file()
	else:
		filename = filename_from_reward(reward)
	var show_hidden: bool = false
	var mode := DisplayServer.FileDialogMode.FILE_DIALOG_MODE_SAVE_FILE
	var filters := PackedStringArray(["*.json"])
	
	DisplayServer.file_dialog_show(
		title,
		current_directory,
		filename,
		show_hidden,
		mode,
		filters,
		_on_file_dialog_selected
	)
	
	RS.pnl_settings.hide()


func _on_file_dialog_selected(
			status: bool,
			selected_paths: PackedStringArray,
			_selected_filter_index: int
		) -> void:
	if !status: return
	var path: String = selected_paths[0]
	%btn_file_path.text = path
	%btn_save_to_disk.disabled = not path.get_file().is_valid_filename() or path.is_empty()
	RS.pnl_settings.show()


static func filename_from_reward(_reward: TwitchCustomReward) -> String:
	var filename: String = "%s_%s.json" % [_reward.id, _reward.title.validate_filename()]
	return filename
#endregion


#region Inspector Signals
func _on_btn_save_to_disk_pressed() -> void:
	save_to_disk()
func _on_btn_delete_pressed() -> void:
	delete()
func _on_btn_update_twitch_pressed() -> void:
	update_twitch()
func _on_btn_file_path_pressed() -> void:
	popup_filepath_selection()
#endregion
