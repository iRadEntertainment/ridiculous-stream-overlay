@tool
extends EditorScript

const INFO_MSG = "[color=green]Updating... [color=orange][b]%s[/b][/color]"

func _run() -> void:
	# batch files
	var bootstrap_folder = r"C:\Git\Bootstrap_icons\bootstrap-icons-1.11.3/"
	var folder_path = "res://ui/icons/bootstrap_icons/"
	var file_paths = RSUtl.list_file_in_folder(bootstrap_folder, ["svg"], true)
	for file_path in file_paths:
		modify_svg_size(file_path, Vector2i.ONE * 48)
		modify_svg_color(file_path, "white")
		print_rich(INFO_MSG % file_path.get_file())
	
	# single file
	#var file_path = "res://ui/icons/bootstrap_icons/sparkles.svg"
	#modify_svg_size(file_path, Vector2i.ONE * 48)
	#print_rich(INFO_MSG % file_path.get_file())
	#print("end")


static func modify_svg_size(file_path: String, svg_size: Vector2i) -> void:
	var file := FileAccess.open(file_path, FileAccess.READ_WRITE)
	var content := file.get_as_text()

	# Match and replace width="..."
	var width_regex := RegEx.new()
	width_regex.compile(r'width="[^"]*"')
	content = width_regex.sub(content, 'width="%d"' % svg_size.x, true)

	# Match and replace height="..."
	var height_regex := RegEx.new()
	height_regex.compile(r'height="[^"]*"')
	content = height_regex.sub(content, 'height="%d"' % svg_size.y, true)

	# Match and replace style="height: ...; width: ...;"
	var style_regex := RegEx.new()
	style_regex.compile(r'style="height:[^;]*;\\s*width:[^;]*;"')
	content = style_regex.sub(content, 'style="height:%dpx; width:%dpx;"' % [svg_size.y, svg_size.x], true)
	
	file.store_string(content)
	file.close()


static func modify_svg_color(file_path: String, color: String) -> void:
	var file := FileAccess.open(file_path, FileAccess.READ_WRITE)
	var content := file.get_as_text()

	var fill_regex := RegEx.new()
	fill_regex.compile(r'fill="[^"]+"')
	content = fill_regex.sub(content, 'fill="%s"' % color, true)

	file.store_string(content)
	file.close()
