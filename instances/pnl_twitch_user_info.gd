extends PanelContainer
class_name PnlTwitchUserInfo

const CARETS_TEX = [
	preload("res://ui/bootstrap_icons/caret-left-fill.png"),
	preload("res://ui/bootstrap_icons/caret-right-fill.png"),
]

var is_extra_panel_expanded: bool
var tw_expand: Tween


func populate_from_twitch_user(user: TwitchUser) -> void:
	clear()
	if not user: return
	OptionButton
	%ln_username.text = user.login
	%ln_display_name.text = user.display_name
	%ln_user_id.text = user.id
	%ln_profile_picture_url.text = user.profile_image_url
	if user.profile_image_url:
		%tex_profile_pic.texture = await RS.loader.load_texture_from_url(user.profile_image_url)
	
	%ln_type.text = user.type
	%ln_description.text = user.description
	%ln_broadcaster_type.text = user.broadcaster_type
	%ln_offline_image_url.text = user.offline_image_url
	%ln_view_count.text = str(user.view_count)


func populate_from_rs_user(user: RSUser) -> void:
	clear()
	if not user: return
	%ln_username.text = user.username
	%ln_display_name.text = user.display_name
	%ln_user_id.text = str(user.user_id)
	%ln_profile_picture_url.text = user.profile_image_url
	%cr_user_twitch_irc_color.color = user.twitch_chat_color
	if user.profile_image_url:
		%tex_profile_pic.texture = await RS.loader.load_texture_from_url(user.profile_image_url)


func clear() -> void:
	%tex_profile_pic.texture = null
	%ln_username.text = ""
	%ln_display_name.text = ""
	%ln_user_id.text = ""
	%ln_profile_picture_url.text = ""
	%cr_user_twitch_irc_color.color = Color.TRANSPARENT
	
	%ln_type.text = ""
	%ln_description.text = ""
	%ln_broadcaster_type.text = ""
	%ln_offline_image_url.text = ""
	%ln_view_count.text = ""


func toggle_extra_panel(val: bool) -> void:
	is_extra_panel_expanded = val
	%btn_expand.icon = CARETS_TEX[0] if is_extra_panel_expanded else CARETS_TEX[1]
	var min_size_x: float = 400 if is_extra_panel_expanded else 0
	if tw_expand:
		tw_expand.kill()
	%pnl_expand.show()
	tw_expand = create_tween()
	tw_expand.set_ease(Tween.EASE_OUT)
	tw_expand.set_trans(Tween.TRANS_CUBIC)
	tw_expand.tween_property(%pnl_expand, ^"custom_minimum_size:x", min_size_x, 0.3)
	if !is_extra_panel_expanded:
		tw_expand.tween_property(%pnl_expand, ^"visible", false, 0.0)


func _on_btn_expand_pressed() -> void:
	toggle_extra_panel(!is_extra_panel_expanded)
