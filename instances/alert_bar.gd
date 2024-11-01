extends PanelContainer
class_name RSAlertBar

@onready var progress_time_left: ProgressBar = %progress_time_left
@onready var btn_close: Button = %btn_close
@onready var message: RichTextLabel = %message


var timer : Timer
var has_seconds := false
var text: String

signal finished(is_completed)

func start(bbcode: String, callable_with_bindings: Callable, duration : float) -> void:
	text = bbcode
	message.text = bbcode
	has_seconds = bbcode.find("{sec_left}") != -1
	progress_time_left.max_value = duration
	progress_time_left.value = duration
	timer = Timer.new()
	add_child(timer)
	timer.one_shot = true
	timer.wait_time = duration
	timer.start()
	timer.timeout.connect(callable_with_bindings)
	timer.timeout.connect(finished.emit.bind(true))
	timer.timeout.connect(queue_free)

func _process(_d: float) -> void:
	if !is_inside_tree(): return
	if has_seconds:
		message.text = text.format({"sec_left": "%01d"%timer.time_left})
	progress_time_left.value = timer.time_left

func cancel():
	set_process(false)
	timer.queue_free()
	finished.emit(false)
	queue_free()
