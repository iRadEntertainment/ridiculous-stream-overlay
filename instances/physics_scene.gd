extends Control
class_name RSPhysicsScene

@onready var bodies: Node2D = %bodies
@onready var right_coll: CollisionShape2D = %right_coll
@onready var bot_coll: CollisionShape2D = %bot_coll
@onready var pick_up_mouse_body: StaticBody2D = %pick_up_mouse_body
@onready var pin: PinJoint2D = %pin
@onready var sfx_list = %sfx_list

@onready var sfx_boom: AudioStreamPlayer = %sfx_boom
@onready var sfx_nuke: AudioStreamPlayer = %sfx_nuke
@onready var sfx_pluck: AudioStreamPlayer = %sfx_pluck

const SHARD_BODIES_CAP = 1200

var main : RSMain
var laser_scene

var default_gravity: float
var duration = 30.0 #s
var is_closing := false
var is_nuking := false
var _relative_mouse_vel: Vector2

var obj_count : int = 0 :
	set(val):
		obj_count = val
		count_updated.emit(obj_count)
signal count_updated(obj_count)


func _ready() -> void:
	resize_physic_borders()
	resized.connect(resize_physic_borders)
	default_gravity = ProjectSettings.get_setting("physics/2d/default_gravity")


func start(_main : RSMain):
	main = _main
	%fire.hide()


func _physics_process(_d: float) -> void:
	pick_up_mouse_body.global_position = get_global_mouse_position()


func _add_rigid(new_body : RigidBody2D, pos := Vector2(), linear_velocity := Vector2(), angular_velocity := 0.0, pickable := false):
	# TODO do we want timers or not?
	#reset_timers()
	# input from the body
	if pickable:
		var control_picker := Control.new()
		var coll_rect := Rect2()
		for coll in new_body.get_children():
			if coll is CollisionPolygon2D:
				for p in coll.polygon:
					if p.x < coll_rect.position.x:
						coll_rect.position.x = p.x
					if p.y < coll_rect.position.y:
						coll_rect.position.y = p.y
					if p.x > coll_rect.end.x:
						coll_rect.end.x = p.x
					if p.y > coll_rect.end.y:
						coll_rect.end.y = p.y
				break
			elif coll is CollisionShape2D:
				if new_body.has_method("start"):
					new_body.start()
				coll_rect = coll.shape.get_rect()
				coll_rect *= Transform2D(coll.rotation, Vector2() )
				break
		
		control_picker.position = coll_rect.position
		control_picker.size = coll_rect.size
		control_picker.gui_input.connect(_gui_control_box_signals.bind(new_body))
		control_picker.add_to_group("UI")
		
		new_body.add_child(control_picker)
	
	# position and physics
	var safe = 60
	if pos == Vector2():
		pos.x = clamp(randf_range(0, size.x), safe, size.x - safe)
		pos.y = clamp(randf_range(0, size.y), safe, size.y - safe)
	new_body.position = pos
	new_body.linear_velocity = linear_velocity
	new_body.angular_velocity = angular_velocity
	
	# finalizing
	for dic in new_body.get_property_list():
		if "physics_scene" == dic.name:
			new_body.physics_scene = self
			break
	$bodies.add_child(new_body)
	obj_count += 1
	new_body.add_to_group("editor_bodies")
	new_body.owner = $bodies.owner
	if new_body.has_method("start"):
		new_body.start()
	new_body.tree_exiting.connect(remove_obj_from_count)
	#add_body_to_space(new_body)
func remove_obj_from_count():
	obj_count -= 1

func generate_text_rigidbody(text : String, col : Color, lb_font_size : int):
	var lb_body : RigidBody2D = await $label_renderer.generate_text_rigidbody(text, col, lb_font_size)
	lb_body.mass = 0.3
	var safe = 120
	var pos = Vector2(randf_range(safe ,size.x-safe*3), randf_range(safe, safe*3))
	var linear_velocity = Vector2((randf()-0.5)*30, (randf()-0.5)*30)
	var angular_velocity = (randf()-0.5)*10
	_add_rigid.call_deferred(lb_body, pos, linear_velocity, angular_velocity, true)


