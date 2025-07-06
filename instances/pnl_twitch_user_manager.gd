# pgorley is the best

#download carbrix now
extends PanelContainer

@onready var tabs = %tabs
@onready var ln_chat_live_streamer = %ln_chat_live_streamer

var user: RSUser
var live_data: TwitchStream

@onready var pnl_rs_twitch_user_info = %pnl_rs_twitch_user_info
@onready var pnl_live: PanelContainer = %pnl_live
@onready var stream_title: Label = %stream_title
@onready var btn_stream_title: Button = %btn_stream_title
@onready var stream_thumbnail: TextureRect = %stream_thumbnail
@onready var stream_time: Label = %stream_time
@onready var stream_viewer_count: Label = %stream_viewer_count


func _ready():
	set_process(false)


func start():
	#%pnl_connect_to_gift.start()
	reset_pnl_live()
	set_tab_names()


func set_tab_names():
	for pnl in tabs.get_children():
		var tab_title = pnl.name.trim_prefix("pnl_").capitalize()
		tabs.set_tab_title(pnl.get_index(), tab_title)


func populate_fields(_user: RSUser, _live_data: TwitchStream):
	user = _user
	live_data = _live_data
	%pnl_rs_twitch_user_info.user = _user
	update_live_fields()


func update_live_fields():
	set_process(live_data != null)
	var live_tab_idx = tabs.get_tab_idx_from_control(pnl_live)
	var info_tab_idx = tabs.get_tab_idx_from_control(pnl_rs_twitch_user_info)
	tabs.set_tab_disabled(live_tab_idx, live_data == null)
	tabs.current_tab = live_tab_idx if live_data else info_tab_idx
	
	if not live_data:
		reset_pnl_live()
		return
	
	stream_title.text = live_data.title
	btn_stream_title.disabled = false
	stream_viewer_count.text = str(live_data.viewer_count)
	var thumbnail_url = live_data.thumbnail_url.format({"width": 640, "height": 360})
	stream_thumbnail.texture = await RS.loader.load_texture_from_url(thumbnail_url, false)

func reset_pnl_live():
	stream_title.text = "Stream title"
	btn_stream_title.disabled = true
	stream_viewer_count.text = "0"
	stream_thumbnail.texture = null


var ticks := 0
func process_stream_time_elapsed():
	if not live_data:
		set_process(false)
		return
	
	ticks += 1
	if ticks < 30: return
	ticks = 0
	
	var system_unix = Time.get_unix_time_from_system()
	var stream_start_unix = Time.get_unix_time_from_datetime_string(live_data.started_at)
	var time_elapsed_string = Time.get_datetime_string_from_unix_time((system_unix - stream_start_unix), true)
	if stream_time:
		stream_time.text = time_elapsed_string.split(" ")[1]


func _process(_d):
	process_stream_time_elapsed()


func check_param_and_add_inspector(params: RSBeansParam):
	clear_param_inspector()
	%btn_add_custom_beans.button_pressed = false
	if params == null: return
	
	var param_inspector = RSGlobals.param_inspector_pack.instantiate()
	%sub_res.add_child(param_inspector)
	param_inspector.owner = owner
	param_inspector.params = params
	btn_custom_beans_is_gui_input = false
	%btn_add_custom_beans.button_pressed = true
func clear_param_inspector():
	#%btn_add_custom_beans.button_pressed = false
	for child in %sub_res.get_children():
		child.queue_free()


#func user_from_fields() -> RSUser:
	#var user_from_field := RSUser.new()
	#user_from_field.username = %ln_username.text
	#user_from_field.display_name = %ln_display_name.text
	#user_from_field.user_id = %ln_user_id.text as int
	#user_from_field.profile_image_url = %ln_profile_picture_url.text
	#
	#user_from_field.is_streamer = %fl_is_streamer.button_pressed
	#user_from_field.auto_shoutout = %fl_auto_shoutout.button_pressed
	#user_from_field.auto_promotion = %fl_auto_promotion.button_pressed
	#
	#user_from_field.custom_chat_color = %btn_custom_color.color
	#user_from_field.custom_notification_sfx = %opt_custom_sfx.get_item_text(%opt_custom_sfx.selected)
	#user_from_field.custom_action = %opt_custom_actions.get_item_text(%opt_custom_actions.selected)
	##-----------------------------
	#user_from_field.custom_beans_params = null
	#if %btn_add_custom_beans.button_pressed:
		#var param_inspector: RSParamInspector = %sub_res.get_child(0)
		#user_from_field.custom_beans_params = param_inspector.get_params()
	#
	#user_from_field.shoutout_description = %te_so.text
	#user_from_field.promotion_description = %te_promote.text
	#return user_from_field


