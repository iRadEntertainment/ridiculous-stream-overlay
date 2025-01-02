class FeatureDefinition extends Resource:
	var id: String
	var feature_name: String
	var doc_link: String
	var description: String

class FeatureSelection extends Resource:
	var feature_id: String
	var selected: bool

class ScopedFeatureDefinition extends FeatureDefinition:
	var scopes: Array[String] = []

	static func from(
		p_id: String,
		p_feature_name: String,
		p_doc_link: String,
		p_description: String,
		p_scopes: Array[String]
	) -> ScopedFeatureDefinition:
		var feature := ScopedFeatureDefinition.new()
		feature.id = p_id
		feature.feature_name = p_feature_name
		feature.doc_link = p_doc_link
		feature.description = p_description
		feature.scopes = p_scopes
		return feature

class ScopedFeatureDefinitionCategory extends Resource:
	var category_name: String
	var feature_definitions: Array[ScopedFeatureDefinition] = []

	static func from(
		p_category_name: String,
		p_feature_definitions: Array[ScopedFeatureDefinition]
	) -> ScopedFeatureDefinitionCategory:
		var category := ScopedFeatureDefinitionCategory.new()
		category.category_name = p_category_name
		category.feature_definitions = p_feature_definitions
		return category

class ScopedFeatureSet extends Resource:
	var id: String
	@warning_ignore("shadowed_variable_base_class")
	var set_name: String
	var feature_categories: Array[ScopedFeatureDefinitionCategory] = []

	static func from(
		p_id: String,
		p_set_name: String,
		p_feature_categories: Array[ScopedFeatureDefinitionCategory]
	) -> ScopedFeatureSet:
		var feature_set := ScopedFeatureSet.new()
		feature_set.id = p_id
		feature_set.set_name = p_set_name
		feature_set.feature_categories = p_feature_categories
		return feature_set
