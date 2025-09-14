extends PanelContainer
class_name PnlUserBeans

const entry_bean_pack = preload("res://instances/entries/entry_bean.tscn")
var user: RSUser: set = _set_user


func _ready() -> void:
	pass


func _set_user(_user: RSUser) -> void:
	if user == _user: return
	user = _user
	update()


func update() -> void:
	_populate_opt_available_beans()
	if not user:
		clear()
		return


func _populate_opt_available_beans() -> void:
	pass


func clear() -> void:
	for child: Control in %flow.get_children():
		child.free()
	%opt_available_beans.clear()


func _on_btn_add_beans_pressed() -> void:
	pass # Replace with function body.


func _on_btn_open_bean_editor_pressed() -> void:
	RS.pnl_settings.pnl_users_mng.tabs.current_tab = 2
