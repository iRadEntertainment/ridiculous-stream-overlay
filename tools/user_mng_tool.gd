@tool
extends EditorScript

func _run() -> void:
	pass


func load_all_users() -> Dictionary:
	RSLoader.new().load_all_user()
	return {}


func convert_all_users():
	var dic = {}
	var user_files = RSUtl.list_file_in_folder(RSSettings.get_users_path(), ["tres"])
	
	for user_file in user_files:
		var path = RSSettings.get_users_path() + user_file
		var username = RSLoader.username_from_userfile(user_file)
		var res = ResourceLoader.load(path, "", ResourceLoader.CACHE_MODE_IGNORE) as RSTwitchUser
		if res.username:
			pass
			# print("user loaded OK: ", res.username)
		else:
			print("user missing info: ", username)
		dic[username] = {"RSTwitchUser": res, "path": path}

	for username in dic.keys():
		var res := dic[username]["RSTwitchUser"] as RSTwitchUser
		var path := dic[username]["path"] as String
		path = path.trim_suffix("tres") + "json"
		RSUtl.save_to_json(path, res.to_dict())
