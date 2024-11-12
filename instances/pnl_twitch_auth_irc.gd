@tool
class_name PanelTwitchAuthIRC
extends PanelFormContainer

var scope_aggregator: ScopeAggregator:
	set(value):
		if value == scope_aggregator:
			print_debug("scope_aggregator unchanged")
			return
		if scope_aggregator:
			scope_aggregator.scopes_changed.disconnect(_on_scopes_changed)
		scope_aggregator = value
		if scope_aggregator:
			scope_aggregator.scopes_changed.connect(_on_scopes_changed)
			_on_scopes_changed(scope_aggregator)

var settings: RSSettings:
	set(value):
		if value == settings: return
		settings = value
		_on_settings_changed(settings)
		_on_scopes_changed(scope_aggregator)

@onready var chatbot_inputs_all: Array[Control] = [
	%input_twitch_chatbot_enabled,
	%input_twitch_chatbot_use_eventsub,
	%hb_twitch_chatbot_join_message/input,
	%hb_twitch_chatbot_main_channel/input,
]

@onready var chatbot_inputs_enabled: Array[Control] = [
	#%input_twitch_chatbot_use_eventsub, # TODO: Implement this and uncomment it
	%hb_twitch_chatbot_join_message/input,
	%hb_twitch_chatbot_main_channel/input,
]

func _init() -> void:
	super._init()

func _ready() -> void:
	if settings: _on_settings_changed(settings)

func _on_settings_changed(p_settings: RSSettings) -> void:
	%hb_twitch_auth_broadcaster_id/input.text = p_settings.broadcaster_id
	%hb_twitch_auth_broadcaster_name/input.text = p_settings.broadcaster_name
	%input_twitch_chatbot_enabled.set_pressed_no_signal(p_settings.chatbot_enabled)
	%input_twitch_chatbot_use_eventsub.set_pressed_no_signal(p_settings.chatbot_use_eventsub)
	%hb_twitch_chatbot_id/input.text = p_settings.chatbot_user_id
	%hb_twitch_chatbot_name/input.text = p_settings.chatbot_username
	%hb_twitch_chatbot_main_channel/input.text = p_settings.chatbot_channel if p_settings.chatbot_channel else p_settings.chatbot_username
	%hb_twitch_chatbot_join_message/input.text = p_settings.chatbot_join_message

func _on_scopes_changed(p_scope_aggregator: ScopeAggregator) -> void:
	if settings:
		for scope in p_scope_aggregator.scopes:
			if settings.twitch_scopes.find(scope) < 0:
				%hb_twitch_auth_broadcaster_id/input.text = "";
				%hb_twitch_auth_broadcaster_name/input.text = "";
				_on_twitch_auth_broadcaster_id_input_text_changed("");
				_on_twitch_auth_broadcaster_name_input_text_changed("");

func _on_btn_connect_to_twitch_pressed() -> void:
	%hb_twitch_auth_connect/btn_connect_to_twitch.disabled = true;

	for input in chatbot_inputs_enabled:
		if input is LineEdit:
			input.editable = false;
		else:
			input.disabled = true;

	var twitch_auth := await TwitchAuth.new(settings);
	await twitch_auth.login();

	var validation_response := await twitch_auth.validate();
	var user_login = validation_response.get("login");
	var user_id = validation_response.get("user_id");

	if not user_login is String \
		or user_login.is_empty() \
		or not user_id is String \
		or user_id.is_empty():
		push_error("Failed to authenticate and validate the access tokens")
		return;

	var broadcaster_name := str(user_login);
	var broadcaster_id := str(user_id);
	%hb_twitch_auth_broadcaster_name/input.text = broadcaster_name;
	_on_twitch_auth_broadcaster_name_input_text_changed(broadcaster_name);
	%hb_twitch_auth_broadcaster_id/input.text = broadcaster_id;
	_on_twitch_auth_broadcaster_id_input_text_changed(broadcaster_id);

	if %hb_twitch_chatbot_id/input.text.is_empty():
		%hb_twitch_chatbot_id/input.text = broadcaster_id;
	if %hb_twitch_chatbot_name/input.text.is_empty():
		%hb_twitch_chatbot_name/input.text = broadcaster_name;
	if %hb_twitch_chatbot_main_channel/input.text.is_empty():
		%hb_twitch_chatbot_main_channel/input.text = broadcaster_name;

	if settings.chatbot_enabled:
		for input in chatbot_inputs_enabled:
			if input is LineEdit:
				input.editable = true;
			else:
				input.disabled = false;

	%hb_twitch_auth_connect/btn_connect_to_twitch.disabled = false;

