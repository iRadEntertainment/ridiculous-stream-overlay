extends PanelContainer
class_name PnlSummary

var summary: RSSummaryMng.RSSummary:
	get: return RS.summary_mng.summary
var duration_label: Label
var accumulator := 0.0
var _last_elapsed := -1
var _displayed_id := ""
var _refresh_queued := false

func _ready() -> void:
	duration_label = Label.new()
	duration_label.name = "StreamDuration"
	duration_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	duration_label.add_theme_font_size_override("font_size", 32)
	$vb.add_child(duration_label)
	$vb.move_child(duration_label, 1)
	visibility_changed.connect(_on_visibility_changed)
	RS.summary_mng.summary_changed.connect(_queue_refresh)
	_on_visibility_changed.call_deferred()

static func format_duration(seconds: int) -> String:
	seconds = maxi(0, seconds)
	@warning_ignore("integer_division")
	var hours: int = seconds / 3600
	@warning_ignore("integer_division")
	var minutes: int = (seconds / 60) % 60
	return "%02d:%02d:%02d" % [hours, minutes, seconds % 60]

func _update_duration() -> void:
	var elapsed := summary.elapsed_seconds() if summary != null else 0
	if elapsed != _last_elapsed:
		_last_elapsed = elapsed
		duration_label.text = "Stream duration: " + format_duration(elapsed)

func _queue_refresh() -> void:
	if not is_visible_in_tree() or _refresh_queued:
		return
	_refresh_queued = true
	_refresh.call_deferred()

func _refresh() -> void:
	_refresh_queued = false
	if is_visible_in_tree():
		populate_with_summary()

func _sorted_ids(ids: Array[int]) -> Array[int]:
	ids.sort_custom(func(a: int, b: int):
		return str(summary.get_identity(a).get("display_name", "")).naturalnocasecmp_to(str(summary.get_identity(b).get("display_name", ""))) < 0)
	return ids

func _name(user_id: int) -> String:
	var identity := summary.get_identity(user_id)
	var display_name := str(identity.get("display_name", ""))
	if display_name.is_empty():
		display_name = str(identity.get("username", ""))
	return display_name if not display_name.is_empty() else "User %d" % user_id

func _add_user(container: Container, user_id: int, detail: String) -> void:
	var identity := summary.get_identity(user_id)
	var color := Color.from_string(str(identity.get("color", "ffffff")), Color.WHITE)
	if color.a == 0:
		color = Color.WHITE
	add_lb_name_to_container(container, "%s — %s" % [_name(user_id), detail], color)

func populate_with_summary() -> void:
	var scroll: float = %main_text.get_v_scroll_bar().value
	for container: Container in [%vb_raids, %vb_cheers, %vb_subs]:
		for child in container.get_children():
			child.free()
	%main_text.clear()
	_update_duration()
	if summary == null:
		%main_text.add_text("No summary available.")
		return
	if _displayed_id != summary.id:
		_displayed_id = summary.id
		scroll = 0
		accumulator = 0
	for user_id in _sorted_ids(summary.get_raiders_user_ids()):
		var inter := summary.user_interactions[user_id]
		var detail := "%d raid(s)" % inter.raids_in_count
		if inter.raid_viewers_count > 0:
			detail += " · %d viewers" % inter.raid_viewers_count
		_add_user(%vb_raids, user_id, detail)
	for user_id in _sorted_ids(summary.get_cheerers_user_ids()):
		_add_user(%vb_cheers, user_id, "%d bits" % summary.user_interactions[user_id].bits_count)
	if summary.anonymous_bits > 0:
		add_lb_name_to_container(%vb_cheers, "Anonymous — %d bits" % summary.anonymous_bits)
	_add_subscription_section("Gift donors", summary.get_gifters_user_ids(), "gift_subscriptions_count", "gifted")
	var anonymous_gifts := RSUser.Interactions._sum(summary.anonymous_gift_subscriptions)
	if anonymous_gifts > 0:
		if summary.get_gifters_user_ids().is_empty():
			add_lb_name_to_container(%vb_subs, "Gift donors", Color.LIGHT_GRAY)
		add_lb_name_to_container(%vb_subs, "Anonymous — %d gifted" % anonymous_gifts)
	_add_subscription_section("Self subscriptions", summary.get_subscribers_user_ids(), "subscriptions_count", "subscription(s)")
	_add_subscription_section("Resub announcements", summary.get_resubscribers_user_ids(), "resubscriptions_count", "announcement(s)")
	_add_subscription_section("Earlier subscriptions (unclassified)", summary.get_legacy_subscribers_user_ids(), "legacy_subscriptions_count", "recorded")
	for container: Container in [%vb_raids, %vb_cheers, %vb_subs]:
		if container.get_child_count() == 0:
			add_lb_name_to_container(container, "None this session", Color.GRAY)

	%main_text.add_text("\n".repeat(40))
	%main_text.push_font_size(32)
	%main_text.push_bold()
	%main_text.add_text("Chatters\n")
	for user_id in _sorted_ids(summary.get_chatters_user_ids()):
		# Names are plain text, so brackets cannot inject BBCode.
		%main_text.add_text("\n" + _name(user_id))
	%main_text.pop()
	%main_text.pop()
	%main_text.add_text("\n".repeat(40))
	%main_text.get_v_scroll_bar().hide()
	%main_text.get_v_scroll_bar().set_deferred("value", scroll)

func _add_subscription_section(title: String, ids: Array[int], counter: String, unit: String) -> void:
	if ids.is_empty():
		return
	add_lb_name_to_container(%vb_subs, title, Color.LIGHT_GRAY)
	for user_id in _sorted_ids(ids):
		_add_user(%vb_subs, user_id, "%d %s" % [summary.user_interactions[user_id].get(counter), unit])

func _process(delta: float) -> void:
	_update_duration()
	var bar: VScrollBar = %main_text.get_v_scroll_bar()
	bar.hide()
	accumulator += delta * (bar.max_value / 120.0)
	if accumulator >= 1.0:
		var pixels := floorf(accumulator)
		accumulator -= pixels
		bar.value += pixels

func add_lb_name_to_container(container: Container, text: String, color := Color.WHITE) -> void:
	var settings := LabelSettings.new()
	settings.font = preload("res://ui/fonts/source-code-pro/SourceCodePro-Black.otf")
	settings.font_size = 28
	settings.font_color = color
	var label := Label.new()
	label.text = text
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.label_settings = settings
	container.add_child(label)

func _on_visibility_changed() -> void:
	if not is_node_ready():
		return
	%main_text.visible = is_visible_in_tree()
	set_process(is_visible_in_tree())
	if is_visible_in_tree():
		populate_with_summary()
		accumulator = 0
		%main_text.get_v_scroll_bar().set_deferred("value", 0)

func _on_btn_close_pressed() -> void:
	hide()
