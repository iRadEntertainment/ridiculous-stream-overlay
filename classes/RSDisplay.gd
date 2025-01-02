extends Node
class_name RSDisplay

var l := RSLogger.new(RSSettings.LOGGER_NAME_DISPLAY)

var is_maximized := false

func start() -> void:
	get_window().mode = Window.MODE_WINDOWED;
	set_borderless_maximized(true);
	set_app_scale(RS.settings.app_scale);


func set_borderless_maximized(value: bool):
	var current_window := get_window();
	is_maximized = value;

	current_window.borderless = value;
	if is_maximized:
		current_window.mode = Window.MODE_WINDOWED;
		var current_screen := current_window.current_screen;
		# thanks to Foolbox <3 and Giganzo
		var usable_rect := DisplayServer.screen_get_usable_rect(current_screen)
		var screen_position := DisplayServer.screen_get_position(current_screen)

		print_debug("[RSDisplay] Moving window %d to %s and resizing it to %s" % [
			current_window.get_window_id(),
			screen_position,
			usable_rect.size,
		]);

		current_window.size = usable_rect.size;
		current_window.position = screen_position;

		print_debug("[RSDisplay] Moved window %d to %s and resized it to %s" % [
			current_window.get_window_id(),
			current_window.position,
			current_window.size,
		]);


func set_app_scale(_scale: float) -> void:
	get_tree().root.content_scale_factor = _scale
