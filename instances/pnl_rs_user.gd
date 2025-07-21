extends PanelContainer
class_name PnlRSUser

var user: RSUser: set = set_user


func _ready() -> void:
	update_dropdown_fields()
	toggle_tool_button(false)
	%pnl_games.pnl_steam_app_info = %pnl_steam_app_info
	%pnl_games.pnl_itchio_app_info = %pnl_itchio_app_info


func set_user(_user: RSUser) -> void:
	if user == _user:
		return
	user = _user
	var is_user_null: bool = user == null
	toggle_tool_button(!is_user_null)
	populate_info()


func toggle_tool_button(val: bool) -> void:
	for btn: Button in %hb_tools.get_children():
		btn.disabled = !val


func populate_info() -> void:
	if not user: return
	%pnl_games.user = user
	%pnl_twitch_user_info.populate_from_rs_user(user)
	
	%fl_is_streamer.button_pressed = user.is_streamer
	%fl_auto_shoutout.button_pressed = user.auto_shoutout
	%fl_auto_promotion.button_pressed = user.auto_promotion
	
	%btn_custom_color.color = user.custom_chat_color
	RSUtl.opt_btn_select_from_text(%opt_custom_sfx, user.custom_notification_sfx)
	RSUtl.opt_btn_select_from_text(%opt_custom_actions, user.custom_action)
	
	%opt_work_with.select(user.work_with)
	%ln_youtube_handle.text = user.youtube_handle
	%ln_bluesky_handle.text = user.bluesky_handle
	%ln_website.text = user.website
	%te_so.text = user.shoutout_description
	%te_promote.text = user.promotion_description
	
	%ln_added_on.text = RSUtl.unix_to_string(user.added_on, false, false)
	%ln_tot_messages.text = str(user.messages_count)
	%ln_tot_redeems.text = str(user.redeems_count)
	%ln_tot_raids_in.text = str(user.raids_in_count)
	%ln_tot_raids_out.text = str(user.raids_out_count)
	
	# TODO: Add custom beans part
	%pnl_user_beans.populate_from_user(user)
	if user.offline_image_url.is_empty():
		%bg_img.texture = null
	else:
		%bg_img.texture = await RS.loader.load_texture_from_url(user.offline_image_url)


func clear() -> void:
	%pnl_twitch_user_info.clear()
	
	%fl_is_streamer.button_pressed = false
	%fl_auto_shoutout.button_pressed = false
	%fl_auto_promotion.button_pressed = false
	
	%btn_custom_color.color = Color()
	%opt_custom_sfx.selected = 0
	%opt_custom_actions.selected = 0
	
	%opt_work_with.select(-1)
	%ln_youtube_handle.text = ""
	%ln_bluesky_handle.text = ""
	%ln_website.text = ""
	%te_so.text = ""
	%te_promote.text = ""
	
	%ln_added_on.text = ""
	%ln_tot_messages.text = ""
	%ln_tot_redeems.text = ""
	%ln_tot_raids_in.text = ""
	%ln_tot_raids_out.text = ""
	
	%pnl_user_beans.populate_from_user(user)


func apply_edits_to_user() -> void:
	user.is_streamer = %fl_is_streamer.button_pressed
	user.auto_shoutout = %fl_auto_shoutout.button_pressed
	user.auto_promotion = %fl_auto_promotion.button_pressed
	
	user.custom_chat_color = %btn_custom_color.color
	RSUtl.opt_btn_select_from_text(%opt_custom_sfx, user.custom_notification_sfx)
	RSUtl.opt_btn_select_from_text(%opt_custom_actions, user.custom_action)
	
	user.work_with = %opt_work_with.selected
	user.youtube_handle = %ln_youtube_handle.text
	user.bluesky_handle = %ln_bluesky_handle.text
	user.website = %ln_website.text
	user.shoutout_description = %te_so.text
	user.promotion_description = %te_promote.text
	
	# TODO: Update user from beans panel
	#%pnl_user_beans.populate_from_user(user)

#region Utilities
func update_dropdown_fields():
	# populate Work With option button
	for id: int in RSUser.WorkWith.size():
		%opt_work_with.add_item(RSUser.WorkWith.keys()[id], id)
	
	# SFX paths
	var sfx_paths: Array[String] = [RSSettings.get_sfx_path(), RSSettings.LOCAL_RES_FOLDER]
	RSUtl.populate_opt_btn_from_files_in_folder(%opt_custom_sfx, sfx_paths, ["ogg"])
	
	# Custom functions from RSCustom.gd
	var rs_custom_filepath: String = "res://classes/RSCustom.gd"
	var exclude: Array[String] = ["start", "discord"]
	var exclude_begin_with: String = "on_"
	var functions: Array[String] = RSUtl.get_methods_from_script(
		rs_custom_filepath,
		exclude,
		exclude_begin_with
	)
	RSUtl.opt_btn_populate_from_list(%opt_custom_actions, functions)
#endregion


#region Inspector Signals
func _on_btn_save_pressed() -> void:
	apply_edits_to_user()
	RS.user_mng.save_user(user)
func _on_btn_reload_pressed() -> void:
	var filepath: String = RSUserMng.get_filename_from_user_id(user.user_id, RS.user_mng.folder)
	user = RSUserMng.load_user_from_json(filepath)
func _on_btn_open_file_pressed() -> void:
	var filepath: String = RSUserMng.get_filename_from_user_id(user.user_id, RS.user_mng.folder)
	OS.shell_open(RS.user_mng.folder + filepath)
func _on_btn_delete_pressed() -> void:
	RS.user_mng.delete_user(user)
	clear()
func _on_btn_yt_promo_pressed() -> void:
	var msg: String = "Check out {user}'s YouTube channel: {link}"
	var param: Dictionary = {
		"user": user.display_name,
		"link": "youtube.com/" + user.youtube_handle,
	}
	RS.twitcher.announcement(msg.format(param))
func _on_btn_bsky_promo_pressed() -> void:
	var msg: String = "Follow {user} on BlueSky: {link}"
	var param: Dictionary = {
		"user": user.display_name,
		"link": "bsky.app/profile/" + user.bluesky_handle.trim_prefix("@") + ".bsky.social",
	}
	RS.twitcher.announcement(msg.format(param))
func _on_btn_web_promo_pressed() -> void:
	var msg: String = "Check out {user}'s website: {link}"
	var param: Dictionary = {
		"user": user.display_name,
		"link": user.website,
	}
	RS.twitcher.announcement(msg.format(param))
#endregion


#region Fields Validation
func _on_ln_youtube_handle_text_submitted(new_text: String) -> void:
	%ln_youtube_handle.text = RSUtl.validate_handle(new_text)
func _on_ln_youtube_handle_focus_exited() -> void:
	%ln_youtube_handle.text = RSUtl.validate_handle(%ln_youtube_handle.text)
func _on_ln_bluesky_handle_text_submitted(new_text: String) -> void:
	%ln_bluesky_handle.text = RSUtl.validate_handle(%ln_bluesky_handle.text)
func _on_ln_bluesky_handle_focus_exited() -> void:
	%ln_bluesky_handle.text = RSUtl.validate_handle(%ln_bluesky_handle.text)
#endregion
