@tool
extends EditorScript


func _run() -> void:
	var tot_array: Array[int] = []
	for i: int in 220:
		tot_array.append(i)
	
	var iter: int = 0
	const MAX_ITER: int = 20
	var batched_arrays: Array = []
	while not tot_array.is_empty():
		# safe measures
		iter += 1
		if iter > MAX_ITER:
			push_error("Max iter reached")
			break
		
		var batch: Array[int] = tot_array.slice(0, 99)
		
