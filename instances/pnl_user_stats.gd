extends PanelContainer
class_name PnlUserStats

const CARET_RIGHT = preload("res://ui/icons/bootstrap_icons/caret-right-fill.png")
const CARET_DOWN = preload("res://ui/icons/bootstrap_icons/caret-down-fill.png")

var user: RSUser: set = _set_user
var is_global_interactions: bool = true: set = _set_is_global_interactions


func _ready() -> void:
	clear()
	if %ck_global.button_pressed != is_global_interactions:
		%ck_global.button_pressed = is_global_interactions
	if !RS.is_node_ready(): await RS.ready
	RS.summary_mng.user_interactions_updated.connect(_on_user_interactions_updated)


func _populate() -> void:
	clear()
	var interactions: RSUser.Interactions
	var current: RSUser.Interactions = RS.summary_mng.get_user_current_interactions(user.user_id)
	if is_global_interactions:
		if current:
			interactions = user.global_interactions.merged_with_interactions(current)
		else:
			interactions = user.global_interactions
	elif current:
		interactions = current
	_populate_from_interactions(interactions)
	%ln_added_on.text = RSUtl.unix_to_string(user.added_on)


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
	
	var sub_count: int = interactions.subscriptions_count
	%ln_subscriptions_count.text = str(sub_count)
	# interactions.subscriptions # Dictionary[SubTier, int] = {}
	%btn_expand_subscriptions.disabled = sub_count == 0
	%btn_expand_subscriptions.icon = CARET_RIGHT
	%btn_expand_subscriptions.button_pressed = false
	%vb_subscriptions.hide()
	for tier: RSUser.Interactions.SubTier in interactions.subscriptions.keys():
		var val: int = interactions.subscriptions[tier]
		var tier_name: String
		match tier:
			RSUser.Interactions.SubTier.TIER1: tier_name = "Tier 1"
			RSUser.Interactions.SubTier.TIER2: tier_name = "Tier 2"
			RSUser.Interactions.SubTier.TIER3: tier_name = "Tier 3"
		add_counter_entry_to_node(%vb_subscriptions, tier_name, val)


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
		child.queue_free()
	
	%btn_expand_subscriptions.disabled = true
	%btn_expand_subscriptions.icon = CARET_RIGHT
	%btn_expand_subscriptions.button_pressed = false
	%vb_subscriptions.hide()
	for child in %vb_subscriptions.get_children():
		child.queue_free()


func add_counter_entry_to_node(node: Control, key: String, val: int) -> void:
	var hb: HBoxContainer = HBoxContainer.new()
	var ln: LineEdit = LineEdit.new()
	ln.text = str(val)
	ln.editable = false
	var lb: Label = Label.new()
	lb.text = key
	lb.clip_text = true
	lb.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	lb.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hb.add_child(ln)
	hb.add_child(lb)
	node.add_child(hb)


#region Setters
func _set_is_global_interactions(val: bool) -> void:
	if is_global_interactions == val:
		return
	is_global_interactions = val
	_populate()
	if %ck_global.button_pressed != is_global_interactions:
		%ck_global.button_pressed = is_global_interactions


func _set_user(_user: RSUser) -> void:
	if user == _user: return
	clear()
	if not _user: return
	user = _user
	_populate()
#endregion


func _on_user_interactions_updated(user_id: int) -> void:
	if !user: return
	if user.user_id == user_id:
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
