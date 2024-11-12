@tool
class_name PanelTwitchFeatures
extends PanelFormContainer

#region Constants

#region Packed Scenes

const SCENE_FEATURE_CATEGORY := preload("res://ui/twitch/feature_category.tscn")
const SCENE_FEATURE_ENTRY := preload("res://ui/twitch/feature_entry.tscn")

#endregion Packed Scenes

#region Theming

const STYLEBOX_PANEL_FLAT_DARK := preload("res://ui/panel_flat_dark.tres")

#endregion Theming

#region Script Imports

const Features = preload("res://ui/twitch/features.gd")

const FeatureTypes = preload("res://ui/twitch/feature_types.gd")
const FeatureDefinition = FeatureTypes.FeatureDefinition
const ScopedFeatureSet = FeatureTypes.ScopedFeatureSet
const ScopedFeatureDefinitionCategory = FeatureTypes.ScopedFeatureDefinitionCategory

const Scopes = preload("res://ui/twitch/scopes/scopes.gd")

#endregion Script Imports

#endregion

#region Exports and Public Properties

@export var show_advanced_details: bool = false:
	set(value):
		if value == show_advanced_details: return
		show_advanced_details = value
		_update_show_advanced_details()

@export var title: String = &"Twitch Features":
	set(value):
		if value == title: return
		title = value
		_update_title()

var feature_set: ScopedFeatureSet:
	set(value):
		if value == feature_set:
			print_debug("feature_set unchanged: was already %s (tried to set to %s)" % [feature_set, value])
			return
		feature_set = value
		_populate_from(feature_set)

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

#endregion Exports and Public Properties

#region Lifecycle

func _ready() -> void:
	_update_show_advanced_details()
	_update_title()

#endregion Lifecycle

#region Export Synchronization

func _update_show_advanced_details() -> void:
	if !is_node_ready(): return

	%btn_toggle_show_adv.set_pressed_no_signal(show_advanced_details)
	
	if !Engine.is_editor_hint():
		%vb_scopes.visible = show_advanced_details

func _update_title() -> void:
	if !is_node_ready(): return

	%lb_title.text = title

#endregion Export Synchronization

func _populate_from(p_feature_set: ScopedFeatureSet) -> void:
	var previous_children := %vb_feature_categories.get_children()
	print_verbose("Removing %d existing categories from the panel (%s)" % [
		previous_children.size(),
		title,
	])
	for child_node in %vb_feature_categories.get_children():
		child_node.queue_free()

	print_verbose("Adding %d categories to the panel (%s)" % [
		p_feature_set.feature_categories.size(),
		title,
	])
	for category in p_feature_set.feature_categories:
		var category_instance: FeatureCategory = SCENE_FEATURE_CATEGORY.instantiate()
		category_instance.category_name = category.category_name
		category_instance.expanded = false
		scope_aggregator.connect_to(category_instance)

		var features: Array[FeatureDefinition] = []
		features.append_array(category.feature_definitions)
		category_instance.features = features
		%vb_feature_categories.add_child(category_instance)

	if scope_aggregator:
		_on_scopes_changed(scope_aggregator)

#region Event Handlers

func _on_scopes_changed(p_scope_aggregator: ScopeAggregator) -> void:
	if Engine.is_editor_hint(): return

	var features := p_scope_aggregator.features
	for child in %vb_feature_categories.get_children():
		if not child is FeatureCategory:
			continue

		var category := child as FeatureCategory
		for entry in category.get_entry_controls():
			var entry_selected := features.find(entry.id) >= 0
			entry.set_selected_no_signal(entry_selected)

		category.synchronize_selections()

	var scopes: Array[String] = p_scope_aggregator.scopes
	scopes.sort()

	for child in %grid_scopes.get_children():
		child.queue_free()

	for scope in scopes:
		var scope_label := Label.new()
		scope_label.add_theme_stylebox_override("normal", STYLEBOX_PANEL_FLAT_DARK)
		scope_label.text = scope
		scope_label.name = "lbl_name_%s" % scope.replace(":", "_")
		%grid_scopes.add_child(scope_label)

		var scope_description := Label.new()
		scope_description.add_theme_stylebox_override("normal", STYLEBOX_PANEL_FLAT_DARK)
		scope_description.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		scope_label.name = "lbl_description_%s" % scope.replace(":", "_")
		if Scopes.lookup.has(scope):
			var scope_metadata := Scopes.lookup.get(scope) as ScopeMetadata
			scope_description.text = scope_metadata.description
		else:
			scope_description.text = &"MISSING DESCRIPTION" if OS.is_debug_build() else &""
		%grid_scopes.add_child(scope_description)

func _on_btn_toggle_show_adv_toggled(toggled_on: bool) -> void:
	%vb_scopes.visible = toggled_on

#endregion Event Handlers
