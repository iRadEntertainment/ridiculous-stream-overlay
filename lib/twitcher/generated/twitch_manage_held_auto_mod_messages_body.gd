@tool
extends RefCounted

# CLASS GOT AUTOGENERATED DON'T CHANGE MANUALLY. CHANGES CAN BE OVERWRITTEN EASILY.

class_name TwitchManageHeldAutoModMessagesBody

## The moderator who is approving or denying the held message. This ID must match the user ID in the access token.
var user_id: String:
	set(val):
		user_id = val;
		changed_data["user_id"] = user_id;
## The ID of the message to allow or deny.
var msg_id: String:
	set(val):
		msg_id = val;
		changed_data["msg_id"] = msg_id;
## The action to take for the message. Possible values are:      * ALLOW * DENY
var action: String:
	set(val):
		action = val;
		changed_data["action"] = action;

var changed_data: Dictionary = {};

static func from_json(d: Dictionary) -> TwitchManageHeldAutoModMessagesBody:
	var result = TwitchManageHeldAutoModMessagesBody.new();
	if d.has("user_id") && d["user_id"] != null:
		result.user_id = d["user_id"];
	if d.has("msg_id") && d["msg_id"] != null:
		result.msg_id = d["msg_id"];
	if d.has("action") && d["action"] != null:
		result.action = d["action"];
	return result;

func to_dict() -> Dictionary:
	return changed_data;

func to_json() -> String:
	return JSON.stringify(to_dict());
