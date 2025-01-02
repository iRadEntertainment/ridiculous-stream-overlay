@tool
extends Object

class_name TwitchSetting













# static func setup() -> void:
# 	# Auth
# 	_setup_scopes();
# 	_setup_subscriptions();

# 	# General

# 	const FALLBACK_TEXTURE = preload("./assets/fallback_texture.tres");
# 	_fallback_texture = Property.new("twitch/general/assets/fallback_texture", FALLBACK_TEXTURE.resource_path).as_image();
# 	const FALLBACK_PROFILE = preload("./assets/no_profile.png");
# 	_fallback_profile = Property.new("twitch/general/assets/fallback_profile", FALLBACK_PROFILE.resource_path).as_image().basic();

# 	# Websocket


# 	var default_connect_to_channel: Array[StringName] = [];
# 	_irc_connect_to_channel = Property.new("twitch/websocket/irc/connect_to_channel", default_connect_to_channel).as_list().basic();

# 	var default_caps: Array[TwitchIrcCapabilities.Capability] = [TwitchIrcCapabilities.COMMANDS, TwitchIrcCapabilities.TAGS];
# 	var default_cap_val = TwitchIrcCapabilities.get_bit_value(default_caps);
# 	_irc_capabilities = Property.new("twitch/websocket/irc/capabilities", default_cap_val).as_bit_field(_get_all_irc_capabilities()).basic();

# static func get_log_enabled() -> Array[String]:
# 	var result: Array[String] = [];
# 	# Other classes can be initialized before the settings and use the log.
# 	if _log_enabled == null:
# 		return result;
# 	var bitset = _log_enabled.get_val();
# 	if typeof(bitset) == TYPE_STRING && bitset == "" || typeof(bitset) == TYPE_INT && bitset == 0:
# 		return result
# 	for logger_idx: int in range(ALL_LOGGERS.size()):
# 		var bit_value = 1 << logger_idx;
# 		if bitset & bit_value == bit_value:
# 			result.append(ALL_LOGGERS[logger_idx])
# 	return result


# static func get_image_transformers() -> Array[String]:
# 	var result: Array[String] = [];
# 	var magic = MagicImageTransformer.new()
# 	if magic.is_supported():
# 		image_transformers["MagicImageTransformer"] = magic;
# 		result.append("MagicImageTransformer");

# 	var twitch = TwitchImageTransformer.new()
# 	image_transformers["TwitchImageTransformer"] = twitch;
# 	result.append("TwitchImageTransformer");

# 	var native = NativeImageTransformer.new()
# 	image_transformers["NativeImageTransformer"] = native;
# 	result.append("NativeImageTransformer");

# 	return result;

# static func get_image_transformer() -> TwitchImageTransformer:
# 	if image_transformers.has(image_tranformer_path):
# 		return image_transformers[image_tranformer_path];
# 	var transformer = load(image_tranformer_path);
# 	return transformer;

# ## Converts the categoriezed bitset back to the strings
# static func get_scopes() -> Array[String]:
# 	var grouped_scopes = TwitchScopes.get_grouped_scopes();
# 	var result: Array[String] = [];
# 	for category_name: String in grouped_scopes:
# 		var scope_property: Property = _scopes[category_name];
# 		var bitset = scope_property.get_val();
# 		if typeof(bitset) == TYPE_STRING && bitset == "" || typeof(bitset) == TYPE_INT && bitset == 0: continue
# 		var scopes = grouped_scopes[category_name];
# 		for scope: TwitchScopes.Scope in scopes:
# 			if bitset & scope.bit_value == scope.bit_value:
# 				result.append(scope.value)
# 	return result

# static func _setup_scopes():
# 	var grouped_scopes: Dictionary = TwitchScopes.get_grouped_scopes();

# 	for category_name: String in grouped_scopes:
# 		var scopes: Array = grouped_scopes[category_name];
# 		var scope_names: Array[String] = [];
# 		for scope: TwitchScopes.Scope in scopes:
# 			scope_names.append(scope.get_name());
# 		_scopes[category_name] = Property.new("twitch/auth/scopes/" + category_name, "").as_bit_field(scope_names).basic();


# static func _get_all_irc_capabilities() -> Array[String]:
# 	var caps = TwitchIrcCapabilities.get_all()
# 	var result: Array[String] = [];
# 	for cap in caps:
# 		result.append(cap.get_name());
# 	return result;

# static func get_irc_capabilities() -> Array[String]:
# 	var result: Array[String] = []
# 	var bitset = _irc_capabilities.get_val();
# 	if typeof(bitset) == TYPE_STRING && bitset == "" || typeof(bitset) == TYPE_INT && bitset == 0:
# 		return result;
# 	for cap : TwitchIrcCapabilities.Capability in TwitchIrcCapabilities.get_all():
# 		if bitset & cap.bit_value == cap.bit_value:
# 			result.append(cap.value);
# 	return result;

# # static func _setup_subscriptions():
# # 	for subscription in TwitchSubscriptions.get_all():
# # 		var subscription_properties = []
# # 		_subscriptions[subscription] = subscription_properties;
# # 		subscription_properties.append(Property.new("twitch/eventsub/%s/subscribed" % subscription.get_name(), false).as_bool().basic());
# # 		for condition in subscription.conditions:
# # 			subscription_properties.append(Property.new("twitch/eventsub/%s/%s" % [subscription.get_name(), condition], "").as_str().basic());

# ## Return the subscribed subscriptions key = TwitchSubscriptions.Subscription, value = Dictionary with conditions (ready to use)
# static func get_subscriptions() -> Dictionary:
# 	var result = {};
# 	for subscription in TwitchSubscriptions.get_all():
# 		var properties: Array = _subscriptions[subscription];
# 		var subscribed_property: Property = properties[0];

# 		if subscribed_property.get_val():
# 			result[subscription] = get_conditions(properties);
# 	return result;

# static func get_conditions(properties: Array) -> Dictionary:
# 	var condition: Dictionary = {}
# 	# Skip first property that is the "subscribed" boolean
# 	for property: Property in properties.slice(1):
# 		var condition_name: String = property.key
# 		condition_name = condition_name.substr(condition_name.rfind("/") + 1);
# 		condition[condition_name] = property.get_val();
# 	return condition;
