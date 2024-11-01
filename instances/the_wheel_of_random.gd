extends PanelContainer
class_name RSWheelOfRandom

const COLOURS = [
	Color.ROSY_BROWN,
	Color.AQUA,
	Color.DEEP_PINK,
	Color.SADDLE_BROWN,
	Color.BLACK,
	Color.SEA_GREEN,
	Color.ORANGE
]

@onready var cnt_center: CenterContainer = %cnt_center
@onready var center_node: Control = %center_node
@onready var rotating: RigidBody2D = %rotating
@onready var rim: Sprite2D = %rim
@onready var arrow: Sprite2D = %arrow

const RES_TOTAL = 100
var wheel_radius = 384.0

var main : RSMain
var angle_init := -PI/2
var choices := PackedStringArray()
var textures: Array[Texture2D] = []


signal winner_selected(winner: String)
signal cancelled


func _ready():
	set_process(false)

func start(_choices: PackedStringArray, _textures: Array[Texture2D] = []):
	hide()
	choices = _choices
	textures = _textures
	if !is_node_ready():
		await ready
	cnt_center.custom_minimum_size = Vector2.ONE * wheel_radius * 2
	arrow.position = Vector2.from_angle(angle_init) * wheel_radius
	arrow.rotation = angle_init
	await get_tree().process_frame
	show()
	build_entire_wheel()
	spin()


func spin() -> void:
	print("Wheel started spinning")
	var rand_torque = randf_range(100, 300)
	var tw = create_tween()
	tw.bind_node(self)
	rotating.sleeping = false
	tw.tween_method(rotating.apply_torque, 0, rand_torque, .3)
	tw.tween_interval(0.8)
	#tw.tween_method(rotating.apply_torque, rand_torque, 0, .3)
	#tw.tween_callback(rotating.apply_torque.bind( rand_torque))
	#tw.tween_callback(rotating.add_constant_torque.bind( rand_torque))
	#tw.tween_callback(rotating.add_constant_torque.bind(-rand_torque))
	
	rotating.sleeping_state_changed.connect(select_winner_from_wheel)


func select_winner_from_wheel():
	var final_angle = wrap(-rotating.rotation, 0, TAU)
	var selected_idx := floor((final_angle/TAU) * choices.size() ) as int
	var winner = choices[selected_idx]
	winner_selected.emit(winner)
	print("winner selected: %s" % winner)
	#main.twitcher.api.start_a_raid(
		#str(TwitchSetting.broadcaster_id),
		#str(winner.user_id),
		#)
	


func build_entire_wheel() -> void:
	print("Wheel being built")
	var angle_size = TAU/(choices.size())
	@warning_ignore("integer_division")
	var res = RES_TOTAL/(choices.size())
	
	for i in choices.size():
		var choice = choices[i]
		var texture := Texture2D.new()
		var angle = angle_init + angle_size * i
		var sector := wheel_sector(choice, angle, angle_size, wheel_radius, res, texture)
		sector.color = Color(randf(), randf(), randf())#COLOURS[wrap(i, 0, COLOURS.size())]
		rotating.add_child(sector)


func wheel_sector(
		choice: String,
		_angle_init : float,
		_angle_size : float,
		_radius : float,
		res : int,
		_texture: Texture2D) -> Polygon2D:
	
	var new_polygon := Polygon2D.new()
	var points := PackedVector2Array()
	var angle_step = _angle_size/(res-1)
	points.append(Vector2())
	for i in res:
		var angle = _angle_init + angle_step*i
		var p = Vector2.from_angle(angle) * _radius
		points.append(p)
	new_polygon.polygon = points
	
	#var user : RSTwitchUser = main.known_users[_streamer_info.user_login]
	#new_polygon.texture = await main.loader.load_texture_from_url(user.profile_image_url)
	#new_polygon.texture_repeat = CanvasItem.TEXTURE_REPEAT_ENABLED
	
	var line := Line2D.new()
	line.points = points
	line.width = 10 #px
	line.closed = true
	line.antialiased = true
	line.default_color = Color.WHITE_SMOKE
	new_polygon.add_child(line)
	
	var lb := Label.new()
	lb.text = choice
	lb.rotation = _angle_init + _angle_size/2
	lb.position = Vector2.from_angle(lb.rotation) * 64
	new_polygon.add_child(lb)
	return new_polygon


func _on_btn_kill_pressed():
	cancelled.emit()
	queue_free()
