@tool
extends EditorScript

func _run() -> void:
	#OS.shell_open("brave://history/") doesnt' work
	OS.execute("C:/Program Files/BraveSoftware/Brave-Browser/Application/brave.exe", ["chrome://history"])
	#OS.execute("C:/Program Files/BraveSoftware/Brave-Browser/Application/brave.exe", ["about:history"])
	#OS.execute("C:/Program Files/BraveSoftware/Brave-Browser/Application/brave.exe", [r"https://www.twitch.tv/konradgryt"])
	#OS.execute("C:/Program Files/BraveSoftware/Brave-Browser/Application/brave.exe brave://history", [])
