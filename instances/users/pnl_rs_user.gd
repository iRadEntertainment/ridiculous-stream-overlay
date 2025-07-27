extends PanelContainer
class_name PnlRSUser

var user: RSUser: set = set_user


func _ready() -> void:
	clear()
	_toggle_tool_button(false)


func set_user(_user: RSUser) -> void:
	if user == _user:
		return
	user = _user
	var is_user_null: bool = user == null
	_toggle_tool_button(!is_user_null)
	_populate()


func _populate() -> void:
	%pnl_twitch_user_info.populate_from_rs_user(user)
	%pnl_user_promo.user = user
	%pnl_user_customization.user = user
	%pnl_user_stats.user = user
	%pnl_games.user = user


func clear() -> void:
	%pnl_twitch_user_info.clear()
	%pnl_user_promo.clear()
	%pnl_user_customization.clear()
	%pnl_user_stats.clear()
	%pnl_games.clear()


#region Utilities
func _toggle_tool_button(val: bool) -> void:
	for btn: Button in %hb_tools.get_children():
		btn.disabled = !val
#endregion


#region Inspector Signals
func _on_btn_save_pressed() -> void:
	RS.user_mng.save_user(user)
func _on_btn_reload_pressed() -> void:
	var filepath: String = RSUserMng.get_filename_from_user_id(user.user_id, RS.user_mng.folder)
	user = RSUserMng.load_user_from_json(filepath)
func _on_btn_open_file_pressed() -> void:
	var filepath: String = RSUserMng.get_filename_from_user_id(user.user_id, RS.user_mng.folder)
	OS.shell_open(RS.user_mng.folder + filepath)
func _on_btn_delete_pressed() -> void:
	RS.user_mng.delete_user(user)
	user = null
#endregion
