@tool
class_name PanelWelcome
extends Control

const Features = preload("res://ui/twitch/features.gd")

var scope_aggregator := ScopeAggregator.new()

func _ready() -> void:
	if !Engine.is_editor_hint():
		hide()

	print_verbose("Configuring Twitch API Features panel...")
	%pnl_twitch_features_api.scope_aggregator = scope_aggregator
	%pnl_twitch_features_api.feature_set = Features.feature_set_api

	print_verbose("Configuring Twitch EventSub Features panel...")
	%pnl_twitch_features_eventsub.scope_aggregator = scope_aggregator
	%pnl_twitch_features_eventsub.feature_set = Features.feature_set_eventsub

func start() -> void:
	show()

func _on_tabs_welcome_tab_changed(tab: int) -> void:
	%btn_prev.disabled = tab < 1
	%btn_next.disabled = tab >= %tabs_welcome.get_tab_count() - 1

func _on_btn_prev_pressed() -> void:
	%tabs_welcome.current_tab = max(%tabs_welcome.current_tab - 1, 0)

func _on_btn_next_pressed() -> void:
	%tabs_welcome.current_tab = min(%tabs_welcome.current_tab + 1, %tabs_welcome.get_tab_count())
