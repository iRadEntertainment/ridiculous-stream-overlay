@tool
class_name PanelTwitchDeveloper
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
			if !scope_aggregator.scopes_changed.is_connected(_on_scopes_changed):
				scope_aggregator.scopes_changed.connect(_on_scopes_changed)
			_on_scopes_changed(scope_aggregator)

var settings: RSSettings:
	set(value):
		if value == settings: return
		settings = value
		_on_settings_changed(settings)

func _init() -> void:
	super._init(4)

func _ready() -> void:
	if settings: _on_settings_changed(settings)

func _on_settings_changed(p_settings: RSSettings) -> void:
	%hb_twitch_developer_client_secret/input.text = p_settings.client_secret
	%hb_twitch_developer_client_secret/btn_reset.disabled = p_settings.client_secret.is_empty()
	_on_twitch_developer_client_secret_input_text_changed(p_settings.client_secret)

	if !%hb_twitch_developer_grant_type/input.item_selected.is_connected(_on_twitch_developer_grant_type_selection_changed):
		%hb_twitch_developer_grant_type/input.item_selected.connect(_on_twitch_developer_grant_type_selection_changed)
	if p_settings.authorization_flow:
		%hb_twitch_developer_grant_type/input.selected = OAuth.AuthorizationFlow.get(p_settings.authorization_flow)
	else:
		var is_publish_mode := RSSettings.project_settings_twitch_publish
		if is_publish_mode:
			%hb_twitch_developer_grant_type/input.selected = OAuth.AuthorizationFlow.IMPLICIT_FLOW
		else:
			%hb_twitch_developer_grant_type/input.selected = OAuth.AuthorizationFlow.AUTHORIZATION_CODE_FLOW
	_on_twitch_developer_grant_type_selection_changed(%hb_twitch_developer_grant_type/input.selected)

	%hb_twitch_developer_client_id/input.placeholder_text = RSSettings.project_settings_twitch_client_id
	%hb_twitch_developer_client_id/input.text = "" if p_settings.client_id == RSSettings.project_settings_twitch_client_id else p_settings.client_id
	%hb_twitch_developer_client_id/btn_reset.disabled = p_settings.client_id.is_empty() or p_settings.client_id == RSSettings.project_settings_twitch_client_id
	_on_twitch_developer_client_id_input_text_changed(%hb_twitch_developer_client_id/input.text)

	%hb_twitch_developer_redirect_uri/input.placeholder_text = RSSettings.project_settings_twitch_redirect_uri
	%hb_twitch_developer_redirect_uri/input.text = "" if p_settings.redirect_url == RSSettings.project_settings_twitch_redirect_uri else p_settings.redirect_url
	%hb_twitch_developer_redirect_uri/btn_reset.disabled = p_settings.redirect_url.is_empty() or p_settings.redirect_url == RSSettings.project_settings_twitch_redirect_uri
	_on_twitch_developer_redirect_uri_input_text_changed(
		p_settings.redirect_url \
			if p_settings.redirect_url.is_empty() \
			else RSSettings.project_settings_twitch_redirect_uri
	)

func _on_scopes_changed(_p_scope_aggregator: ScopeAggregator) -> void:
	pass

func _on_twitch_developer_grant_type_selection_changed(p_index: int) -> void:
	%hb_twitch_developer_grant_type/btn_reset.disabled = p_index == RSSettings.project_settings_twitch_grant_type

	var require_client_secret := p_index != OAuth.AuthorizationFlow.IMPLICIT_FLOW
	%hb_twitch_developer_client_secret.visible = require_client_secret
	_required_valid_field_count = 3 if require_client_secret else 2

	if require_client_secret:
		_on_twitch_developer_client_secret_input_text_changed(settings.client_secret)
	else:
		_mark_field_valid("client_secret", false)

	settings.authorization_flow = OAuth.AuthorizationFlow.keys()[p_index]

func _on_twitch_developer_grant_type_reset_pressed() -> void:
	%hb_twitch_developer_grant_type/input.selected = RSSettings.project_settings_twitch_grant_type

func _on_twitch_developer_client_id_input_text_changed(new_text: String) -> void:
	if new_text: new_text = new_text.strip_edges()
	settings.client_id = RSSettings.project_settings_twitch_client_id if new_text.is_empty() else new_text
	%hb_twitch_developer_client_id/btn_reset.disabled = new_text == RSSettings.project_settings_twitch_client_id
	_mark_field_valid("client_id", settings.client_id.length() > 24)

func _on_twitch_developer_client_id_reset_pressed() -> void:
	%hb_twitch_developer_client_id/input.text = ""
	_on_twitch_developer_client_id_input_text_changed("")

func _on_twitch_developer_client_secret_input_text_changed(new_text: String) -> void:
	if new_text: new_text = new_text.strip_edges()
	settings.client_secret = new_text
	%hb_twitch_developer_client_secret/btn_reset.disabled = new_text.is_empty()
	_mark_field_valid("client_secret", settings.client_secret.length() > 24)

func _on_twitch_developer_client_secret_reset_pressed() -> void:
	%hb_twitch_developer_client_secret/input.text = ""
	_on_twitch_developer_client_secret_input_text_changed("")

func _on_twitch_developer_redirect_uri_input_text_changed(new_text: String) -> void:
	if new_text: new_text = new_text.strip_edges()
	settings.redirect_url = RSSettings.project_settings_twitch_redirect_uri if new_text.is_empty() else new_text
	%hb_twitch_developer_redirect_uri/btn_reset.disabled = new_text.is_empty() or new_text == RSSettings.project_settings_twitch_redirect_uri
	_mark_field_valid("redirect_uri", settings.redirect_url.length() > 7)

func _on_twitch_developer_redirect_uri_reset_pressed() -> void:
	%hb_twitch_developer_redirect_uri/input.text = ""
	_on_twitch_developer_redirect_uri_input_text_changed("")