func _on_twitch_auth_broadcaster_name_input_text_changed(new_text: String) -> void:
	settings.broadcaster_name = new_text
	_update_chatbot_enablement()

func _on_twitch_auth_broadcaster_id_input_text_changed(new_text: String) -> void:
	settings.broadcaster_id = new_text
	_update_chatbot_enablement()

func _update_chatbot_enablement() -> void:
	var should_enable_chatbot_section := settings.broadcaster_name and settings.broadcaster_id
	%input_twitch_chatbot_enabled.disabled = !should_enable_chatbot_section

func _on_input_twitch_chatbot_enabled_toggled(toggled_on: bool) -> void:
	settings.chatbot_enabled = toggled_on
	for input in chatbot_inputs_enabled:
		if input is LineEdit:
			input.editable = toggled_on
		else:
			input.disabled = !toggled_on

	if settings.chatbot_use_eventsub:
		scope_aggregator.enable_feature("channel.chat.message", toggled_on)
		scope_aggregator.enable_feature("send-chat-message", toggled_on)
	else:
		scope_aggregator.enable_scope("chat:read", toggled_on)
		scope_aggregator.enable_scope("chat:edit", toggled_on)

	if toggled_on:
		_required_valid_field_count += 2
		_on_twitch_chatbot_name_input_text_changed(%hb_twitch_chatbot_name/input.text)
		_on_twitch_chatbot_id_input_text_changed(%hb_twitch_chatbot_id/input.text)
	else:
		_mark_field_valid("chatbot_username", false)
		_mark_field_valid("chatbot_user_id", false)
		_required_valid_field_count -= 2

func _on_input_twitch_chatbot_use_eventsub_toggled(toggled_on: bool) -> void:
	settings.chatbot_use_eventsub = toggled_on;

	scope_aggregator.enable_feature("send-chat-message", toggled_on);
	scope_aggregator.enable_feature("channel.chat.message", toggled_on);
	scope_aggregator.enable_scope("chat:edit", !toggled_on);
	scope_aggregator.enable_scope("chat:read", !toggled_on);


func _on_twitch_chatbot_use_different_pressed() -> void:
	pass # Replace with function body.

func _on_twitch_chatbot_name_input_text_changed(new_text: String) -> void:
	settings.chatbot_username = new_text;
	_mark_field_valid("chatbot_username", !new_text.is_empty());

func _on_twitch_chatbot_id_input_text_changed(new_text: String) -> void:
	settings.chatbot_user_id = new_text;
	_mark_field_valid("chatbot_user_id", !new_text.is_empty());

func _on_twitch_chatbot_join_message_input_text_changed(new_text: String) -> void:
	settings.chatbot_join_message = new_text \
		if !new_text.is_empty() \
		else %hb_twitch_chatbot_join_message/input.placeholder_text;

func _on_twitch_chatbot_main_channel_input_text_changed(new_text: String) -> void:
	settings.chatbot_channel = new_text;

func _presubmit(p_settings: RSSettings) -> void:
	p_settings.chatbot_join_message = _pick_chatbot_join_message(p_settings);
	p_settings.chatbot_channel = _pick_chatbot_channel(p_settings);

func _pick_chatbot_join_message(p_settings: RSSettings) -> String:
	var chatbot_join_message := p_settings.chatbot_join_message;
	if chatbot_join_message.is_empty():
		chatbot_join_message = %hb_twitch_chatbot_join_message/input.text;
	if chatbot_join_message.is_empty():
		chatbot_join_message = %hb_twitch_chatbot_join_message/input.placeholder_text;
	return chatbot_join_message;

func _pick_chatbot_channel(p_settings: RSSettings) -> String:
	var chatbot_channel := p_settings.chatbot_channel;
	if chatbot_channel.is_empty():
		chatbot_channel = %hb_twitch_chatbot_main_channel/input.text;
	if chatbot_channel.is_empty():
		chatbot_channel = %hb_twitch_chatbot_main_channel/input.placeholder_text;
	return chatbot_channel;
