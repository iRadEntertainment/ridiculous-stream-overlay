@tool
extends PanelContainer
class_name PnlReward

@export_tool_button("pop") var _pop: Callable = _run_editor_populate

var reward: TwitchCustomReward:
	set(val):
		if reward == val:
			return
		_populate()



func _populate() -> void:
	%ln_broadcaster_id.text = reward.broadcaster_id
	%ln_broadcaster_login.text = reward.broadcaster_login
	%ln_broadcaster_name.text = reward.broadcaster_name
	%ln_id.text = reward.id
	%ln_title.text = reward.title
	%ln_prompt.text = reward.prompt
	%ln_cost.text = reward.cost
	# TwitchCustomReward.TwitchImage
	reward.image.url_1x
	reward.image.url_2x
	reward.image.url_4x
	# TwitchCustomReward.DefaultImage
	reward.default_image.url_1x
	reward.default_image.url_2x
	reward.default_image.url_4x
	%cl_background_color.color = Color(reward.background_color)
	%ck_is_enabled.value = reward.is_enabled
	%ck_is_user_input_required.value = reward.is_user_input_required
	# TwitchCustomReward.MaxPerStreamSetting
	reward.max_per_stream_setting.is_enabled
	reward.max_per_stream_setting.max_per_stream
	# TwitchCustomReward.MaxPerUserPerStreamSetting
	reward.max_per_user_per_stream_setting.is_enabled
	reward.max_per_user_per_stream_setting.max_per_user_per_stream
	# TwitchCustomReward.GlobalCooldownSetting
	reward.global_cooldown_setting.is_enabled
	reward.global_cooldown_setting.global_cooldown_seconds
	%ck_is_paused.value = reward.is_paused
	%ck_is_in_stock.value = reward.is_in_stock
	%ck_should_redemptions_skip_request_queue.value = reward.should_redemptions_skip_request_queue
	%ln_redemptions_redeemed_current_stream.text = reward.redemptions_redeemed_current_stream
	%ln_cooldown_expires_at.text = reward.cooldown_expires_at


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
		%ck_is_enabled.value,
		%ck_is_user_input_required.value,
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
		%ck_is_paused.value,
		%ck_is_in_stock.value,
		%ck_should_redemptions_skip_request_queue.value,
		int(%ln_redemptions_redeemed_current_stream.text),
		%ln_cooldown_expires_at.text,
	)
	return new_reward


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
		var type: String = _properties[key]
		if type in ["String", "int"]:
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
		elif type == "bool":
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
				to_print.append("# %s.%s: %s" % [_print_key, key, type])
	
	print("==")
	for string: String in to_print:
		print(string)
