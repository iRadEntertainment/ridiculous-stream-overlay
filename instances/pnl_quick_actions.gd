
extends PanelContainer

var main : RSMain

@onready var btn_cont = %btn_cont


func start(_main : RSMain):
	main = _main


func _on_btn_expand_pressed():
	btn_cont.visible = !btn_cont.visible


func _on_btn_zero_g_pressed():
	main.custom.zero_g()
func _on_btn_laser_pressed():
	main.custom.laser()
