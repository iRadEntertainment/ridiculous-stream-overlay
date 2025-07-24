@tool
extends EditorScript

var input_path := "res://tools/user_creation_times.txt"
var output_path_csv := "res://tools/user_creation_times.csv"
var output_path_json := "res://tools/user_creation_times.json"


func _run():
	#txt_to_csv(output_path_csv)
	txt_to_json(output_path_json)
	#var res := read_csv(output_path_csv)
	#for row in res:
		#print(row)


func read_csv(path: String) -> Array:
	var data := []
	var file := FileAccess.open(path, FileAccess.READ)
	if not file:
		push_error("Failed to open CSV: %s" % path)
		return data

	# First line is the header
	if file.eof_reached():
		return data
	
	var headers := file.get_line().strip_edges().split(",")

	while not file.eof_reached():
		var line := file.get_line().strip_edges()
		if line == "":
			continue
		var values := line.split(",")
		var row := {}
		for i in headers.size():
			if i < values.size():
				row[headers[i]] = values[i]
		data.append(row)

	return data


func txt_to_json(_output_path: String) -> void:
	var file := FileAccess.open(input_path, FileAccess.READ)
	if file == null:
		push_warning("Failed to open input file")
		return

	var result := {}  # Dictionary: {int: float}

	while not file.eof_reached():
		var line := file.get_line().strip_edges()
		if line == "":
			continue

		var split := line.rsplit(" ", false, 1)
		if split.size() != 2:
			push_warning("Invalid line format: " + line)
			continue

		var path := split[0]
		var timestamp := split[1]

		# Extract user ID from path
		var regex := RegEx.new()
		regex.compile(r"users\\(\d+)_")
		var match := regex.search(path)
		if not match:
			push_warning("User ID not found in path: " + path)
			continue

		var user_id := int(match.get_string(1))
		var added_on := float(timestamp)
		
		result[user_id] = added_on
	
	RSUtl.save_to_json(_output_path, result)
	print("JSON saved to: ", _output_path)


func txt_to_csv(_output_path: String) -> void:
	var file := FileAccess.open(input_path, FileAccess.READ)
	if not file:
		push_error("Failed to open input file")
		return
	
	var out_file := FileAccess.open(_output_path, FileAccess.WRITE)
	if not out_file:
		push_error("Failed to open output file")
		return
	
	# Write CSV header
	out_file.store_line("user_id,creation_unix")
	while not file.eof_reached():
		var line := file.get_line().strip_edges()
		if line == "":
			continue
		
		var split := line.rsplit(" ", false, 1)
		if split.size() != 2:
			push_warning("Line format unexpected: " + line)
			continue
		
		var path := split[0]
		var timestamp := split[1]
		
		# Extract user ID with regex
		var regex := RegEx.new()
		regex.compile(r"users\\(\d+)_")
		var match := regex.search(path)
		if match:
			var user_id := match.get_string(1)
			out_file.store_line("%s,%s" % [user_id, timestamp])
		else:
			push_warning("User ID not found in path: " + path)
	
	out_file.close()
	print("CSV generated at: ", _output_path)
