@tool
extends EditorPlugin

func _enter_tree() -> void:
	_configure_setting("ridiculous_stream/twitch/publish", false);
	_configure_setting("ridiculous_stream/twitch/grant_type", OAuth.AuthorizationFlow.keys()[OAuth.AuthorizationFlow.IMPLICIT_FLOW]);
	_configure_setting("ridiculous_stream/twitch/client_id", "");
	_configure_setting("ridiculous_stream/twitch/redirect_uri", "http://localhost:7170");

	add_control_to_container(
		EditorPlugin.CONTAINER_PROJECT_SETTING_TAB_RIGHT,
		preload("res://addons/ridiculous_stream_project_settings/settings/pnl_ridiculous_stream_project_settings.tscn").instantiate()
	);

func _configure_setting(p_setting_name: String, p_default_value: Variant) -> void:
	if !ProjectSettings.has_setting(p_setting_name):
		ProjectSettings.set_setting(p_setting_name, p_default_value);
	ProjectSettings.set_initial_value(p_setting_name, p_default_value);
	ProjectSettings.set_as_internal(p_setting_name, true);
