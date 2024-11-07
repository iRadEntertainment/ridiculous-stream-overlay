
extends PanelContainer


@onready var btn_cont = %btn_cont


func start():
	pass


func _on_btn_expand_pressed():
	btn_cont.visible = !btn_cont.visible


func _on_btn_zero_g_pressed():
	RS.custom.zero_g()
func _on_btn_laser_pressed():
	RS.custom.laser()
