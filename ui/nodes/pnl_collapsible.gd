@tool
class_name CollapsiblePanelContainer
extends PanelContainer

const CARET_RIGHT = preload("res://ui/bootstrap_icons/caret-right-fill.png")
const CARET_DOWN = preload("res://ui/bootstrap_icons/caret-down-fill.png")

@export var expanded := false:
	set(value):
		if value == expanded: return
		expanded = value
		_update()

@export var text := &"":
	set(value):
		if value == text: return
		text = value
		_update()

@export var text_centered := false:
	set(value):
		if value == text_centered: return
		text_centered = value
		_update()


func _ready() -> void:
	_update()

func _update() -> void:
	if !is_node_ready(): return

	%btn_toggle.set_pressed_no_signal(expanded)
	%lb.text = text
	%lb.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER if text_centered else HORIZONTAL_ALIGNMENT_LEFT
	%ico.texture = CARET_DOWN if expanded else CARET_RIGHT

	for child in get_children():
		if child == %btn_toggle: continue
		if child == %hb: continue
		child.visible = expanded

func _on_btn_toggle_toggled(toggled_on: bool) -> void:
	expanded = toggled_on
