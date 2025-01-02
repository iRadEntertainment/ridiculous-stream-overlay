extends PanelFormContainer
class_name PanelObsWs

var settings: RSSettings:
	set(value):
		if value == settings: return
		settings = value
		_on_settings_changed()

func _init() -> void:
	super()

func _ready() -> void:
	if settings:
		_on_settings_changed()


func _on_settings_changed() -> void:
	_required_valid_field_count = 3 if settings.obs_use_module else 0
	%ck_use_noobsws.button_pressed = settings.obs_use_module
	%ck_obs_autoconnect.button_pressed = settings.obs_autoconnect

	%ln_server_ip.editable = settings.obs_use_module
	%ln_server_port.editable = settings.obs_use_module
	%ln_server_secret.editable = settings.obs_use_module
	
	if settings.obs_use_module:
		%ln_server_ip.text = settings.obs_websocket_url
		_on_ln_server_ip_text_changed(%ln_server_ip.text)
		%ln_server_port.text = str(settings.obs_websocket_port)
		_on_ln_server_port_text_changed(%ln_server_port.text)
		%ln_server_secret.text = settings.obs_websocket_password
		_on_ln_server_secret_text_changed(%ln_server_secret.text)



func _on_ln_server_ip_text_changed(new_text:String) -> void:
	new_text = new_text.strip_edges()
	settings.obs_websocket_url = new_text
	_mark_field_valid("obs_server_ip", !settings.obs_websocket_url.is_empty())
func _on_ln_server_port_text_changed(new_text: String) -> void:
	new_text = new_text.strip_edges()
	settings.obs_websocket_port = int(new_text)
	_mark_field_valid("obs_server_port", settings.obs_websocket_port != 0)
func _on_ln_server_secret_text_changed(new_text: String) -> void:
	new_text = new_text.strip_edges()
	settings.obs_websocket_password = new_text
	_mark_field_valid("obs_server_secret", !settings.obs_websocket_password.is_empty())


func _on_btn_reset_ip_pressed() -> void:
	%ln_server_ip.text = ""
func _on_btn_reset_port_pressed() -> void:
	%ln_server_port.text = str(settings.obs_websocket_port)
func _on_btn_reset_secret_pressed() -> void:
	%ln_server_secret.text = settings.obs_websocket_password


func _on_ck_use_noobsws_toggled(toggled_on:bool) -> void:
	settings.obs_use_module = toggled_on
	_on_settings_changed()



func _on_ck_obs_autoconnect_toggled(toggled_on:bool) -> void:
	settings.obs_autoconnect = toggled_on
	_on_settings_changed()
