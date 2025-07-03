extends PanelContainer
class_name PnlRSTwitchUserInfo

var user: RSTwitchUser: set = set_user


func _ready() -> void:
	# populate Work With option button
	for id: int in RSTwitchUser.WorkWith.size():
		%opt_work_with.add_item(RSTwitchUser.WorkWith.keys()[id], id)


func set_user(_user: RSTwitchUser) -> void:
	if user == _user:
		return
	user = _user
	populate_info()


func populate_info() -> void:
	%tex_profile_pic.texture = await RS.loader.load_texture_from_url(user.profile_image_url)
	%ln_username.text = user.username
	%ln_display_name.text = user.display_name
	%ln_user_id.text = str(user.user_id)
	%ln_profile_picture_url.text = user.profile_image_url
	%cr_user_twitch_irc_color.color = user.twitch_chat_color
	
	%fl_is_streamer.button_pressed = user.is_streamer
	%fl_auto_shoutout.button_pressed = user.auto_shoutout
	%fl_auto_promotion.button_pressed = user.auto_promotion
	
	%btn_custom_color.color = user.custom_chat_color
	RSUtl.opt_btn_select_from_text(%opt_custom_sfx, user.custom_notification_sfx)
	RSUtl.opt_btn_select_from_text(%opt_custom_actions, user.custom_action)
	
	check_param_and_add_inspector(user.custom_beans_params)
	#clear_param_inspector()
	%btn_add_custom_beans.button_pressed = user.custom_beans_params != null
		
	%te_so.text = user.shoutout_description
	%te_promote.text = user.promotion_description


func clear_custom_fields():
	%fl_is_streamer.button_pressed = false
	%fl_auto_shoutout.button_pressed = false
	%fl_auto_promotion.button_pressed = false
	%btn_custom_color.color = Color()
	%opt_custom_sfx.selected = 0
	#%opt_custom_beans.selected = 0
	%opt_custom_actions.selected = 0
	%te_so.text = ""
	%te_promote.text = ""


#region Inspector Signals
func _on_btn_save_pressed() -> void:
	pass # Replace with function body.
func _on_btn_reload_pressed() -> void:
	pass # Replace with function body.
func _on_btn_open_file_pressed() -> void:
	pass # Replace with function body.
#endregion


func _on_btn_delete_pressed() -> void:
	pass # Replace with function body.
