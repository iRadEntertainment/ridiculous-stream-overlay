extends PanelContainer
class_name PnlTwitchUserInfo

const CARETS_TEX = [
	preload("res://ui/icons/bootstrap_icons/caret-left-fill.png"),
	preload("res://ui/icons/bootstrap_icons/caret-right-fill.png"),
]
@export var expanded: bool = true

var is_extra_panel_expanded: bool
var tw_expand: Tween

var t_user: TwitchUser
var user: RSUser


func _ready() -> void:
	toggle_extra_panel(expanded)
	%pnl_loading_simple.hide()


func populate_from_twitch_user(_t_user: TwitchUser) -> void:
	%pnl_loading_simple.show()
	clear()
	t_user = _t_user
	if not t_user: return
	%ln_username.text = t_user.login
	%ln_display_name.text = t_user.display_name
	%ln_user_id.text = t_user.id
	%ln_profile_picture_url.text = t_user.profile_image_url
	if t_user.profile_image_url:
		%tex_profile_pic.texture = await RS.loader.load_texture_from_url(t_user.profile_image_url)
	else:
		%tex_profile_pic.texture = preload("res://ui/sprites/twitch_user_profile_pic.png")
	
	%ln_type.text = t_user.type
	%ln_description.text = t_user.description
	%ln_broadcaster_type.text = t_user.broadcaster_type
	%ln_offline_image_url.text = t_user.offline_image_url
	%ln_view_count.text = str(t_user.view_count)
	%pnl_loading_simple.hide()


func populate_from_rs_user(_rs_user: RSUser) -> void:
	clear()
	user = _rs_user
	if not user: return
	%ln_username.text = user.username
	%ln_display_name.text = user.display_name
	%ln_user_id.text = str(user.user_id)
	%ln_profile_picture_url.text = user.profile_image_url
	%cr_user_twitch_irc_color.color = user.twitch_chat_color
	if user.profile_image_url:
		%tex_profile_pic.texture = await RS.loader.load_texture_from_url(user.profile_image_url)
	else:
		%tex_profile_pic.texture = preload("res://ui/sprites/twitch_user_profile_pic.png")
	
	%ln_description.text = user.description
	%ln_broadcaster_type.text = user.broadcaster_type
	%ln_offline_image_url.text = user.offline_image_url


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


func _on_btn_update_twitch_info_pressed() -> void:
	%pnl_loading_simple.show()
	var user_id: int
	if user: user_id = user.user_id
	elif t_user: user_id = int(t_user.id)
	if not user_id: return
	
	var new_t_user: TwitchUser = await RS.user_mng.get_t_user_from_twitch_api(user_id)
	if not new_t_user:
		clear()
		return
	t_user = new_t_user
	populate_from_twitch_user(t_user)
	if user:
		user.update_from_twitch_user(t_user)
		RS.user_mng.save_user(user)
	%pnl_loading_simple.hide()
