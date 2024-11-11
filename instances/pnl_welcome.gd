@tool
class_name PanelWelcome
extends Control

const Features = preload("res://ui/twitch/features.gd")

signal completed()

var settings: RSSettings
var scope_aggregator := ScopeAggregator.new()

var _form_containers: Array[PanelFormContainer] = []
var _completed_form_containers := {}

var _all_forms_completed: bool:
	get: return _completed_form_containers.size() >= _form_containers.size()

func _ready() -> void:
	# Don't hide if we're in the editor, it just makes modifying the panel a pain
	if !Engine.is_editor_hint():
		hide()

func start() -> void:
	# Duplicate this and modify the local copy so we can add a "reset" button that copies the
	# previous values from RS.settings, and only replace the settings when the user is done
	settings = RS.settings.duplicate(true)

	# Initialize the scope aggregator with previously selected items
	scope_aggregator.features = settings.twitch_features_enabled
	scope_aggregator.scopes = settings.twitch_scopes
	scope_aggregator.scopes_changed.connect(_on_scopes_changed)

	print_verbose("Configuring Twitch API Features panel...")
	%pnl_twitch_features_api.scope_aggregator = scope_aggregator
	%pnl_twitch_features_api.feature_set = Features.feature_set_api

	print_verbose("Configuring Twitch EventSub Features panel...")
	%pnl_twitch_features_eventsub.scope_aggregator = scope_aggregator
	%pnl_twitch_features_eventsub.feature_set = Features.feature_set_eventsub

	%pnl_twitch_auth_irc.scope_aggregator = scope_aggregator
	%pnl_twitch_auth_irc.settings = settings

	%pnl_twitch_developer.scope_aggregator = scope_aggregator
	%pnl_twitch_developer.settings = settings

	for child in %tabs_welcome.get_children():
		if child is PanelFormContainer:
			assert(child.unique_name_in_owner, "All forms in tabs_welcome should have a unique name")
			_form_containers.append(child)
			var form_container := child as PanelFormContainer
			form_container.completion_changed.connect(_on_panel_form_container_completion_changed)
			_on_panel_form_container_completion_changed(form_container, form_container.is_completed)

	show()

func should_show() -> bool:
	var project_version := RSVersion.parse(ProjectSettings.get_setting("application/config/version"))
	var welcome_version := RSVersion.parse(RS.settings.welcome_version)
	return welcome_version.compare_to(project_version) < 0

func _on_panel_form_container_completion_changed(p_panel_form_container: PanelFormContainer, p_completed: bool) -> void:
	var form_key := p_panel_form_container.name
	if p_completed:
		_completed_form_containers[form_key] = true
	else:
		_completed_form_containers.erase(form_key)

	var active_tab = %tabs_welcome.get_current_tab_control()
	if p_panel_form_container == active_tab:
		%btn_next.disabled = !p_completed

func _on_tabs_welcome_tab_changed(tab: int) -> void:
	%btn_prev.disabled = tab < 1
	#%btn_next.disabled = tab >= %tabs_welcome.get_tab_count() - 1
	if %tabs_welcome.current_tab + 1 < %tabs_welcome.get_tab_count():
		%btn_next.icon = preload("res://ui/bootstrap_icons/arrow-right.png")
	else:
		%btn_next.icon = preload("res://ui/bootstrap_icons/check2.png")

func _on_btn_prev_pressed() -> void:
	%tabs_welcome.current_tab = max(%tabs_welcome.current_tab - 1, 0)

func _on_btn_next_pressed() -> void:
	if %tabs_welcome.current_tab + 1 < %tabs_welcome.get_tab_count():
		%tabs_welcome.current_tab = min(%tabs_welcome.current_tab + 1, %tabs_welcome.get_tab_count())
	else:
		RS.settings = settings
		completed.emit()

func _on_scopes_changed(p_scope_aggregator: ScopeAggregator) -> void:
	settings.twitch_features_enabled = p_scope_aggregator.features
	settings.twitch_scopes = p_scope_aggregator.scopes
