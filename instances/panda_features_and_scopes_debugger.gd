extends HBoxContainer

const SCENE_FEATURE_CATEGORY := preload("res://ui/twitch/feature_category.tscn")
const SCENE_FEATURE_ENTRY := preload("res://ui/twitch/feature_entry.tscn")

const Features = preload("res://ui/twitch/features.gd")
const FeatureTypes = preload("res://ui/twitch/feature_types.gd")
const FeatureDefinition = FeatureTypes.FeatureDefinition
const ScopedFeatureDefinitionCategory = FeatureTypes.ScopedFeatureDefinitionCategory

var scope_aggregator := ScopeAggregator.new()

func _ready() -> void:
	scope_aggregator.scopes_changed.connect(_on_scopes_changed)

	_populate_from(Features.feature_set_api.feature_categories, %FeaturesApi)
	_populate_from(Features.feature_set_eventsub.feature_categories, %FeaturesEventSub)
	
	%TabContainer.set_tab_title(0, "API Features")
	%TabContainer.set_tab_title(1, "EventSub Features")

func _on_scopes_changed(p_scope_aggregator: ScopeAggregator) -> void:
	var scopes: Array[String] = p_scope_aggregator.scopes
	scopes.sort()

	%ScopesList.clear()
	for scope in scopes:
		%ScopesList.add_item(scope)

func _populate_from(categories: Array[ScopedFeatureDefinitionCategory], parent_node: VBoxContainer) -> void:
	for category in categories:
		var category_instance: FeatureCategory = SCENE_FEATURE_CATEGORY.instantiate()
		category_instance.category_name = category.category_name
		category_instance.expanded = false
		scope_aggregator.connect_to(category_instance)

		var features: Array[FeatureDefinition] = []
		features.append_array(category.feature_definitions)
		category_instance.features = features
		parent_node.add_child(category_instance)
