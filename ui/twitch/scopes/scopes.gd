static var scope_analytics_read_extensions := ScopeMetadata.new(
	"analytics:read:extensions",
	"View analytics data for the Twitch Extensions owned by the authenticated account.",
	[
		ScopeMetadata.Usage.new(
			"Get Extension Analytics",
			ScopeMetadata.UsageType.API,
			"https://dev.twitch.tv/docs/api/reference#get-extension-analytics"
		)
	]
)

# TODO: Change to Dictionary[StringName, ScopeMetadata] in Godot 4.4
static var lookup: Dictionary = {
	&"analytics:read:extensions": scope_analytics_read_extensions,
}
