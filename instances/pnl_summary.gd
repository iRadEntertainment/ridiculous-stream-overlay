extends PanelContainer
class_name PnlSummary

const TITLE_CENTER = "[font_size=50][center][b]%s[/b][/center][/font_size]"
const SUBTITLE_CENTER = "[font_size=32][center][b]%s[/b][/center][/font_size]"
const SUBTITLE_LEFT = "[font_size=32][b]%s[/b][/font_size]"
const TIME_HH_MM = "[font_size=32][b]{hour}:{minute}:{second}[/b][/font_size]"


func _ready() -> void:
	set_process(false)
	visibility_changed.connect(_on_visibility_changed)


func populate_with_summary() -> void:
	var space_before_after: int = 60
	%main_text.clear()
	# clear space
	for i: int in space_before_after:
		%main_text.newline()
	%main_text.append_text(TITLE_CENTER % "Stream ending")
	%main_text.newline()
	var stream_length: int = Time.get_unix_time_from_system() - RS.summary_mng.summary.stream_start
	var time_dict: Dictionary = Time.get_time_dict_from_unix_time(stream_length)
	print(time_dict)
	var stream_duration: String = TIME_HH_MM.format(time_dict)
	%main_text.append_text(stream_duration)
	
	# clear space
	for i: int in space_before_after:
		%main_text.newline()
	%main_text.get_v_scroll_bar().hide()


var accumulator: float = 0.0
func _process(delta: float) -> void:
	var tot_scroll_sec: float = 120.0 # seconds
	var bar: VScrollBar = %main_text.get_v_scroll_bar()
	bar.hide()
	accumulator += delta * (bar.max_value / tot_scroll_sec)
	if accumulator > 1.0:
		var integer: float = floorf(accumulator)
		accumulator -= integer
		bar.value += integer
	#prints(bar.value, delta * (bar.max_value / tot_scroll_sec))


func _on_visibility_changed() -> void:
	%main_text.visible = is_visible_in_tree()
	set_process(is_visible_in_tree())
	if is_visible_in_tree():
		populate_with_summary()
		var bar: VScrollBar = %main_text.get_v_scroll_bar()
		bar.value = 0
