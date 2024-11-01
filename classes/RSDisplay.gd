extends Node
class_name RSDisplay

var main: RSMain
var is_maximized := false

func start(_main: RSMain) -> void:
	main = _main
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	set_borderless_maximized(true)


func set_borderless_maximized(value: bool):
	is_maximized = value
	DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, value)
	if is_maximized:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		# thanks to Foolbox <3 and Giganzo
		var current_screen = DisplayServer.window_get_current_screen()
		var usable_rect = DisplayServer.screen_get_usable_rect(current_screen)
		DisplayServer.window_set_position(DisplayServer.screen_get_position(current_screen))
		DisplayServer.window_set_size(usable_rect.size)
