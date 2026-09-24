extends PanelContainer
class_name PnlUserStats

const CARET_RIGHT = preload("res://ui/icons/bootstrap_icons/caret-right-fill.png")
const CARET_DOWN = preload("res://ui/icons/bootstrap_icons/caret-down-fill.png")

var user: RSUser: set = _set_user
var is_global_interactions: bool = true: set = _set_is_global_interactions
var _displayed_summary_id := ""


func _ready() -> void:
	clear()
	if %ck_global.button_pressed != is_global_interactions:
		%ck_global.button_pressed = is_global_interactions
	if !RS.is_node_ready(): await RS.ready
	RS.summary_mng.user_interactions_updated.connect(_on_user_interactions_updated)
	RS.summary_mng.summary_changed.connect(_on_summary_changed)
	_populate.call_deferred()


func _populate() -> void:
	if not is_node_ready():
		return
	_displayed_summary_id = RS.summary_mng.summary.id if RS.summary_mng.summary != null else ""
	clear()
	if user == null:
		return
	%ln_added_on.text = RSUtl.unix_to_string(user.added_on, false, false)
	
	var interactions: RSUser.Interactions
	if is_global_interactions:
		interactions = user.current_global_interactions
	else:
		interactions = user.current_interactions
	_populate_from_interactions(interactions)


func _populate_from_interactions(interactions: RSUser.Interactions) -> void:
	if not interactions:
		clear()
		return
	%ln_points.text = str(interactions.global_points)
	
	%ln_messages_count.text = str(interactions.messages_count)
	%ln_commands_count.text = str(interactions.commands_count)
	%ln_fake_commands_count.text = str(interactions.fake_commands_count)
	%ln_channel_points_spent_count.text = str(interactions.channel_points_spent_count)
	%ln_gigantify_count.text = str(interactions.gigantify_count)
	%ln_bits_count.text = str(interactions.bits_count)
	%ln_raids_in_count.text = str(interactions.raids_in_count)
	%ln_raids_out_count.text = str(interactions.raids_out_count)
	
	var redeems_count: int = interactions.redeems_count
	%ln_redeems_count.text = str(redeems_count)
	# interactions.redeems # Dictionary[String, int] = {}
	%btn_expand_redeems.disabled = redeems_count == 0
	%btn_expand_redeems.icon = CARET_RIGHT
	%btn_expand_redeems.button_pressed = false
	%vb_redeems.hide()
	for redeem_name: String in interactions.redeems.keys():
		var val: int = interactions.redeems[redeem_name]
		add_counter_entry_to_node(%vb_redeems, redeem_name, val)
	
	var sub_count := interactions.subscriptions_count + interactions.gift_subscriptions_count
	%ln_subscriptions_count.text = str(sub_count)
	%ln_subscriptions_count.tooltip_text = "Self subscriptions and gifts sent; announcements and unclassified history are listed separately."
	%btn_expand_subscriptions.disabled = sub_count + interactions.resubscriptions_count + interactions.legacy_subscriptions_count == 0
	%btn_expand_subscriptions.icon = CARET_RIGHT
	%btn_expand_subscriptions.button_pressed = false
	%vb_subscriptions.hide()
	var categories := {
		"subscriptions": "Self", "gift_subscriptions": "Gifted",
		"resubscriptions": "Resub announcements", "legacy_subscriptions": "Earlier (unclassified)",
	}
	for field in categories:
		var counts: Dictionary = interactions.get(field)
		for tier in counts:
			add_counter_entry_to_node(%vb_subscriptions, "%s · Tier %d" % [categories[field], int(tier) + 1], counts[tier])
	# points
	%lb_msg_pt.text = str(interactions.messages_points)
	%lb_commands_pt.text = str(interactions.commands_points)
	%lb_fake_commands_pt.text = str(interactions.fake_commands_points)
	%lb_channel_points_spent_pt.text = str(interactions.channel_points_spent_points)
	%lb_gigantify_count_pt.text = str(interactions.gigantify_points)
	%lb_bits_pt.text = str(interactions.bits_points)
	%lb_raids_in_pt.text = str(interactions.raids_in_points)
	%lb_subscriptions_count_pt.text = str(interactions.subscription_points)


func clear() -> void:
	%ln_added_on.text = ""
	%ln_points.text = ""
	
	%ln_messages_count.text = ""
	%ln_commands_count.text = ""
	%ln_fake_commands_count.text = ""
	%ln_channel_points_spent_count.text = ""
	%ln_redeems_count.text = ""
	%ln_gigantify_count.text = ""
	%ln_bits_count.text = ""
	%ln_raids_in_count.text = ""
	%ln_raids_out_count.text = ""
	%ln_subscriptions_count.text = ""
	
	%btn_expand_redeems.disabled = true
	%btn_expand_redeems.icon = CARET_RIGHT
	%btn_expand_redeems.button_pressed = false
	%vb_redeems.hide()
	for child in %vb_redeems.get_children():
		child.free()
	
	%btn_expand_subscriptions.disabled = true
	%btn_expand_subscriptions.icon = CARET_RIGHT
	%btn_expand_subscriptions.button_pressed = false
	%vb_subscriptions.hide()
	for child in %vb_subscriptions.get_children():
		child.free()
	
	# points
	%lb_msg_pt.text = ""
	%lb_commands_pt.text = ""
	%lb_fake_commands_pt.text = ""
	%lb_channel_points_spent_pt.text = ""
	%lb_gigantify_count_pt.text = ""
	%lb_bits_pt.text = ""
	%lb_raids_in_pt.text = ""
	%lb_subscriptions_count_pt.text = ""


func add_counter_entry_to_node(node: Control, key: String, val: int) -> void:
	var hb: HBoxContainer = HBoxContainer.new()
	var empty: Control = Control.new()
	empty.custom_minimum_size.x = 32 #px
	var ln: LineEdit = LineEdit.new()
	ln.text = str(val)
	ln.editable = false
	var lb: Label = Label.new()
	lb.text = key
	lb.clip_text = true
	lb.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	lb.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hb.add_child(empty)
	hb.add_child(ln)
	hb.add_child(lb)
	node.add_child(hb)


#region Setters
func _set_is_global_interactions(val: bool) -> void:
	if is_global_interactions == val:
		return
	is_global_interactions = val
	if not is_node_ready():
		return
	_populate()
	if %ck_global.button_pressed != is_global_interactions:
		%ck_global.button_pressed = is_global_interactions


func _set_user(value: RSUser) -> void:
	user = value
	if is_node_ready():
		_populate()
#endregion


func _on_user_interactions_updated(user_id: int) -> void:
	if user != null and user.user_id == user_id:
		_populate()

func _on_summary_changed() -> void:
	var current_id: String = RS.summary_mng.summary.id if RS.summary_mng.summary != null else ""
	if current_id != _displayed_summary_id:
		_populate()


#region Inspector signals
func _on_ck_global_toggled(toggled_on: bool) -> void:
	is_global_interactions = toggled_on
func _on_btn_expand_redeems_toggled(toggled_on: bool) -> void:
	%btn_expand_redeems.icon = CARET_DOWN if toggled_on else CARET_RIGHT
	%vb_redeems.visible = toggled_on
func _on_btn_expand_subscriptions_toggled(toggled_on: bool) -> void:
	%btn_expand_subscriptions.icon = CARET_DOWN if toggled_on else CARET_RIGHT
	%vb_subscriptions.visible = toggled_on
#endregion
