@tool
extends Control

func _ready() -> void:
	name = "Ridiculous Stream"
	#var parent_control := get_parent_control()
	#if not parent_control is TabContainer:
		#print_debug("Parent is a %s not a TabContainer" % [parent_control.get_class() if parent_control else parent_control])
		#return
#
	#var tab_container := parent_control as TabContainer
	#for tab_index in tab_container.get_tab_count():
		#var tab_control := tab_container.get_tab_control(tab_index)
		#if tab_control != self:
			#print_debug("Tab %d is not this, it is a %s" % [
				#tab_index,
				#tab_control.get_class() if tab_control else tab_control
			#])
			#continue
		#tab_container.set_tab_title(tab_index, "Ridiculous Stream")

	var publish_mode_enabled := ProjectSettings.get_setting(
		"ridiculous_stream/twitch/publish",
		false
	);

	var default_grant_type_key := "IMPLICIT_FLOW" if publish_mode_enabled else "AUTHORIZATION_CODE_FLOW";
	var default_grant_type := OAuth.AuthorizationFlow.IMPLICIT_FLOW if publish_mode_enabled else OAuth.AuthorizationFlow.AUTHORIZATION_CODE_FLOW;
	%val_flow.selected = OAuth.AuthorizationFlow.get(
		ProjectSettings.get_setting(
			"ridiculous_stream/twitch/grant_type",
			default_grant_type_key
		),
		default_grant_type
	);

	if publish_mode_enabled and %val_flow.selected == OAuth.AuthorizationFlow.AUTHORIZATION_CODE_FLOW:
		%val_flow.selected = OAuth.AuthorizationFlow.IMPLICIT_FLOW;

	%val_publish.button_pressed = publish_mode_enabled;
	%val_clientid.editable = publish_mode_enabled;
	%val_clientid.text = ProjectSettings.get_setting("ridiculous_stream/twitch/client_id", "");
	%val_redirecturi.text = ProjectSettings.get_setting("ridiculous_stream/twitch/redirect_uri", "");

func _on_val_publish_toggled(toggled_on: bool) -> void:
	%val_clientid.editable = toggled_on
	if toggled_on and %val_flow.selected == OAuth.AuthorizationFlow.AUTHORIZATION_CODE_FLOW:
		%val_flow.selected = OAuth.AuthorizationFlow.IMPLICIT_FLOW;
		_on_val_flow_item_selected(OAuth.AuthorizationFlow.IMPLICIT_FLOW);
	ProjectSettings.set_setting("ridiculous_stream/twitch/publish", toggled_on);
	ProjectSettings.save();

func _on_val_flow_item_selected(index: int) -> void:
	ProjectSettings.set_setting(
		"ridiculous_stream/twitch/grant_type",
		OAuth.AuthorizationFlow.keys()[index]
	);
	ProjectSettings.save();

func _on_val_clientid_text_changed(new_text: String) -> void:
	ProjectSettings.set_setting("ridiculous_stream/twitch/client_id", new_text);
	ProjectSettings.save();

func _on_val_redirecturi_text_changed(new_text: String) -> void:
	ProjectSettings.set_setting("ridiculous_stream/twitch/redirect_uri", new_text);
	ProjectSettings.save();
