@tool
extends PanelContainer

const CARET_RIGHT = preload("res://ui/bootstrap_icons/caret-right-fill.png")
const CARET_DOWN = preload("res://ui/bootstrap_icons/caret-down-fill.png")

@export var text: String:
	set(val):
		text = val
		if is_node_ready():
			update()
@export var nodes_to_collapse: Array[Control]:
	set(val):
		nodes_to_collapse = val
		if is_node_ready():
			update()
@export var text_centered := false:
	set(val):
		text_centered = val
		if is_node_ready():
			update()


func _ready() -> void:
	%btn_toggle.pressed.connect(_on_toggled)
	update()

func update() -> void:
	%lb.text = text
	%lb.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER if text_centered else HORIZONTAL_ALIGNMENT_LEFT
	if nodes_to_collapse.is_empty():
		return
	var is_collapsed: bool = !nodes_to_collapse.front().visible
	%ico.texture = CARET_RIGHT if is_collapsed else CARET_DOWN

func _on_toggled() -> void:
	for node: Control in nodes_to_collapse:
		node.visible = !node.visible
	update()
