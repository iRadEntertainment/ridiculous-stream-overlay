@tool
extends PanelContainer

@export var rotation_speed: float = 1.0


func _ready() -> void:
	visibility_changed.connect(_on_visibility_changed)


func _on_visibility_changed() -> void:
	set_process(is_visible_in_tree())


func _process(d: float) -> void:
	%loading_ico.rotation += d * TAU * rotation_speed
	%loading_ico.rotation = wrapf(%loading_ico.rotation, 0, TAU)
