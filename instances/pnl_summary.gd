extends PanelContainer
class_name PnlSummary

const TITLE_CENTER = "[font_size=50][center][b]%s[/b][/center][/font_size]"
const SUBTITLE_CENTER = "[font_size=32][center][b]%s[/b][/center][/font_size]"
const SUBTITLE_LEFT = "[font_size=32][b]%s[/b][/font_size]"
const TIME_HH_MM = "[font_size=32][b]{hour}:{minute}:{second}[/b][/font_size]"


var summary: RSSummaryMng.RSSummary:
	get: return RS.summary_mng.summary


func _ready() -> void:
	set_process(false)
	visibility_changed.connect(_on_visibility_changed)


func populate_with_summary() -> void:
	# clear containers
	for child: Control in %vb_raids.get_children() + %vb_cheers.get_children() + %vb_subs.get_children():
		child.free()
	
	var chatters_ids: Array[int] = summary.get_chatters_user_ids()
	var cheerers_ids: Array[int] = summary.get_cheerers_user_ids()
	var subscribers_ids: Array[int] = summary.get_subscribers_user_ids()
	var raiders_ids: Array[int] = summary.get_raiders_user_ids()
	
	var chatters: Array[RSUser]
	for user_id: int in chatters_ids:
		var user: RSUser = await RS.user_mng.get_user_from_user_id(user_id)
		chatters.append(user)
	
	var cheerers: Array[RSUser]
	for user_id: int in cheerers_ids:
		var user: RSUser = await RS.user_mng.get_user_from_user_id(user_id)
		cheerers.append(user)
		add_lb_name_to_container(%vb_cheers, user.display_name, user.twitch_chat_color)
	var subscribers: Array[RSUser]
	for user_id: int in subscribers_ids:
		var user: RSUser = await RS.user_mng.get_user_from_user_id(user_id)
		subscribers.append(user)
		add_lb_name_to_container(%vb_subs, user.display_name, user.twitch_chat_color)
	var raiders: Array[RSUser]
	for user_id: int in raiders_ids:
		var user: RSUser = await RS.user_mng.get_user_from_user_id(user_id)
		raiders.append(user)
		add_lb_name_to_container(%vb_raids, user.display_name, user.twitch_chat_color)
	
	
	
	# MAIN TEXT
	var space_before_after: int = 40
	%main_text.clear()
	# clear space
	for i: int in space_before_after:
		%main_text.newline()
	#%main_text.append_text(TITLE_CENTER % "Stream ending")
	#%main_text.newline()
	
	# stream duration
	var stream_length: int = int(Time.get_unix_time_from_system()) - summary.stream_start
	var time_dict: Dictionary = Time.get_datetime_dict_from_unix_time(stream_length)
	var stream_duration: String = "[font_size=32][b]{hour}:{minute}:{second}[/b][/font_size]".format(time_dict)
	%main_text.append_text(stream_duration)
	
	# Chatters
	%main_text.append_text(SUBTITLE_CENTER % "Chatters")
	%main_text.append_text("\n[font_size=32][b]")
	for user: RSUser in chatters:
		%main_text.append_text("\n%s" % user.display_name)
	%main_text.append_text("\n[/b][/font_size]")
	
	# clear space
	for i: int in space_before_after:
		%main_text.newline()
	%main_text.get_v_scroll_bar().hide()


var accumulator: float = 0.0
func _process(delta: float) -> void:
	var tot_scroll_sec: float = 120.0 # seconds
	var bar: VScrollBar = %main_text.get_v_scroll_bar()
	bar.hide()
	accumulator += delta * (bar.max_value / tot_scroll_sec)
	if accumulator > 1.0:
		var integer: float = floorf(accumulator)
		accumulator -= integer
		bar.value += integer
	#prints(bar.value, delta * (bar.max_value / tot_scroll_sec))


func add_lb_name_to_container(cont: Container, username: String, color := Color.WHITE) -> void:
	var lb_settings_big_names := LabelSettings.new()
	lb_settings_big_names.font = load("res://ui/fonts/source-code-pro/SourceCodePro-Black.otf")
	lb_settings_big_names.font_size = 28
	lb_settings_big_names.font_color = color
	var lb := Label.new()
	lb.text = username
	lb.label_settings = lb_settings_big_names
	cont.add_child(lb)


func _on_visibility_changed() -> void:
	%main_text.visible = is_visible_in_tree()
	set_process(is_visible_in_tree())
	if is_visible_in_tree():
		populate_with_summary()
		var bar: VScrollBar = %main_text.get_v_scroll_bar()
		bar.value = 0


func _on_btn_close_pressed() -> void:
	hide()