func add_image_bodies(params : RSBeansParam, pos = null, linear_velocity = null, angular_velocity = null):
	if params.img_paths.is_empty():
		print("RSPhysics: no image passed to 'add_image_bodies()'")
		return
	var texs : Array[Texture2D] = []
	for tex_path in params.img_paths:
		if tex_path.is_empty(): continue
		texs.append(main.loader.load_texture_from_data_folder(tex_path))
	
	var sfx_streams : Array[AudioStream] = []
	for sfx_path in params.sfx_paths:
		if sfx_path.is_empty(): continue
		sfx_streams.append(main.loader.load_sfx_from_sfx_folder(sfx_path))
	
	var num = range(params.spawn_range[0], params.spawn_range[1]+1).pick_random()
	for i in num:
		if obj_count > SHARD_BODIES_CAP: continue
		var tex = texs.pick_random()
		var body := RSImageToRigid.new(tex, params, sfx_streams)
		body.rotation = randf_range(0, TAU)
		var physic_material := PhysicsMaterial.new()
		physic_material.friction = 0.95
		physic_material.bounce = 0.25
		body.physics_material_override = physic_material
		var final_pos := Vector2()
		if not pos:
			#var safe = 120
			#final_pos = Vector2(randf_range(safe , size.x-safe*3), randf_range(safe, safe*3))
			final_pos = size/2
		else:
			final_pos = pos + Vector2.ONE.rotated(randf_range(0, TAU)) * randf_range(40, 80)
		if not linear_velocity:
			linear_velocity = Vector2((randf()-0.5)*30, (randf()-0.5)*30)
		if not angular_velocity:
			angular_velocity = (randf()-0.5)*10
		
		_add_rigid(body, final_pos, linear_velocity, angular_velocity, true)
		await get_tree().physics_frame


func add_laser(angle: float) -> void:
	if not laser_scene:
		laser_scene = main.globals.laser_scene_pack.instantiate()
		laser_scene.position = size/2
		add_child(laser_scene)
		laser_scene.play(angle)
	else:
		laser_scene.play(angle)


func add_rigid_body_from_image(tex: Texture2D, body_scale: float = 1.0) -> RigidBody2D:
	if !tex: return
	var tex_size = tex.get_size() * body_scale
	var new_body := RigidBody2D.new()
	
	var physic_material := PhysicsMaterial.new()
	physic_material.friction = 0.95
	physic_material.bounce = 0.25
	new_body.mass *= pow(body_scale, 2)
	new_body.physics_material_override = physic_material
	
	var coll := CollisionShape2D.new()
	var shape := CapsuleShape2D.new()
	shape.radius = tex_size.x / 2.0
	shape.height = tex_size.y
	coll.shape = shape
	
	var sprite := Sprite2D.new()
	sprite.texture = tex
	sprite.name = "sprite"
	sprite.scale *= body_scale
	new_body.add_child(sprite)
	new_body.add_child(coll)
	
	var control_box := Control.new()
	control_box.size = tex_size
	control_box.position = -tex_size/2.0
	control_box.add_to_group("UI")
	control_box.gui_input.connect(_gui_control_box_signals.bind(new_body))
	new_body.add_child(control_box)
	
	new_body.position = size / 2.0
	bodies.add_child(new_body)
	return new_body

func zero_g() -> void:
	interpolate_gravity(0)
	shake_bodies()
	var tw = create_tween()
	tw.tween_callback(shake_bodies)
	tw.tween_callback(shake_bodies).set_delay(duration)
	tw.tween_method(interpolate_gravity, 0, default_gravity, 5.0)

func interpolate_gravity(new_gravity: float):
	var space: RID = bodies.get_world_2d().space
	PhysicsServer2D.area_set_param(space, PhysicsServer2D.AREA_PARAM_GRAVITY, new_gravity)
	#ProjectSettings.set("physics/2d/default_gravity_vector:y", new_gravity)


