extends Node
class_name RSMouseTracker

var main: RSMain

var m_pos: Vector2
var is_active := true:
	set(val):
		is_active = val
		set_process(is_active)
		main.mouse_pass.SetClickThrough(false)

var is_gui_active := false
var is_on_a_control_node := false
var is_on_a_window := false
var is_on_title_bar := false
var is_on_window_decoration := false

signal mouse_track_updated(is_passthrough)

func _ready() -> void:
	set_process(false)

func start(_main : RSMain):
	main = _main
	set_process(true)

func _process(_d) -> void:
	if not main:
		return
	m_pos = main.get_global_mouse_position()
	is_on_title_bar = is_m_pos_in_title(m_pos)
	is_on_window_decoration = is_m_pos_on_window_decoration(m_pos)
	is_on_a_window = is_m_pos_in_window(m_pos)
	
	if is_on_title_bar or is_on_window_decoration: is_on_a_control_node = false
	else: is_on_a_control_node = is_m_pos_in_control_nodes(m_pos)
	
	var checks = (is_on_a_control_node or is_on_title_bar or is_on_window_decoration or is_on_a_window)
	if is_gui_active != checks:
		is_gui_active = checks
		mouse_track_updated.emit(!is_gui_active)

func is_pixel_transparent(pos: Vector2) -> bool:
	if !main.get_rect().has_point(pos):
		return true
	return !get_window().get_texture().get_image().get_pixelv(pos).a > 0

func is_m_pos_in_control_nodes(pos: Vector2) -> bool:
	Rect2i().has_point(pos)
	
	if !main.get_rect().has_point(pos):
		return false
	for ctr: Control in get_tree().get_nodes_in_group("UI"):
		if !ctr.is_visible_in_tree(): continue
		var pos_rotated = pos
		var ctr_angle = ctr.get_global_transform().get_rotation()
		if ctr_angle != 0:
			pos_rotated = (pos - ctr.global_position).rotated(-ctr_angle) + ctr.global_position
		
		if ctr.get_global_rect().has_point(pos_rotated):
			return true
	return false


func is_m_pos_in_window(pos: Vector2) -> bool:
	if !main.get_rect().has_point(pos):
		return false
	for window: Window in get_tree().get_nodes_in_group("UIWindows"):
		if not window.visible: continue
		var win_rect := Rect2i(window.get_position_with_decorations(), window.get_size_with_decorations())
		if win_rect.has_point(pos):
			return true
	return false


func is_m_pos_in_title(pos: Vector2) -> bool:
	if DisplayServer.window_get_flag(DisplayServer.WINDOW_FLAG_BORDERLESS):
		return false
	var title_size: Vector2i = DisplayServer.window_get_title_size("App")
	@warning_ignore("narrowing_conversion")
	title_size = Vector2i(main.get_rect().size.x, 30)
	var title_rect := Rect2i(Vector2i(0, -title_size.y), title_size)
	
	return title_rect.has_point(Vector2i(pos))

func is_m_pos_on_window_decoration(pos: Vector2) -> bool:
	if DisplayServer.window_get_flag(DisplayServer.WINDOW_FLAG_BORDERLESS):
		return false
	var window_rect := Rect2i(Vector2i(), DisplayServer.window_get_size())
	
	var title_size: Vector2i = DisplayServer.window_get_title_size("App")
	var decorations_size := DisplayServer.window_get_size_with_decorations()
	var decorations_pos := Vector2i()
	@warning_ignore("integer_division")
	decorations_pos.x = -(decorations_size.x - window_rect.size.x)/2
	decorations_pos.y = - title_size.y - 2 #px
	var window_rect_decorations := Rect2i(decorations_pos, decorations_size)
	
	return window_rect_decorations.has_point(pos) and not window_rect.has_point(pos)
