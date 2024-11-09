class_name ScopeMetadata
extends RefCounted

var description: StringName = &""
var name: StringName = &""
var usages: Array[Usage] = []

func _init(p_name: StringName, p_description: StringName, p_usages: Array[Usage] = []) -> void:
	description = p_description
	name = p_name
	usages = p_usages

enum UsageType {
	API,
	EVENTSUB,
	IRC,
	PUBSUB
}

class Usage extends RefCounted:
	var documentation_uri: StringName = &""
	var name: StringName = &""
	var type: UsageType

	func _init(p_name: StringName, p_type: UsageType, p_documentation_uri: StringName) -> void:
		documentation_uri = p_documentation_uri
		name = p_name
		type = p_type
