extends Button
class_name RSButtonPhysics

signal properly_pressed

var main: RSMain

var is_open := false
var is_dragged := false
var is_mouse_click_down := false
var grabbed_at := Vector2()

const DURATION = 0.15
const DELAY = 0.03
const MIN_SIZE = Vector2(48, 48)


func _ready() -> void:
	properly_pressed.connect(toggle_menu)


func start(_main: RSMain) -> void:
	main = _main
	main.physic_scene.count_updated.connect(update_obj_count)
	for btn: Button in get_children():
		btn.focus_mode = Control.FOCUS_NONE
		btn.custom_minimum_size = MIN_SIZE
		btn.add_to_group("UI")
	expand_menu(false)

func update_obj_count(val: int) -> void:
	%lb_count.visible = (val != 0)
	%lb_count.text = str(val)

func expand_menu(value: bool) -> void:
	is_open = value
	var parent_center : Vector2 = get_parent().size/2
	var this_center := size/2 + position
	var main_dir = parent_center.direction_to(this_center)
	
	var tw = create_tween()
	tw.bind_node(self)
	tw.set_ease(Tween.EASE_IN_OUT)
	tw.set_trans(Tween.TRANS_CUBIC)
	for i in get_children().size():
		if not get_child(i) is Button: continue
		var btn: Button = get_child(i)
		var delay : float = i * DELAY
		var new_pos := size / 2.0 -(btn.size / 2.0)
		if is_open:
			new_pos += main_dir * (i+1) * (size.x + 8)
			btn.visible = true
		else:
			tw.parallel().tween_property(btn, "visible", is_open, DURATION).set_delay(delay)
		tw.parallel().tween_property(btn, "position", new_pos, DURATION).set_delay(delay)
		tw.parallel().tween_property(btn, "modulate:a", 1 if is_open else 0, DURATION).set_delay(delay)


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
			else:
				is_dragged = false
	if event is InputEventMouseMotion and is_mouse_click_down:
		is_dragged = true
		if is_open:
			expand_menu(false)

func _pressed() -> void:
	if is_dragged: return
	properly_pressed.emit()


func _on_btn_beans_pressed() -> void: main.custom.beans("")
func _on_btn_laser_pressed() -> void: main.custom.laser()
func _on_btn_nuke_pressed() -> void: main.physic_scene.nuke()
func _on_btn_zerog_pressed() -> void: main.custom.zero_g()
func _on_btn_names_pressed() -> void: main.custom.destructibles_names()
func _on_btn_granade_pressed() -> void: pass
