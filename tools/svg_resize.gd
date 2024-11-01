@tool
extends EditorScript

func _run():
	#var path = "res://editor_default.theme"
	#ResourceSaver.save(EditorInterface.get_editor_theme(), path, ResourceSaver.FLAG_BUNDLE_RESOURCES)
	
	ResourceSaver.save(EditorInterface.get_editor_theme() as Theme, "res://godot_theme.tres", ResourceSaver.FLAG_NONE)
	#var folder_path = "res://ui/bootstrap_icons/"
	#var file_paths = RSExternalLoader.list_file_in_folder(folder_path, ["svg"], true)
	#for file_path in file_paths:
		#print(file_path)
		#modify_file(file_path)
	
	#var file_circle_path = "res://addons/ridiculous_stream/ui/bootstrap_icons/0-circle.svg"
	#modify_file(file_circle_path)
	print("end")

func modify_file(file_path : String):
	var file = FileAccess.open(file_path, FileAccess.READ_WRITE)
	var content = file.get_as_text()
	content = content.replace('width=64', 'width=16')
	file.store_string(content)
	file.close()
