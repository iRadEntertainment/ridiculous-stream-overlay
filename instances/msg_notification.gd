# notification wave

extends Control

@onready var part_1: GPUParticles2D = $part_1
@onready var part_2: GPUParticles2D = $part_2
@onready var part_3: GPUParticles2D = $part_3
@onready var part_4: GPUParticles2D = $part_4


var duration = 1.5
var username : String = ""

func start(_username: String) -> void:
	username = _username
	part_2.position.x = size.x
	part_3.position = size
	part_4.position.y = size.y
	
	var hashed = hash(username)
	var assigned_num := (hashed % 11) as int
	var sound_path = "sfx_notification_%02d.ogg"%[assigned_num]
	if username in RS.user_mng.known.keys():
		var user := RS.user_mng.known[username] as RSTwitchUser
		if !user.custom_notification_sfx.is_empty():
			sound_path = user.custom_notification_sfx
	
	$sfx.stream = RS.loader.load_sfx_from_sfx_folder(sound_path)
	$sfx.play()
	for part: GPUParticles2D in [part_1, part_2, part_3, part_4]:
		part.emitting = true
	get_tree().create_timer(duration).timeout.connect(queue_free)
