@tool
extends PanelContainer
class_name RSWheel


const COLOURS = [
	Color.ROSY_BROWN,
	Color.AQUA,
	Color.DEEP_PINK,
	Color.SADDLE_BROWN,
	Color.BLACK,
	Color.SEA_GREEN,
	Color.ORANGE
]


var example_entries: Array[RSWheelEntry] = [
	RSWheelEntry.new("Choice 1", COLOURS[0]),
	RSWheelEntry.new("Choice 2", COLOURS[1]),
	RSWheelEntry.new("Choice 3", COLOURS[2]),
	RSWheelEntry.new("Choice 4", COLOURS[3]),
	RSWheelEntry.new("Choice 5", COLOURS[4]),
]


@export var entries: Array[RSWheelEntry] = example_entries:
	set(val):
		entries = val
		update()
@export var update_visuals := false:
	set(val): update_visuals = val; update()
@export_subgroup("Rim")
@export_range(6, 360, 2) var resolution: int = 100:
	set(val):
		resolution = val
		update()
@export_range(0, 64, 0.5) var line_thickness = 2.0:
	set(val):
		line_thickness = val
		update()
@export var line_color: Color = Color.WHITE_SMOKE:
	set(val):
		line_color = val
		update()
@export_range(0, 1, 0.01) var wheel_radius_ratio = 0.9:  #percentage
	set(val):
		wheel_radius_ratio = val
		update()
@export var rim_texture: Texture2D:
	set(val):
		rim_texture = val
		update()
@export var label_font: Font:
	set(val):
		label_font = val
		update()
@export_subgroup("Arrow")
@export var arrow_texture: Texture2D:
	set(val):
		arrow_texture = val
		update()
@export var arrow_scale: float = 0.5:
	set(val):
		arrow_scale = val
		update()
@export var arrow_modulate: Color = Color.WHITE:
	set(val):
		arrow_modulate = val
		update()
@export_range(0, TAU, PI/4) var angle_init := -PI/2:
	set(val):
		angle_init = val
		update()



var n_cnt_center: CenterContainer
var n_center_node: Control
var n_rotating_body: RigidBody2D
var n_rim: Sprite2D
var n_arrow: Sprite2D

var _wheel_radius: int
var _n_entries: int
var _tw_spin: Tween

signal winner_selected(winner: String)
signal cancelled


#func _init(entries: Array[RSWheelEntry]) -> void:
	#self.entries = entries


func _ready() -> void:
	_generate_nodes()


func _generate_nodes() -> void:
	for child in get_children():
		child.queue_free()
	
	var vb := VBoxContainer.new()
	add_child(vb)
	var btn_kill := Button.new()
	btn_kill.custom_minimum_size = Vector2.ONE * 32
	vb.add_child(btn_kill)
	n_cnt_center = CenterContainer.new()
	n_cnt_center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	n_cnt_center.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vb.add_child(n_cnt_center)
	n_center_node = Control.new()
	n_cnt_center.add_child(n_center_node)
	
	n_rotating_body = RigidBody2D.new()
	n_rotating_body.collision_layer = 0
	n_rotating_body.collision_mask = 0
	n_rotating_body.gravity_scale = 0
	n_rotating_body.center_of_mass_mode = RigidBody2D.CenterOfMassMode.CENTER_OF_MASS_MODE_CUSTOM
	n_rotating_body.inertia = 1
	n_rotating_body.angular_damp = 0.005
	n_rotating_body.sleeping_state_changed.connect(_on_rotating_body_sleeping_state_changed)
	
	n_center_node.add_child(n_rotating_body)
	n_rim = Sprite2D.new()
	n_center_node.add_child(n_rim)
	n_arrow = Sprite2D.new()
	n_center_node.add_child(n_arrow)


func update() -> void:
	_wheel_radius = min(n_cnt_center.size.x, n_cnt_center.size.y)
	_wheel_radius *= wheel_radius_ratio
	_wheel_radius *= 0.5
	
	_n_entries = entries.size()
	
	if rim_texture:
		n_rim.texture = rim_texture
		var rim_original_radius = min(rim_texture.get_width(), rim_texture.get_height()) / 2.0
		var rim_scale = _wheel_radius / rim_original_radius
		n_rim.scale = Vector2.ONE * rim_scale
	
	if arrow_texture:
		n_arrow.texture = arrow_texture
		n_arrow.position = Vector2.from_angle(angle_init) * _wheel_radius
		n_arrow.rotation = angle_init
		n_arrow.scale = Vector2.ONE * arrow_scale
		n_arrow.modulate = arrow_modulate
	
	populate_wheel()



func spin() -> void:
	print("Wheel started spinning")
	var rand_torque = randf_range(100, 300)
	
	n_rotating_body.sleeping = false
	if _tw_spin:
		_tw_spin.kill()
	_tw_spin = create_tween()
	_tw_spin.tween_method(n_rotating_body.apply_torque, 0, rand_torque, .3)
	_tw_spin.tween_interval(0.8)


func select_winner_from_wheel():
	var final_angle = wrap(-n_rotating_body.rotation, 0, TAU)
	var selected_idx := floor((final_angle/TAU) * _n_entries ) as int
	var winner: RSWheelEntry = entries[selected_idx]
	winner_selected.emit(winner.text)
	print("winner selected: %s" % winner)


func populate_wheel() -> void:
	for child in n_rotating_body.get_children():
		child.queue_free()
	
	var angle_size = TAU/_n_entries
	@warning_ignore("integer_division")
	var res = resolution/_n_entries
	
	for i in _n_entries:
		var entry: RSWheelEntry = entries[i]
		var angle = angle_init + angle_size * i
		var n_sector: Polygon2D = poly_from_entry(entry, angle, angle_size, res)
		n_sector.color = entry.colour
		n_rotating_body.add_child(n_sector)


func poly_from_entry(
			_entry: RSWheelEntry,
			_angle_init : float,
			_angle_size : float,
			res : int,
		) -> Polygon2D:
	res = max(res, 2)
	
	var new_polygon := Polygon2D.new()
	var points := PackedVector2Array()
	var angle_step = _angle_size/(res-1)
	points.append(Vector2())
	for i in res:
		var angle = _angle_init + angle_step*i
		var p = Vector2.from_angle(angle) * _wheel_radius
		points.append(p)
	new_polygon.polygon = points
	
	#var user : RSTwitchUser = main.known_users[_streamer_info.user_login]
	#new_polygon.texture = await main.loader.load_texture_from_url(user.profile_image_url)
	#new_polygon.texture_repeat = CanvasItem.TEXTURE_REPEAT_ENABLED
	
	var line := Line2D.new()
	line.points = points
	line.width = line_thickness
	line.closed = true
	line.antialiased = true
	line.default_color = line_color
	new_polygon.add_child(line)
	
	var lb := Label.new()
	lb.text = _entry.text
	lb.add_theme_font_override("font", label_font)
	lb.rotation = _angle_init + _angle_size/2
	lb.position = Vector2.from_angle(lb.rotation) * 64
	new_polygon.add_child(lb)
	return new_polygon


func _on_btn_kill_pressed():
	cancelled.emit()
	queue_free()

func _on_rotating_body_sleeping_state_changed() -> void:
	select_winner_from_wheel()
