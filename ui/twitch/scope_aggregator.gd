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
		var features: Array[String] = []
		features.append_array(_active_features.keys())
		return features;

var _active_features := {}

var scopes: Array[String]:
	get:
		var scopes: Array[String] = []
		scopes.append_array(_active_scopes.keys())
		return scopes

var _active_scopes := {}

func connect_to(category: FeatureCategory) -> void:
	category.feature_category_selection_changed.connect(_on_feature_category_selection_changed)

func disconnect_from(category: FeatureCategory) -> void:
	category.feature_category_selection_changed.disconnect(_on_feature_category_selection_changed)

func _on_feature_category_selection_changed(p_selections: Array[FeatureSelection]) -> void:
	for selection in p_selections:
		if selection.selected:
			_active_features[selection.feature_id] = true
		else:
			_active_features.erase(selection.feature_id)

		var scopes := scopes_by_feature_id.get(selection.feature_id, []) as Array
		for scope in scopes:
			var scope_count: int = _active_scopes.get_or_add(scope, 0)
			if selection.selected:
				scope_count += 1
			else:
				scope_count -= 1
			
			if scope_count < 1:
				_active_scopes.erase(scope)
			else:
				_active_scopes[scope] = scope_count

	scopes_changed.emit(self)
