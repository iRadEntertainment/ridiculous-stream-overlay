extends PanelContainer
class_name PnlSearchTwitchUser

var t_user: TwitchUser:
	set(val):
		t_user = val
		update_buttons()

var username_search: String
var user_id_search: String


func _ready() -> void:
	clear()


func on_user_fetched(_t_user: TwitchUser) -> void:
	clear()
	if not _t_user:
		update_buttons()
		return
	%pnl_twitch_user_info.show()
	%pnl_twitch_user_info.populate_from_twitch_user(_t_user)
	t_user = _t_user
	update_buttons()


func clear() -> void:
	t_user = null
	%ln_search_username.text = ""
	%ln_search_user_id.text = ""
	%pnl_twitch_user_info.clear()
	%pnl_twitch_user_info.hide()


func update_buttons() -> void:
	if not t_user:
		%btn_save.visible = true
		%btn_save.disabled = true
		%btn_update.visible = false
		%btn_update.disabled = true
		return
	%btn_save.disabled = false
	%btn_update.disabled = false
	var is_user_known: bool = RS.user_mng.is_user_id_known(int(t_user.id))
	%btn_save.visible = !is_user_known
	%btn_update.visible = is_user_known


#region Inspector Signals
func _on_ln_search_username_text_submitted(new_text: String) -> void:
	if RS.twitcher.is_connected_to_twitch:
		username_search = new_text
		t_user = await RS.twitcher.get_user(username_search)
		on_user_fetched(t_user)
func _on_ln_search_user_id_text_submitted(new_text: String) -> void:
	if RS.twitcher.is_connected_to_twitch:
		user_id_search = new_text
		t_user = await RS.twitcher.get_user_by_id(user_id_search)
		on_user_fetched(t_user)

func _on_btn_save_pressed() -> void:
	if not t_user:
		return
	var user: RSUser = RSUser.from_twitcher_user(t_user)
	RS.user_mng.save_user(user)
	clear()
func _on_btn_update_pressed() -> void:
	if not t_user:
		return
	var user: RSUser = await RS.user_mng.get_user_from_user_id(int(t_user.id))
	if user:
		user.update_from_twitch_user(t_user)
		RS.user_mng.save_user(user)
		clear()
#endregion
