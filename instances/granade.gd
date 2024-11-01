extends RSImageToRigid

@onready var area_destruct: Area2D = $area_destruct
@onready var area_push: Area2D = $area_push
@onready var sfx_boom: AudioStreamPlayer = $sfx_boom
@onready var white_circle: Polygon2D = $white_circle

var is_detonated := false

func _init() -> void:
	pass

func start():
	set_white_circle()
	params = RSBeansParam.new()
	if ! is_inside_tree():
		await tree_entered
	get_tree().create_timer(4.0).timeout.connect(destroy)

func destroy() -> void:
	if is_detonated: return
	is_detonated = true
	await get_tree().create_timer(randf_range(0.02, 0.1)).timeout
	sfx_boom.play()
	white_circle.show()
	var obj_to_destroy = area_destruct.get_overlapping_bodies()
	for body: PhysicsBody2D in obj_to_destroy:
		if body == self: continue
		if body.has_method("destroy"):
			body.call_deferred("destroy")
	for body: PhysicsBody2D in area_push.get_overlapping_bodies():
		if body == self: continue
		if !body is RigidBody2D: continue
		var dist = 1/body.global_position.distance_squared_to(global_position)
		var dir := global_position.direction_to(body.global_position)
		body.apply_central_impulse(dir * dist * 100000000)
	await get_tree().process_frame
	collision_layer = 0
	collision_mask = 0
	hide()
	await sfx_boom.finished
	super()


func set_white_circle():
	if !is_node_ready():
		await ready
	white_circle.hide()
	var r : float = area_destruct.get_node("coll").shape.radius
	var res = 36
	var angle_step = TAU/res
	var poly := [] as PackedVector2Array
	for i in res:
		var p := Vector2.RIGHT.rotated(angle_step * i) * r
		poly.append(p)
	white_circle.polygon = poly
