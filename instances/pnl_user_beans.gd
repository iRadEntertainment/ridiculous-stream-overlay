extends PanelContainer
class_name PnlUserBeans

const entry_bean_pack = preload("res://instances/entry_bean.tscn")
var user: RSUser


func populate_from_user(_user: RSUser) -> void:
	user = _user
	# TODO: PnlUserBeans


func clear() -> void:
	pass
