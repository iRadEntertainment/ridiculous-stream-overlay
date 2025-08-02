extends PanelContainer
class_name PnlBeansEditor


func _ready() -> void:
	if RS.is_node_ready(): await RS.ready
	_populate()


func _populate() -> void:
	pass


func clear() -> void:
	pass


#region Inspector Signals

#endregion
