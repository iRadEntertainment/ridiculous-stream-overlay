extends PanelContainer
class_name  PnlUserPromo


var user: RSUser: set = _set_user


func _ready() -> void:
	update_dropdown_fields()


func _populate() -> void:
	%fl_is_streamer.button_pressed = user.is_streamer
	%fl_auto_shoutout.button_pressed = user.auto_shoutout
	%fl_auto_promotion.button_pressed = user.auto_promotion
	%opt_work_with.select(user.work_with)
	%ln_youtube_handle.text = user.youtube_handle
	%ln_bluesky_handle.text = user.bluesky_handle
	%ln_website.text = user.website
	%te_so.text = user.shoutout_description
	%te_promote.text = user.promotion_description


func clear() -> void:
	%fl_is_streamer.button_pressed = false
	%fl_auto_shoutout.button_pressed = false
	%fl_auto_promotion.button_pressed = false
	%opt_work_with.select(-1)
	%ln_youtube_handle.text = ""
	%ln_bluesky_handle.text = ""
	%ln_website.text = ""
	%te_so.text = ""
	%te_promote.text = ""


func _toggle_btns(val: bool) -> void:
	%fl_is_streamer.disabled = !val
	%fl_auto_shoutout.disabled = !val
	%fl_auto_promotion.disabled = !val
	%opt_work_with.disabled = !val
	%ln_youtube_handle.editable = val
	%ln_bluesky_handle.editable = val
	%ln_website.editable = val
	%te_so.editable = val
	%te_promote.editable = val


func _set_user(_user: RSUser) -> void:
	if user == _user: return
	clear()
	_toggle_btns(user != null)
	if not _user:
		return
	user = _user
	_populate()


#region Utilities
func update_dropdown_fields() -> void:
	# populate Work With option button
	for id: int in RSUser.WorkWith.size():
		%opt_work_with.add_item(RSUser.WorkWith.keys()[id], id)
#endregion


#region Fields Validation
func _on_ln_youtube_handle_text_submitted(_new_text: String) -> void:
	%ln_youtube_handle.text = RSUtl.validate_handle(%ln_youtube_handle.text)
	if user: user.youtube_handle = %ln_youtube_handle.text
func _on_ln_youtube_handle_focus_exited() -> void:
	%ln_youtube_handle.text = RSUtl.validate_handle(%ln_youtube_handle.text)
	if user: user.youtube_handle = %ln_youtube_handle.text
func _on_ln_bluesky_handle_text_submitted(_new_text: String) -> void:
	%ln_bluesky_handle.text = RSUtl.validate_handle(%ln_bluesky_handle.text.trim_suffix(".bsky.social"))
	if user: user.bluesky_handle = %ln_bluesky_handle.text
func _on_ln_bluesky_handle_focus_exited() -> void:
	%ln_bluesky_handle.text = RSUtl.validate_handle(%ln_bluesky_handle.text.trim_suffix(".bsky.social"))
	if user: user.bluesky_handle = %ln_bluesky_handle.text
func _on_ln_website_text_submitted(_new_text: String) -> void:
	if user: user.website = %ln_website.text
func _on_ln_website_focus_exited() -> void:
	if user: user.website = %ln_website.text
#endregion


#region Inspector Signals
func _on_fl_is_streamer_toggled(toggled_on: bool) -> void:
	if user: user.is_streamer = toggled_on
func _on_fl_auto_shoutout_toggled(toggled_on: bool) -> void:
	if user: user.auto_shoutout = toggled_on
func _on_fl_auto_promotion_toggled(toggled_on: bool) -> void:
	if user: user.auto_promotion = toggled_on

func _on_opt_work_with_item_selected(index: int) -> void:
	if user: user.work_with = index as RSUser.WorkWith

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

func _on_te_so_focus_exited() -> void:
	if user: user.shoutout_description = %te_so.text
func _on_te_promote_focus_exited() -> void:
	if user: user.promotion_description = %te_promote.text
#endregion
