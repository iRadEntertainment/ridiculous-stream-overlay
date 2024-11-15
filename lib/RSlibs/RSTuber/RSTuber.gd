@tool
extends Control
class_name RSTuber

# https://godotshaders.com/shader/spectrum-analyzer/

@export var active_in_editor := false:
	set(val):
		active_in_editor = val
		if is_node_ready():
			%mic.playing = val

enum Scale{LINEAR, LOGARITMIC, OCTAVES}
@export var scale_type: Scale = Scale.LOGARITMIC

const VU_COUNT = 30

@export var freq_min: float = 20.0: # Hz
	set(val):
		freq_min = clamp(val, 20.0, 500.0)
@export var freq_max: float = 11050.0: # Hz
	set(val):
		freq_max = clamp(val, 501.0, 48000.0)
@export_range(12.0, 75.5) var min_db: float = 60.0
@export_range(0.2, 0.5, 0.01) var animation_speed: float = 0.28
const HEIGHT_SCALE = 8.0


var spectrum: AudioEffectSpectrumAnalyzerInstance
var min_values = []
var max_values = []

enum AudioBus {}
@export var audio_bus: AudioBus

func _validate_property(property: Dictionary):
	if property.name == "audio_bus":
		var busNumber = AudioServer.bus_count
		var options = ""
		for i in busNumber:
			if i > 0:
				options += ","
			var busName = AudioServer.get_bus_name(i)
			options += busName
		property.hint_string = options

func _ready():
	min_values.resize(VU_COUNT)
	min_values.fill(0.0)
	max_values.resize(VU_COUNT)
	max_values.fill(0.0)

func _process(_d):
	if Engine.is_editor_hint() and !active_in_editor:
		return
	spectrum = AudioServer.get_bus_effect_instance(1, 1)
	if not spectrum:
		return
	if !spectrum is AudioEffectSpectrumAnalyzerInstance:
		push_error("no it's %s" % spectrum)
		return
	var prev_hz = freq_min
	var data = []
	
	# 20 Hz -> 11050.0 Hz
	var hz: float
	for i in range(1, VU_COUNT + 1):
		match scale_type:
			Scale.LINEAR: hz = i * (freq_max - freq_min) / VU_COUNT
			Scale.LOGARITMIC: hz = freq_min * pow(freq_max / freq_min, float(i) / VU_COUNT)
			Scale.OCTAVES: hz = freq_min * pow(2, i / (VU_COUNT / log_base(freq_max / freq_min, 2)))
		
		var f = spectrum.get_magnitude_for_frequency_range(prev_hz, hz)
		
		var energy = clamp((min_db + linear_to_db(f.length())) / min_db, 0.0, 1.0)
		data.append(energy * HEIGHT_SCALE)
		prev_hz = hz
	
	for i in range(VU_COUNT):
		if data[i] > max_values[i]:
			max_values[i] = data[i]
		else:
			max_values[i] = lerp(max_values[i], data[i], animation_speed)
		if data[i] <= 0.0:
			min_values[i] = lerp(min_values[i], 0.0, animation_speed)
	var fft = []
	for i in range(VU_COUNT):
		fft.append(lerp(min_values[i], max_values[i], animation_speed))
	%spectrometer.material.set_shader_parameter("freq_data", fft)


func log_base(val: float, base: float) -> float:
	return log(val) / log(base)
