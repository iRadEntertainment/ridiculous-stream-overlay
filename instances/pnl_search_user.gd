extends PanelContainer
class_name PnlSearchTwitchUser

var user: TwitchUser:
	set(val):
		user = val
		update_buttons()

var username_search: String
var user_id_search: String


func _ready() -> void:
	update_buttons()


func on_user_fetched(user: TwitchUser) -> void:
	%pnl_twitch_user_info.clear()
	if not user:
		return
	%ln_search_username.text = ""
	%ln_search_user_id.text = ""
	%pnl_twitch_user_info.populate_from_twitch_user(user)


func update_buttons() -> void:
	if not user:
		%btn_save.visible = true
		%btn_save.disabled = true
		%btn_update.visible = false
		%btn_update.disabled = true
		return
	%btn_save.disabled = false
	%btn_update.disabled = false
	var is_user_known: bool = RS.user_mng.is_user_id_known(int(user.id))
	%btn_save.visible = !is_user_known
	%btn_update.visible = is_user_known


#region Inspector Signals
func _on_ln_search_username_text_submitted(new_text: String) -> void:
	if RS.twitcher.is_connected_to_twitch:
		username_search = new_text
		user = await RS.twitcher.get_user(username_search)
		on_user_fetched(user)
func _on_ln_search_user_id_text_submitted(new_text: String) -> void:
	if RS.twitcher.is_connected_to_twitch:
		user_id_search = new_text
		user = await RS.twitcher.get_user_by_id(user_id_search)
		on_user_fetched(user)

func _on_btn_save_pressed() -> void:
	pass # Replace with function body.
func _on_btn_update_pressed() -> void:
	pass # Replace with function body.
#endregion