#func update_user():
	#var updated_user = user_from_fields()
	#RS.user_mng.save_user(updated_user)
	# TODO: update the user list after updating the user json file
	#await RS.load_known_user(updated_user.username)
	#new_user_file.emit()


func search_user(_username: String):
	# TODO: What do I need search user for?
	pass


func _on_opt_custom_sfx_item_selected(index):
	%sfx_prev.stop()
	var sfx_name = %opt_custom_sfx.get_item_text(index)
	%sfx_prev.stream = RS.loader.load_sfx_from_sfx_folder(sfx_name)
	%sfx_prev.play()
# TODO:
#func _on_btn_open_file_pressed():
	#OS.shell_open(RS.settings.get_user_filepath(%ln_username.text))
func _on_btn_open_folder_pressed():
	OS.shell_open(RSSettings.get_users_path())

func _on_btn_raid_current_pressed():
	if not live_data: return
	RS.twitcher.raid(live_data.user_id)


# ==============================================================================
#func set_do_it(val):
	#do_it = val
	#return
	##add_res_picker($scroll/vb/grid_custom/dummy1, "ImageToRigidParam")
	#add_editor_inspector(%inspector)
#
#
#func add_res_picker(node_to_replace: Control, resource_type := ""):
	#var to_node = node_to_replace.get_parent()
	#var replace_pos = node_to_replace.get_index()
	#node_to_replace.queue_free()
	#
	#var res_picker = EditorResourcePicker.new()
	#res_picker.base_type = resource_type
	#res_picker.editable = true
	##res_picker.resource_selected.connect(EditorInterface.edit_resource.unbind(1))
	#to_node.add_child(res_picker)
	#to_node.move_child(res_picker, replace_pos)
	#res_picker.owner = self
#
#func add_editor_inspector(node_to_replace: Control):
	#var to_node = node_to_replace.get_parent()
	#var replace_pos = node_to_replace.get_index()
	#node_to_replace.queue_free()
	#
	#var ed_insp = EditorInterface.get_inspector().duplicate()
	#to_node.add_child(ed_insp)
	#to_node.move_child(ed_insp, replace_pos)
	#ed_insp.owner = self
#
#func _on_res_picker_resource_selected(resource, _inspect):
	##%res_insp.resource = resource
	##%inspector.edited_object == (resource)
	#EditorInterface.edit_resource(resource)
	##EditorInspector.edited_object()

func add_param_inspector():
	if %sub_res.get_child_count() > 0: return
	if user.custom_beans_params != null:
		check_param_and_add_inspector(user.custom_beans_params)
	else:
		check_param_and_add_inspector(RSBeansParam.from_json(RSGlobals.PARAMS_CANS))
	#var param_inspector: RSParamInspector = RSGlobals.param_inspector_pack.instantiate()
	#%sub_res.add_child(param_inspector)
	#param_inspector.owner = owner
	#param_inspector.params = RSGlobals.params_can

var btn_custom_beans_is_gui_input := true
func _on_btn_add_custom_beans_toggled(toggled_on):
	%sub_res.visible = toggled_on
	if not btn_custom_beans_is_gui_input:
		btn_custom_beans_is_gui_input = true
		return
	if toggled_on:
		add_param_inspector()
	else:
		clear_param_inspector()


#func _on_btn_test_beans_pressed():
	#var _user := user_from_fields()
	#if !_user.username.is_empty():
		#RS.custom.beans(_user.username)


func _on_stream_title_pressed():
	OS.shell_open("https://www.twitch.tv/%s"%user.username)
func _on_ln_chat_live_streamer_text_submitted(new_text):
	ln_chat_live_streamer.clear()
	if !live_data: return
	RS.twitcher.chat(new_text, live_data.user_login)
