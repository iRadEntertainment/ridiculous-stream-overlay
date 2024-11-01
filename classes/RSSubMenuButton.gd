@icon("res://ui/btn_sub_menu.png")
extends Button
class_name RSSubMenuButton

@export var expand_on_hover := true:
	set(val):
		expand_on_hover = val
		if is_node_ready():
			if val:
				if not mouse_entered.is_connected(expand_menu):
					mouse_entered.connect(expand_menu.bind(true))
			else:
				if mouse_entered.is_connected(expand_menu):
					mouse_entered.disconnect(expand_menu)
@export var is_radial := false
@export_range (0.0, 64.0, 0.5) var offset_gap : float = 8:
	set(val):
		offset_gap = val
		expand_menu(is_open)
@export_range (0.0, 360.0, 0.5) var radial_angle : float = 180:
	set(val):
		radial_angle = val
		_radial_angle_rad = deg_to_rad(radial_angle)
		expand_menu(is_open)

@export_range (0.0, 0.6, 0.01) var anim_duration = 0.15
@export_range (0.0, 0.1, 0.001) var anim_delay = 0.03
const MIN_SIZE = Vector2(48, 48)

var main: RSMain
var main_menu_button: RSSubMenuButton
var tw: Tween

enum Edge{UP, LEFT, BOT, RIGHT}
var closest_edge := Edge.RIGHT

var _radial_angle_rad : float = PI
var parent: RSSubMenuButton
var parent_dir := Vector2.DOWN
var custom_pos := Vector2()

var is_open := false
var is_sub_menu := false
var is_dragged := false
var is_mouse_click_down := false
var grabbed_at := Vector2()
var all_btns : Array[Button]

signal btn_child_expanded(btn_child: RSSubMenuButton, is_open: bool)
signal properly_pressed


func start(_main: RSMain, _main_menu_button: RSSubMenuButton = null) -> void:
	main = _main
	main_menu_button = _main_menu_button
	#tw = create_tween()
	#tw.bind_node(self)
	
	gui_input.connect(_on_gui_input)
	properly_pressed.connect(toggle_menu)
	if expand_on_hover:
		mouse_entered.connect(expand_menu.bind(true))
	
	if get_parent() is RSSubMenuButton:
		parent = get_parent()
		is_sub_menu = true
	
	all_btns = []
	for child in get_children():
		if child is Button:
			all_btns.append(child)
	
	for btn in all_btns:
		if btn is RSSubMenuButton:
			btn.start(main, main_menu_button)
			btn.btn_child_expanded.connect(_on_btn_child_expanded)
		btn.focus_mode = Control.FOCUS_NONE
		btn.custom_minimum_size = MIN_SIZE
		RSSubMenuButton.assign_texture_to_button_from_icon(btn, 10)
		btn.add_to_group("UI")
	expand_menu(false)

func _on_btn_child_expanded(btn_expanded: RSSubMenuButton, opened: bool) -> void:
	for btn in all_btns:
		if btn is RSSubMenuButton and btn != btn_expanded and opened:
			btn.expand_menu(false)
	#if not opened:
		#expand_menu(false, btn)
	#else:
		#expand_menu(true, btn)

func expand_menu(value: bool, except : RSSubMenuButton = null) -> void:
	is_open = value
	if is_sub_menu:
		var parent_center : Vector2 = parent.size/2
		var this_center := size/2 + position
		parent_dir = parent_center.direction_to(this_center)
	
	var angle_start = 0
	var angle_step = 0
	if is_open and is_radial:
		angle_start = - _radial_angle_rad/2 + parent_dir.angle()
		angle_step = _radial_angle_rad / (all_btns.size()-1)
	
	if tw:
		tw.kill()
	tw = create_tween()
	tw.bind_node(self)
	tw.set_ease(Tween.EASE_IN_OUT)
	tw.set_trans(Tween.TRANS_CUBIC)
	for i in all_btns.size():
		var btn: Button = all_btns[i]
		if btn == except:
			continue
		var delay : float = i * anim_delay
		var new_pos := size / 2.0 -(btn.size / 2.0)
		if is_open:
			if btn is RSSubMenuButton and btn.custom_pos != Vector2():
				new_pos = btn.custom_pos.rotated(main_menu_button.parent_dir.angle())
			elif is_radial:
				new_pos += Vector2.from_angle(angle_start + i * angle_step) * (size.x + offset_gap)
			else:
				new_pos += parent_dir * (i+1) * (size.x + offset_gap)
			btn.visible = true
		else:
			if btn.has_method("expand_menu"):
				btn.expand_menu(false)
			tw.parallel().tween_property(btn, "visible", is_open, anim_duration).set_delay(delay)
		tw.parallel().tween_property(btn, "position", new_pos, anim_duration).set_delay(delay)
		tw.parallel().tween_property(btn, "modulate:a", 1 if is_open else 0, anim_duration).set_delay(delay)
		
		btn_child_expanded.emit(self, is_open)


func toggle_menu():
	expand_menu(!is_open)


func _process(d: float) -> void:
	if is_dragged:
		position = position.lerp(get_parent().get_local_mouse_position() - grabbed_at, d*10)

func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			is_mouse_click_down = event.is_pressed()
			if is_mouse_click_down:
				grabbed_at = event.position
			elif is_dragged:
				custom_pos = position.rotated(-main_menu_button.parent_dir.angle())
				is_dragged = false
		if event.button_index == MOUSE_BUTTON_RIGHT:
			custom_pos = Vector2()
			if is_sub_menu:
				expand_menu(false)
				parent.expand_menu(parent.is_open)
	if event is InputEventMouseMotion and is_mouse_click_down:
		is_dragged = true
		if is_open:
			expand_menu(false)

func _pressed() -> void:
	if is_dragged: return
	properly_pressed.emit()


static func assign_texture_to_button_from_icon(btn: Button, offset: float) -> void:
	var tex = btn.icon
	if not tex: return
	btn.icon = null
	var normal_col = btn.get_theme_color("icon_normal_color")
	var pressed_col = btn.get_theme_color("icon_pressed_color")
	var hover_col = btn.get_theme_color("icon_hover_color")
	var tex_rect = TextureRect.new()
	tex_rect.name = "ico"
	tex_rect.texture = tex
	tex_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	tex_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	tex_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	tex_rect.modulate = normal_col
	tex_rect.set_anchor_and_offset(SIDE_TOP, 0, offset)
	tex_rect.set_anchor_and_offset(SIDE_LEFT, 0, offset)
	tex_rect.set_anchor_and_offset(SIDE_RIGHT, 1, -offset)
	tex_rect.set_anchor_and_offset(SIDE_BOTTOM, 1, -offset)
	btn.mouse_exited.connect(func(): tex_rect.modulate = normal_col)
	btn.mouse_entered.connect(func(): tex_rect.modulate = hover_col)
	btn.pressed.connect(func(): tex_rect.modulate = pressed_col)
	btn.add_child(tex_rect)
	btn.size = btn.custom_minimum_size
	