func shake_bodies():
	for body : RigidBody2D in get_tree().get_nodes_in_group("editor_bodies"):
		var force = Vector2.from_angle(randf_range(-PI, PI)) * 100
		body.apply_impulse(force)


func toggle_top_boundary(val : bool):
	$boundaries/n.set_deferred("disabled", !val)


func disable_boundaries():
	is_closing = true
	$boundaries.collision_layer = 0
	$boundaries.collision_mask  = 0
	set_all_bodies_sleeping(false)


func set_all_bodies_sleeping(val : bool):
	for body in get_tree().get_nodes_in_group("editor_bodies"):
		body.sleeping = val


func resize_physic_borders():
	if not is_node_ready(): return
	right_coll.position.x = size.x
	bot_coll.position.y = size.y

func is_sfx_free() -> bool:
	var is_too_early_to_play_another_one := false
	var one_is_free := false
	for sfx: AudioStreamPlayer in %sfx_list.get_children():
		if !sfx.has_stream_playback():
			one_is_free = true
		elif sfx.get_playback_position() < randf_range(0.02, 0.04):
			is_too_early_to_play_another_one = true
	return one_is_free and not is_too_early_to_play_another_one

func play_sfx(stream : AudioStream, volume_db: int) -> void:
	for sfx: AudioStreamPlayer in %sfx_list.get_children():
		if !sfx.has_stream_playback():
			sfx.volume_db = volume_db
			sfx.stream = stream
			sfx.pitch_scale = randf_range(0.95, 1.05)
			sfx.play()
			break

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.is_released() and event.button_index == MOUSE_BUTTON_LEFT:
			unpin_bodies()
	if event is InputEventMouseMotion:
		_relative_mouse_vel = event.relative


func _gui_control_box_signals(event: InputEvent, body: RigidBody2D) -> void:
	if event is InputEventMouseButton:
		if event.is_pressed():
			if event.button_index == MOUSE_BUTTON_LEFT:
				pin_rigid_body(body)
			elif event.button_index == MOUSE_BUTTON_RIGHT:
				if body.has_method("destroy"):
					body.call_deferred("destroy")
				else:
					body.queue_free()


func pin_rigid_body(body):
	sfx_pluck.play()
	unpin_bodies()
	pin.node_b = pin.get_path_to(body)


func unpin_bodies():
	var body: RigidBody2D
	if pin.node_b != NodePath():
		body = pin.get_node_or_null(pin.node_b)
		if body:
			body.apply_central_impulse(_relative_mouse_vel*10)
	pin.node_b = NodePath()


func spawn_grenade():
	var granade := main.globals.granade_pack.instantiate()
	_add_rigid(granade, Vector2(), Vector2(), randf_range(-5.0, 5.0), true)


func nuke():
	if is_nuking: return
	is_nuking = true
	sfx_nuke.play()
	await sfx_nuke.finished
	sfx_boom.play()
	start_bottom_fire(2.5)
	for body: RigidBody2D in bodies.get_children():
		body.queue_free()
	if is_instance_valid(laser_scene):
		laser_scene.queue_free()
	await sfx_boom.finished
	sfx_pluck.play()
	await get_tree().create_timer(10).timeout
	is_nuking = false
	

func start_bottom_fire(flames_duration: float) -> void:
	%fire.show()
	var in_out_time = 0.6
	var tw = create_tween()
	tw.bind_node(self)
	tw.set_ease(Tween.EASE_OUT)
	tw.set_trans(Tween.TRANS_CUBIC)
	tw.tween_method(tweak_flames_height, 0.0, 1.0, in_out_time)
	tw.tween_interval(flames_duration)
	tw.tween_method(tweak_flames_height, 1.0, 0.0, in_out_time)
	tw.tween_callback(%fire.hide)
func tweak_flames_height(val: float) -> void:
	%fire.material.set_shader_parameter("spread", val)
