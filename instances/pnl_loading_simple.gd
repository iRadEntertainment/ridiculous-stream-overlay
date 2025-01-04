extends PanelContainer

@export var rotation_speed: float = 1.0

func _ready() -> void:
	stop()

func start() -> void:
	show()
	set_process(true)


func stop() -> void:
	hide()
	set_process(false)


func _process(d: float) -> void:
	%loading_ico.rotation += d * TAU * rotation_speed
	%loading_ico.rotation = wrapf(%loading_ico.rotation, 0, TAU)
