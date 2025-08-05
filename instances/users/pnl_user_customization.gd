extends PanelContainer
class_name PnlUserCustomization


var user: RSUser: set = _set_user


func _ready() -> void:
	update_dropdown_fields()


func _populate() -> void:
	%btn_custom_color.color = user.custom_chat_color
	RSUtl.opt_btn_select_from_text(%opt_custom_sfx, user.custom_notification_sfx)
	RSUtl.opt_btn_select_from_text(%opt_custom_actions, user.custom_action)


func clear() -> void:
	%btn_custom_color.color = Color.TRANSPARENT
	%opt_custom_sfx.select(-1)
	%opt_custom_actions.select(-1)


func _toggle_btns(val: bool) -> void:
	%btn_custom_color.disabled = !val
	%opt_custom_sfx.disabled = !val
	%opt_custom_actions.disabled = !val


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


#region Inspector signals
func _on_btn_custom_color_color_changed(color: Color) -> void:
	if user: user.custom_chat_color = color
func _on_opt_custom_sfx_item_selected(_index: int) -> void:
	if user: user.custom_notification_sfx = %opt_custom_sfx.text
func _on_opt_custom_actions_item_selected(_index: int) -> void:
	if user: user.custom_action = %opt_custom_actions.text
#endregion
