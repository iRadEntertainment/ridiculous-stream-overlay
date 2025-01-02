extends PanelContainer

var settings: RSSettings


func _ready() -> void:
	hide()


func start() -> void:
	%pnl_loggers.settings = settings
	%pnl_loggers.start()
	show()


func _on_btn_debug_mode_done_pressed() -> void:
	hide()
