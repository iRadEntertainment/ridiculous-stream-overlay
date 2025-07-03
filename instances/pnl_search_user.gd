extends PanelContainer
class_name PnlSearchTwitchUser

var user: RSTwitchUser
var username_search: String


func gather_username_info_from_api():
	clear()
	username_search = %ln_search.text
	user = await RS.twitcher.gather_user_info(username_search)
	if user:
		%ln_search_username.text = ""
		%ln_search_user_id.text = ""
		populate()
	check_save_update_btns()


func populate() -> void:
	%tex_profile_pic.texture = await RS.loader.load_texture_from_url(user.profile_image_url)
	%ln_username.text = user.username
	%ln_display_name.text = user.display_name
	%ln_user_id.text = str(user.user_id)
	%ln_profile_picture_url.text = user.profile_image_url


func clear() -> void:
	%tex_profile_pic.texture = null
	%ln_username.text = ""
	%ln_display_name.text = ""
	%ln_user_id.text = ""
	%ln_profile_picture_url.text = ""


func check_save_update_btns() -> void:
	var is_known: bool = username_search in RS.user_mng.known.keys()
	


func _on_ln_search_text_submitted(_new_text):
	if RS.twitcher.is_connected_to_twitch:
		gather_username_info_from_api()
func _on_btn_save_pressed() -> void:
	pass # Replace with function body.
func _on_btn_update_pressed() -> void:
	pass # Replace with function body.
