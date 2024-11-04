@tool
extends EditorScript

func _run() -> void:
	pass


func load_all_users() -> Dictionary:
	RSLoader.new().load_all_user()
	return {}
