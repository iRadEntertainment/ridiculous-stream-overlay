@tool
class_name FeatureCategory
extends VBoxContainer

const SCENE_FEATURE_ENTRY := preload("res://ui/twitch/feature_entry.tscn")

const FeatureTypes = preload("res://ui/twitch/feature_types.gd")
const FeatureDefinition = FeatureTypes.FeatureDefinition
const FeatureSelection = FeatureTypes.FeatureSelection

signal feature_category_selection_changed(p_selections: Array[FeatureSelection])

@export var category_name: String = "Category Name":
	set(value):
		if value == category_name: return
		category_name = value
		_update_category_name()

@export var expanded: bool = false:
	set(value):
		if value == expanded: return
		expanded = value
		_update_expanded()

@export var features: Array[FeatureDefinition] = []:
	set(value):
		if value == features: return
		features = value

		var features_by_id := {}
		for feature in features:
			features_by_id[feature.id] = feature
		_features_by_id = features_by_id

		_update_features()

var _selected: bool = false
@export var selected: bool:
	get: return _selected
	set(value):
		if value == _selected: return
		_selected = value
		_update_selected()

@export var selections: Array[FeatureSelection] = []:
	set(value):
		if value == selections: return
		selections = value

		var selections_by_id := {}
		for selection in selections:
			selections_by_id[selection.id] = selection.selected
		_selections_by_id = selections_by_id

		_update_features()

var _features_by_id := {}
var _selections_by_id := {}

func _ready() -> void:
	_update_category_name()
	_update_expanded()
	_update_features()
	_update_selected()

func _update_category_name() -> void:
	if !is_node_ready(): return
	%LabelCategoryName.text = category_name

func _update_expanded() -> void:
	if !is_node_ready(): return
	%ButtonExpandCategory.set_pressed_no_signal(expanded)
	%FeatureEntries.visible = expanded

func _update_selected() -> void:
	if !is_node_ready(): return
	%CheckSelectCategory.button_pressed = selected

func _update_selections() -> void:
	if !is_node_ready(): return
	if _selections_by_id.size() != _features_by_id.size():
		_update_features()
		return

	var feature_entries := _get_existing_feature_entries()
	for feature_entry in feature_entries:
		feature_entry.selected = _selections_by_id.get(feature_entry.id, false)

func _update_features() -> void:
	if !is_node_ready(): return
	if Engine.is_editor_hint(): return

	var feature_entries_to_prune := _get_existing_feature_entries()
	var feature_entries_by_id := {}

	# Figure out what existing nodes should be reused, and update them
	for feature_entry in feature_entries_to_prune:
		# If it's somehow already in the list (i.e. duplicates) skip it (we want to prune it later)
		if feature_entries_by_id.has(feature_entry.id): continue

		# If the feature should no longer be displayed skip it (we want to prune it later)
		if !_features_by_id.has(feature_entry.id): continue

		# Register the feature entry by id, we need this to sort the entries later
		feature_entries_by_id[feature_entry.id] = feature_entry

		# Remove the feature entry from the list of entries to prune
		feature_entries_to_prune.erase(feature_entry)

		# Synchronize all of the properties
		var feature_definition := _features_by_id[feature_entry.id] as FeatureDefinition
		feature_entry.description = feature_definition.description
		feature_entry.doc_link = feature_definition.doc_link
		feature_entry.feature_name = feature_definition.feature_name
		feature_entry.selected = _selections_by_id.get(feature_definition.id, false)

	# Create nodes for newly added features
	for feature_index in features.size():
		var feature_definition := features[feature_index]

		# If it's already registered it means we had an existing node for it
		if feature_entries_by_id.has(feature_definition.id): continue

		# Create and add the entry to the list
		var feature_entry: FeatureEntry = SCENE_FEATURE_ENTRY.instantiate()
		%FeatureEntries.add_child(feature_entry)

		# Listen to selection changes
		feature_entry.feature_selection_changed.connect(_on_feature_selection_changed)

		# Synchronize all of the properties
		feature_entry.id = feature_definition.id
		feature_entry.description = feature_definition.description
		feature_entry.doc_link = feature_definition.doc_link
		feature_entry.feature_name = feature_definition.feature_name
		feature_entry.selected = _selections_by_id.get(feature_definition.id, false)

		# Register the feature entry by id, we need this to sort the entries later
		feature_entries_by_id[feature_entry.id] = feature_entry

	# Remove nodes that are no longer being used
	for feature_entry in feature_entries_to_prune:
		feature_entry.queue_free()

	for feature_index in features.size():
		var feature_definition := features[feature_index]
		var feature_entry: FeatureEntry = feature_entries_by_id[feature_definition.id]
		%FeatureEntries.move_child(feature_entry, feature_index)

func _on_button_expand_category_toggled(toggled_on: bool) -> void:
	print_debug("Category expanded: %s" % toggled_on)
	expanded = toggled_on
	_update_expanded()

func _on_check_select_category_toggled(toggled_on: bool) -> void:
	selected = toggled_on

	var changed_selections: Array[FeatureSelection] = []

	for selection in selections:
		if selection.selected != selected:
			selection.selected = selected
			changed_selections.append(selection)
			_selections_by_id[selection.feature_id] = selected

	for feature in features:
		if _selections_by_id.has(feature.id):
			continue

		var selection := FeatureSelection.new()
		selection.feature_id = feature.id
		selection.selected = toggled_on
		selections.append(selection)
		changed_selections.append(selection)
		_selections_by_id[feature.id] = selected

	feature_category_selection_changed.emit(changed_selections)

	_update_selections()
	_update_selected()

func _on_feature_selection_changed(p_id: String, p_selected: bool) -> void:
	_selections_by_id[p_id] = p_selected

	if !p_selected and selected:
		set_selected_no_signal(false)

	_selections_by_id[p_id] = p_selected
	for selection in selections:
		if selection.feature_id != p_id: continue
		selection.selected = p_selected
		feature_category_selection_changed.emit([selection.duplicate()])

func set_selected_no_signal(p_selected: bool) -> void:
	_selected = p_selected
	%CheckSelectCategory.set_pressed_no_signal(p_selected)

func _get_existing_feature_entries() -> Array[FeatureEntry]:
	var nodes := %FeatureEntries.get_children()
	var entries: Array[FeatureEntry] = []
	for node in nodes:
		if node is FeatureEntry:
			entries.append(node)
		else:
			push_warning("Bad element in feature entries container (%s)" % [
				node.get_class().get_basename()
			])
	return entries