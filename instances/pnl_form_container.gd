@tool
class_name PanelFormContainer
extends PanelContainer

signal completion_changed(p_panel_form_container: PanelFormContainer, p_completed: bool)

var is_completed: bool:
	get: return _required_valid_field_count <= _valid_fields.size()

var _required_valid_field_count: int:
	set(value):
		if value == _required_valid_field_count: return
		_required_valid_field_count = value
		_check_completion(false)

var _valid_fields := {}
var _was_completed: bool

func _init(p_required_valid_field_count := 0) -> void:
	_required_valid_field_count = p_required_valid_field_count
	_was_completed = is_completed

func _mark_field_valid(p_field_name: String, p_valid := true) -> void:
	if p_valid:
		_valid_fields[p_field_name] = true
	else:
		_valid_fields.erase(p_field_name)

	_check_completion(true)

func _check_completion(_p_was_marked_valid: bool) -> void:
	if is_completed:
		completion_changed.emit(self, true)
	elif _was_completed:
		completion_changed.emit(self, false)

	_was_completed = is_completed

func _presubmit(_p_settings: RSSettings) -> void:
	pass
