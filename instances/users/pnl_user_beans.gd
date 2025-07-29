extends PanelContainer
class_name PnlUserBeans

const entry_bean_pack = preload("res://instances/entries/entry_bean.tscn")
var user: RSUser


func populate_from_user(_user: RSUser) -> void:
	if user == _user: return
	user = _user
	# TODO: PnlUserBeans


func clear() -> void:
	pass
