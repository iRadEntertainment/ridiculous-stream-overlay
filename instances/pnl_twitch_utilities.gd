extends PanelContainer


func _ready() -> void:
	connect_btn_tabs()


func connect_btn_tabs() -> void:
	for i: int in %hb_btns_tab.get_child_count():
		var btn: Button = %hb_btns_tab.get_child(i)
		btn.pressed.connect(_go_to_tab.bind(i))


func _go_to_tab(idx: int) -> void:
	%tabs.current_tab = idx
