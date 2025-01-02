class_name ScopeAggregator
extends RefCounted

const Features = preload("res://ui/twitch/features.gd")
const FeatureTypes = preload("res://ui/twitch/feature_types.gd")
const FeatureSelection = FeatureTypes.FeatureSelection
const ScopedFeatureDefinition = FeatureTypes.ScopedFeatureDefinition
const ScopedFeatureSet = FeatureTypes.ScopedFeatureSet

signal scopes_changed(p_scope_aggregator: ScopeAggregator)

static var scopes_by_feature_id := {}

static func _static_init() -> void:
	var feature_sets: Array[ScopedFeatureSet] = [
		Features.feature_set_api,
		Features.feature_set_eventsub
	]

	for feature_set in feature_sets:
		for feature_category in feature_set.feature_categories:
			for feature_definition in feature_category.feature_definitions:
				var scopes_for_feature_id: Array[String] = []
				scopes_for_feature_id = scopes_by_feature_id.get_or_add(feature_definition.id, scopes_for_feature_id)
				for scope in feature_definition.scopes:
					if scopes_for_feature_id.find(scope) < 0:
						scopes_for_feature_id.append_array(feature_definition.scopes)

var features: Array[String]:
	get:
		var _features: Array[String] = []
		_features.append_array(_active_features.keys())
		return _features;

var _active_features := {}

var scopes: Array[String]:
	get:
		var _scopes: Array[String] = []
		_scopes.append_array(_active_scopes.keys())
		return _scopes

var _active_scopes := {}

func connect_to(category: FeatureCategory) -> void:
	category.feature_category_selection_changed.connect(_on_feature_category_selection_changed)

func disconnect_from(category: FeatureCategory) -> void:
	category.feature_category_selection_changed.disconnect(_on_feature_category_selection_changed)

func enable_feature(p_feature_id: String, p_enabled := true, p_no_signal := false) -> bool:
	if p_enabled == _active_features.has(p_feature_id):
		return false

	var no_scope_change := p_enabled

	if p_enabled:
		var activation_count: int = _active_features.get_or_add(p_feature_id, 0) + 1
		no_scope_change = activation_count > 1
		_active_features[p_feature_id] = activation_count
	else:
		var activation_count: int = _active_features.get_or_add(p_feature_id, 0) - 1
		if activation_count < 1:
			_active_features.erase(p_feature_id)
		else:
			no_scope_change = true
			_active_features[p_feature_id] = activation_count

	if !no_scope_change:
		var _scopes := scopes_by_feature_id.get(p_feature_id, []) as Array
		for scope in _scopes:
			enable_scope(scope, p_enabled, true)

		if !p_no_signal:
			scopes_changed.emit(self)

	return true

func enable_scope(p_scope: String, p_enabled := true, p_no_signal := false) -> void:
	var scope_count: int = _active_scopes.get_or_add(p_scope, 0)

	if p_enabled:
		scope_count += 1
	else:
		scope_count -= 1

	if scope_count < 1:
		_active_scopes.erase(p_scope)
	else:
		_active_scopes[p_scope] = scope_count

	if !p_no_signal:
		scopes_changed.emit(self)

func _on_feature_category_selection_changed(p_selections: Array[FeatureSelection]) -> void:
	var _scope_changed := false
	for selection in p_selections:
		if enable_feature(selection.feature_id, selection.selected, true):
			_scope_changed = true

	scopes_changed.emit(self)
