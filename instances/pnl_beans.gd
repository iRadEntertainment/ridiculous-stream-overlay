extends PanelContainer
@onready var param_inspector: RSParamInspector = %param_inspector


func _on_btn_test_beans_pressed():
	# Grab parameters from the parameter inspector.
	param_inspector.params 
	# Pass parameter to the physics scene to spawn beans! >^^< 
	RS.physic_scene.add_image_bodies(param_inspector.params)
	push_error("We need more beans, bro.")
	pass # Replace with function body.


func _on_btn_save_beans_pressed():
	push_error("Lets save some of these bean babies for later.")
	pass # Replace with function body.


func _on_btn_load_beans_pressed():
	push_error("Sweet! Home-cooked beans I didn't have to cook myself.")
	pass # Replace with function body.
