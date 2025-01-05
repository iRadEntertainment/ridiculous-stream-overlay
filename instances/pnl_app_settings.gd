extends PanelFormContainer
class_name PanelAppSettings

var l := RSLogger.new(RSSettings.LOGGER_NAME_MAIN)

var settings: RSSettings:
	set(value):
		if value == settings: return
		settings = value
		_on_settings_changed()

func _init() -> void:
	super()

func start() -> void:
	if settings:
		_on_settings_changed()
	%ln_data_folder.text = RSSettings.data_dir
	%sl_window_scale.value = settings.app_scale


func _on_settings_changed() -> void:
	pass


func _on_btn_select_data_folder_pressed() -> void:
	var title = "Select or create the data folder"
	var start_dir = OS.get_data_dir()
	var mode = DisplayServer.FILE_DIALOG_MODE_OPEN_DIR
	DisplayServer.file_dialog_show(
		title, start_dir, "", true, mode, [], _on_file_dialog_folder_selected)
func _on_file_dialog_folder_selected(status: bool, selected_paths: PackedStringArray, _selected_filter_index: int) -> void:
	if !status: return
	var data_dir = selected_paths[0]
	RSSettings.data_dir = data_dir
	RSSettings._config.set_value("Ridiculous Stream", "data_dir", RSSettings.data_dir)
	RSSettings._config.save(RSSettings._CONFIG_PATH)
	l.i("Data folder set: %s | Saving to %s" % [RSSettings.data_dir, RSSettings._CONFIG_PATH])
	%ln_data_folder.text = data_dir


func _on_sl_window_scale_value_changed(value: float) -> void:
	%lb_window_scale.text = "%d%%" % (value*100)
func _on_sl_window_scale_drag_ended(_value_changed: bool) -> void:
	get_tree().root.content_scale_factor = %sl_window_scale.value
	settings.app_scale = %sl_window_scale.value