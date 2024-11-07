extends Control

@onready var lb_fps: Label = %lb_fps
@onready var lb_tot_obj: Label = %lb_tot_obj
@onready var lb_mouse_pos: Label = %lb_mouse_pos
@onready var lb_hover: Label = %lb_hover
@onready var cl_title_flag: ColorRect = %cl_title_flag
@onready var cl_decoration: ColorRect = %cl_decoration
@onready var cl_win: ColorRect = %cl_win

var lb_style: StyleBoxFlat



func _ready() -> void:
	lb_style = lb_hover.get_theme_stylebox("normal")

func start():
	hide()
	RS.physic_scene.count_updated.connect(update_obj_count)

func update_obj_count(val: int):
	lb_tot_obj.text = str(val)

func print_to_console(_text_from_button: String) -> void:
	pass


func _process(_d: float) -> void:
	if not RS.mouse_tracker: return
	if !is_visible_in_tree(): return
	
	lb_mouse_pos.text = "%4d, %4d" % [RS.mouse_tracker.m_pos.x , RS.mouse_tracker.m_pos.y]
	cl_win.color = Color.SEA_GREEN if RS.mouse_tracker.is_on_a_window else Color.CRIMSON
	lb_style.bg_color = Color.SEA_GREEN if RS.mouse_tracker.is_on_a_control_node else Color.CRIMSON
	lb_hover.text = "is on UI element"
	lb_hover.has_theme_stylebox_override("normal")
	if RS.mouse_tracker.is_on_a_control_node:
		lb_hover.text = "is on UI element: %s" % RS.mouse_tracker.hovered_control_node.name
	cl_title_flag.color = Color.SEA_GREEN if RS.mouse_tracker.is_on_title_bar else Color.CRIMSON
	cl_decoration.color = Color.SEA_GREEN if RS.mouse_tracker.is_on_window_decoration else Color.CRIMSON
	lb_fps.text = "fps %s" % [Engine.get_frames_per_second()]
