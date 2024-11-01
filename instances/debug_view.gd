extends Control

@onready var lb_fps: Label = %lb_fps
@onready var lb_tot_obj: Label = %lb_tot_obj
@onready var lb_mouse_pos: Label = %lb_mouse_pos
@onready var cl_hover: ColorRect = %cl_hover
@onready var cl_title_flag: ColorRect = %cl_title_flag
@onready var cl_decoration: ColorRect = %cl_decoration
@onready var cl_win: ColorRect = %cl_win

var main: RSMain

func start(_main: RSMain):
	hide()
	main = _main
	main.physic_scene.count_updated.connect(update_obj_count)

func update_obj_count(val: int):
	lb_tot_obj.text = str(val)

func print_to_console(_text_from_button: String) -> void:
	pass


func _process(_d: float) -> void:
	if not main.mouse_tracker: return
	if !is_visible_in_tree(): return
	
	lb_mouse_pos.text = str(main.mouse_tracker.m_pos)
	cl_win.color = Color.SEA_GREEN if main.mouse_tracker.is_on_a_window else Color.CRIMSON
	cl_hover.color = Color.SEA_GREEN if main.mouse_tracker.is_on_a_control_node else Color.CRIMSON
	cl_title_flag.color = Color.SEA_GREEN if main.mouse_tracker.is_on_title_bar else Color.CRIMSON
	cl_decoration.color = Color.SEA_GREEN if main.mouse_tracker.is_on_window_decoration else Color.CRIMSON
	lb_fps.text = "fps %s" % [Engine.get_frames_per_second()]


func _on_btn_launch_game_pressed() -> void: main.launch_game(true)
func _on_btn_close_game_pressed() -> void: main.launch_game(false)
