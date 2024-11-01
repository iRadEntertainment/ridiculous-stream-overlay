
extends Node2D

var duration = 20
var tw : Tween
var tmr: Timer

var space : PhysicsDirectSpaceState2D

var query : PhysicsRayQueryParameters2D
var obj_destroyed_counter : int = 0


func _ready():
	set_process(false)
	tmr = Timer.new()
	add_child(tmr)
	tmr.one_shot = true
	tmr.wait_time = 1.5
	tmr.timeout.connect(queue_free)


func play(angle: float):
	await get_tree().physics_frame
	set_process(true)
	space = get_world_2d().direct_space_state
	query = PhysicsRayQueryParameters2D.create(Vector2(), Vector2())
	query.collide_with_bodies = true
	query.collision_mask = 1+2+4+8+16+32
	
	var passes = 5
	set_process(true)
	tw = create_tween().bind_node(self)
	tw.set_ease(Tween.EASE_IN_OUT)
	tw.set_trans(Tween.TRANS_SINE)
	@warning_ignore("integer_division")
	var single_duration = duration/passes
	tw.tween_property(self, "rotation", angle, single_duration)
	tw.tween_property(self, "rotation", -angle, single_duration)
	tw.tween_property(self, "rotation", angle, single_duration)
	tw.tween_property(self, "rotation", -angle, single_duration)
	tw.tween_property(self, "rotation", 0, single_duration)


func replay():
	return
	# tw.tween_property(self, "rotation", TAU, 3.0)
	# await tw.finished
	# queue_free()


func _process(_d):
	if rotation == 0 and tmr.is_stopped():
		tmr.start()
	elif rotation != 0:
		tmr.stop()
	
	var firing = not Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)
	
	query.from = %ray.global_position
	query.to = %ray.global_position + %ray.target_position.rotated(rotation)
	var coll_dic : Dictionary = space.intersect_ray(query)
	var colliding = !coll_dic.is_empty()
	
	%line.visible = firing #and colliding
	%line.points[1] = %ray.target_position
	%impact_particles.emitting = colliding and firing
	
	if colliding and firing:
		var impact_pos = coll_dic.position
		var n = coll_dic.normal
		var n_angle = n.angle()
		var coll = coll_dic.collider
		
		%line.points[1].y = (impact_pos - %line.global_position).length()
		%impact_particles.global_position = impact_pos
		%impact_particles.global_rotation = n_angle + PI/2
		
		if coll.has_method("destroy"):
			coll.destroy()
			obj_destroyed_counter += 1
			%lb_counter.text = str(obj_destroyed_counter)
		elif coll is RigidBody2D and firing:
			coll.apply_impulse((Vector2.RIGHT * 30).rotated(n_angle+PI), impact_pos)
		
