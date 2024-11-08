@tool
class_name FeatureEntry
extends PanelContainer

signal feature_selection_changed(p_id: String, p_selected: bool)

@export var id: String

@export var feature_name: String = "Feature Name":
	set(value):
		if value == feature_name: return
		feature_name = value
		_update_feature_name()

@export var doc_link: String:
	set(value):
		if value == doc_link: return
		doc_link = value
		_update_doc_link()

@export_multiline var description: String = "Test\nTest\nTest":
	set(value):
		if value == description: return
		description = value
		_update_description()

@export var expanded: bool = false:
	set(value):
		if value == expanded: return
		expanded = value
		_update_expanded()

@export var selected: bool = false:
	set(value):
		if value == selected: return
		selected = value
		_update_selected()

func _ready() -> void:
	_update_doc_link()
	_update_expanded()
	_update_feature_name()
	_update_selected()

func _update_doc_link() -> void:
	if !is_node_ready(): return
	%LinkDocumentation.uri = doc_link

func _update_description() -> void:
	if !is_node_ready(): return
	%LabelDescription.text = description

func _update_expanded() -> void:
	if !is_node_ready(): return
	%ButtonFeatureDetails.set_pressed_no_signal(expanded)
	%FeatureDetails.visible = expanded

func _update_feature_name() -> void:
	if !is_node_ready(): return
	%LabelFeatureName.text = feature_name

func _update_selected() -> void:
	if !is_node_ready(): return
	%CheckSelectFeature.set_pressed_no_signal(selected)

func _on_button_feature_details_toggled(toggled_on: bool) -> void:
	expanded = toggled_on
	_update_expanded()

func _on_check_select_feature_toggled(toggled_on: bool) -> void:
	selected = toggled_on
	feature_selection_changed.emit(id, selected)
	_update_selected()
