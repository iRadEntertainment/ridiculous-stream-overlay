@tool
extends EditorScript


func _run() -> void:
	print(Time.get_unix_time_from_datetime_dict({
		"year": 2025,
		"month": 7,
		"day": 25,
		"hour": 16,
		"minute": 0,
	}))
