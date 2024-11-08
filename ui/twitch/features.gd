const FeatureTypes = preload("res://ui/twitch/feature_types.gd");
const ScopedFeatureDefinition = FeatureTypes.ScopedFeatureDefinition;
const ScopedFeatureDefinitionCategory = FeatureTypes.ScopedFeatureDefinitionCategory;
const ScopedFeatureSet = FeatureTypes.ScopedFeatureSet;

#region Feature Set API Features

#region Feature Category API Features

static var feature_start_commercial: ScopedFeatureDefinition = ScopedFeatureDefinition.from(
	"start-commercial",
	"Start Commercial",
	"https://dev.twitch.tv/docs/api/reference/#start-commercial",
	"Starts a commercial on the specified channel.",
	[
		"channel:edit:commercial"
	]
);

static var feature_get_ad_schedule: ScopedFeatureDefinition = ScopedFeatureDefinition.from(
	"get-ad-schedule",
	"Get Ad Schedule",
	"https://dev.twitch.tv/docs/api/reference/#get-ad-schedule",
	"Returns ad schedule related information.",
	[
		"channel:read:ads"
	]
);

static var feature_snooze_next_ad: ScopedFeatureDefinition = ScopedFeatureDefinition.from(
	"snooze-next-ad",
	"Snooze Next Ad",
	"https://dev.twitch.tv/docs/api/reference/#snooze-next-ad",
	"Pushes back the timestamp of the upcoming automatic mid-roll ad by 5 minutes.",
	[
		"channel:manage:ads"
	]
);

static var feature_category_ads: ScopedFeatureDefinitionCategory = ScopedFeatureDefinitionCategory.from(
	"Ads",
	[
		feature_start_commercial,
		feature_get_ad_schedule,
		feature_snooze_next_ad
	]
);

#endregion Feature Category API Features

#region Feature Category API Features

static var feature_get_extension_analytics: ScopedFeatureDefinition = ScopedFeatureDefinition.from(
	"get-extension-analytics",
	"Get Extension Analytics",
	"https://dev.twitch.tv/docs/api/reference/#get-extension-analytics",
	"Gets an analytics report for one or more extensions.",
	[
		"analytics:read:extensions"
	]
);

static var feature_get_game_analytics: ScopedFeatureDefinition = ScopedFeatureDefinition.from(
	"get-game-analytics",
	"Get Game Analytics",
	"https://dev.twitch.tv/docs/api/reference/#get-game-analytics",
	"Gets an analytics report for one or more games.",
	[
		"analytics:read:games"
	]
);

static var feature_category_analytics: ScopedFeatureDefinitionCategory = ScopedFeatureDefinitionCategory.from(
	"Analytics",
	[
		feature_get_extension_analytics,
		feature_get_game_analytics
	]
);

#endregion Feature Category API Features

#region Feature Category API Features

static var feature_get_bits_leaderboard: ScopedFeatureDefinition = ScopedFeatureDefinition.from(
	"get-bits-leaderboard",
	"Get Bits Leaderboard",
	"https://dev.twitch.tv/docs/api/reference/#get-bits-leaderboard",
	"Gets the Bits leaderboard for the authenticated broadcaster.",
	[
		"bits:read"
	]
);

static var feature_get_cheermotes: ScopedFeatureDefinition = ScopedFeatureDefinition.from(
	"get-cheermotes",
	"Get Cheermotes",
	"https://dev.twitch.tv/docs/api/reference/#get-cheermotes",
	"Gets a list of Cheermotes that users can use to cheer Bits.",
	[

	]
);

static var feature_get_extension_transactions: ScopedFeatureDefinition = ScopedFeatureDefinition.from(
	"get-extension-transactions",
	"Get Extension Transactions",
	"https://dev.twitch.tv/docs/api/reference/#get-extension-transactions",
	"Gets an extension’s list of transactions.",
	[

	]
);

static var feature_category_bits: ScopedFeatureDefinitionCategory = ScopedFeatureDefinitionCategory.from(
	"Bits",
	[
		feature_get_bits_leaderboard,
		feature_get_cheermotes,
		feature_get_extension_transactions
	]
);

#endregion Feature Category API Features

#region Feature Category API Features

static var feature_get_channel_information: ScopedFeatureDefinition = ScopedFeatureDefinition.from(
	"get-channel-information",
	"Get Channel Information",
	"https://dev.twitch.tv/docs/api/reference/#get-channel-information",
	"Gets information about one or more channels.",
	[

	]
);

static var feature_modify_channel_information: ScopedFeatureDefinition = ScopedFeatureDefinition.from(
	"modify-channel-information",
	"Modify Channel Information",
	"https://dev.twitch.tv/docs/api/reference/#modify-channel-information",
	"Updates a channel’s properties.",
	[
		"channel:manage:broadcast"
	]
);

static var feature_get_channel_editors: ScopedFeatureDefinition = ScopedFeatureDefinition.from(
	"get-channel-editors",
	"Get Channel Editors",
	"https://dev.twitch.tv/docs/api/reference/#get-channel-editors",
	"Gets the broadcaster’s list editors.",
	[
		"channel:read:editors"
	]
);

static var feature_get_followed_channels: ScopedFeatureDefinition = ScopedFeatureDefinition.from(
	"get-followed-channels",
	"Get Followed Channels",
	"https://dev.twitch.tv/docs/api/reference/#get-followed-channels",
	"Gets a list of broadcasters that the specified user follows. You can also use this endpoint to see whether a user follows a specific broadcaster.",
	[
		"user:read:follows"
	]
);

static var feature_get_channel_followers: ScopedFeatureDefinition = ScopedFeatureDefinition.from(
	"get-channel-followers",
	"Get Channel Followers",
	"https://dev.twitch.tv/docs/api/reference/#get-channel-followers",
	"Gets a list of users that follow the specified broadcaster. You can also use this endpoint to see whether a specific user follows the broadcaster.",
	[
		"moderator:read:followers"
	]
);

static var feature_category_channels: ScopedFeatureDefinitionCategory = ScopedFeatureDefinitionCategory.from(
	"Channels",
	[
		feature_get_channel_information,
		feature_modify_channel_information,
		feature_get_channel_editors,
		feature_get_followed_channels,
		feature_get_channel_followers
	]
);

#endregion Feature Category API Features

#region Feature Category API Features

static var feature_create_custom_rewards: ScopedFeatureDefinition = ScopedFeatureDefinition.from(
	"create-custom-rewards",
	"Create Custom Rewards",
	"https://dev.twitch.tv/docs/api/reference/#create-custom-rewards",
	"Creates a Custom Reward in the broadcaster’s channel.",
	[
		"channel:manage:redemptions"
	]
);

static var feature_delete_custom_reward: ScopedFeatureDefinition = ScopedFeatureDefinition.from(
	"delete-custom-reward",
	"Delete Custom Reward",
	"https://dev.twitch.tv/docs/api/reference/#delete-custom-reward",
	"Deletes a custom reward that the broadcaster created.",
	[
		"channel:manage:redemptions"
	]
);

static var feature_get_custom_reward: ScopedFeatureDefinition = ScopedFeatureDefinition.from(
	"get-custom-reward",
	"Get Custom Reward",
	"https://dev.twitch.tv/docs/api/reference/#get-custom-reward",
	"Gets a list of custom rewards that the specified broadcaster created.",
	[
		"channel:read:redemptions",
		"channel:manage:redemptions"
	]
);

static var feature_get_custom_reward_redemption: ScopedFeatureDefinition = ScopedFeatureDefinition.from(
	"get-custom-reward-redemption",
	"Get Custom Reward Redemption",
	"https://dev.twitch.tv/docs/api/reference/#get-custom-reward-redemption",
	"Gets a list of redemptions for a custom reward.",
	[
		"channel:read:redemptions",
		"channel:manage:redemptions"
	]
);

static var feature_update_custom_reward: ScopedFeatureDefinition = ScopedFeatureDefinition.from(
	"update-custom-reward",
	"Update Custom Reward",
	"https://dev.twitch.tv/docs/api/reference/#update-custom-reward",
	"Updates a custom reward.",
	[
		"channel:manage:redemptions"
	]
);

static var feature_update_redemption_status: ScopedFeatureDefinition = ScopedFeatureDefinition.from(
	"update-redemption-status",
	"Update Redemption Status",
	"https://dev.twitch.tv/docs/api/reference/#update-redemption-status",
	"Updates a redemption’s status.",
	[
		"channel:manage:redemptions"
	]
);

static var feature_category_channel_points: ScopedFeatureDefinitionCategory = ScopedFeatureDefinitionCategory.from(
	"Channel Points",
	[
		feature_create_custom_rewards,
		feature_delete_custom_reward,
		feature_get_custom_reward,
		feature_get_custom_reward_redemption,
		feature_update_custom_reward,
		feature_update_redemption_status
	]
);

#endregion Feature Category API Features

#region Feature Category API Features

static var feature_get_charity_campaign: ScopedFeatureDefinition = ScopedFeatureDefinition.from(
	"get-charity-campaign",
	"Get Charity Campaign",
	"https://dev.twitch.tv/docs/api/reference/#get-charity-campaign",
	"Gets information about the broadcaster’s active charity campaign.",
	[
		"channel:read:charity"
	]
);

static var feature_get_charity_campaign_donations: ScopedFeatureDefinition = ScopedFeatureDefinition.from(
	"get-charity-campaign-donations",
	"Get Charity Campaign Donations",
	"https://dev.twitch.tv/docs/api/reference/#get-charity-campaign-donations",
	"Gets the list of donations that users have made to the broadcaster’s active charity campaign.",
	[
		"channel:read:charity"
	]
);

static var feature_category_charity: ScopedFeatureDefinitionCategory = ScopedFeatureDefinitionCategory.from(
	"Charity",
	[
		feature_get_charity_campaign,
		feature_get_charity_campaign_donations
	]
);

#endregion Feature Category API Features

#region Feature Category API Features

static var feature_get_chatters: ScopedFeatureDefinition = ScopedFeatureDefinition.from(
	"get-chatters",
	"Get Chatters",
	"https://dev.twitch.tv/docs/api/reference/#get-chatters",
	"Gets the list of users that are connected to the broadcaster’s chat session.",
	[
		"moderator:read:chatters"
	]
);

static var feature_get_channel_emotes: ScopedFeatureDefinition = ScopedFeatureDefinition.from(
	"get-channel-emotes",
	"Get Channel Emotes",
	"https://dev.twitch.tv/docs/api/reference/#get-channel-emotes",
	"Gets the broadcaster’s list of custom emotes.",
	[

	]
);

static var feature_get_global_emotes: ScopedFeatureDefinition = ScopedFeatureDefinition.from(
	"get-global-emotes",
	"Get Global Emotes",
	"https://dev.twitch.tv/docs/api/reference/#get-global-emotes",
	"Gets all global emotes.",
	[

	]
);

static var feature_get_emote_sets: ScopedFeatureDefinition = ScopedFeatureDefinition.from(
	"get-emote-sets",
	"Get Emote Sets",
	"https://dev.twitch.tv/docs/api/reference/#get-emote-sets",
	"Gets emotes for one or more specified emote sets.",
	[

	]
);

static var feature_get_channel_chat_badges: ScopedFeatureDefinition = ScopedFeatureDefinition.from(
	"get-channel-chat-badges",
	"Get Channel Chat Badges",
	"https://dev.twitch.tv/docs/api/reference/#get-channel-chat-badges",
	"Gets the broadcaster’s list of custom chat badges.",
	[

	]
);

static var feature_get_global_chat_badges: ScopedFeatureDefinition = ScopedFeatureDefinition.from(
	"get-global-chat-badges",
	"Get Global Chat Badges",
	"https://dev.twitch.tv/docs/api/reference/#get-global-chat-badges",
	"Gets Twitch’s list of chat badges.",
	[

	]
);

static var feature_get_chat_settings: ScopedFeatureDefinition = ScopedFeatureDefinition.from(
	"get-chat-settings",
	"Get Chat Settings",
	"https://dev.twitch.tv/docs/api/reference/#get-chat-settings",
	"Gets the broadcaster’s chat settings.",
	[
		"moderator:read:chat_settings"
	]
);

static var feature_get_shared_chat_session: ScopedFeatureDefinition = ScopedFeatureDefinition.from(
	"get-shared-chat-session",
	"Get Shared Chat Session",
	"https://dev.twitch.tv/docs/api/reference/#get-shared-chat-session",
	"NEW Retrieves the active shared chat session for a channel.",
	[

	]
);

static var feature_get_user_emotes: ScopedFeatureDefinition = ScopedFeatureDefinition.from(
	"get-user-emotes",
	"Get User Emotes",
	"https://dev.twitch.tv/docs/api/reference/#get-user-emotes",
	"NEW Retrieves emotes available to the user across all channels.",
	[
		"user:read:emotes"
	]
);

static var feature_update_chat_settings: ScopedFeatureDefinition = ScopedFeatureDefinition.from(
	"update-chat-settings",
	"Update Chat Settings",
	"https://dev.twitch.tv/docs/api/reference/#update-chat-settings",
	"Updates the broadcaster’s chat settings.",
	[
		"moderator:manage:chat_settings"
	]
);

static var feature_send_chat_announcement: ScopedFeatureDefinition = ScopedFeatureDefinition.from(
	"send-chat-announcement",
	"Send Chat Announcement",
	"https://dev.twitch.tv/docs/api/reference/#send-chat-announcement",
	"Sends an announcement to the broadcaster’s chat room.",
	[
		"moderator:manage:announcements"
	]
);

static var feature_send_a_shoutout: ScopedFeatureDefinition = ScopedFeatureDefinition.from(
	"send-a-shoutout",
	"Send a Shoutout",
	"https://dev.twitch.tv/docs/api/reference/#send-a-shoutout",
	"Sends a Shoutout to the specified broadcaster.",
	[
		"moderator:manage:shoutouts"
	]
);

static var feature_send_chat_message: ScopedFeatureDefinition = ScopedFeatureDefinition.from(
	"send-chat-message",
	"Send Chat Message",
	"https://dev.twitch.tv/docs/api/reference/#send-chat-message",
	"NEW Sends a message to the broadcaster’s chat room.",
	[
		"channel:bot",
		"user:bot",
		"user:write:chat"
	]
);

static var feature_get_user_chat_color: ScopedFeatureDefinition = ScopedFeatureDefinition.from(
	"get-user-chat-color",
	"Get User Chat Color",
	"https://dev.twitch.tv/docs/api/reference/#get-user-chat-color",
	"Gets the color used for the user’s name in chat.",
	[

	]
);

static var feature_update_user_chat_color: ScopedFeatureDefinition = ScopedFeatureDefinition.from(
	"update-user-chat-color",
	"Update User Chat Color",
	"https://dev.twitch.tv/docs/api/reference/#update-user-chat-color",
	"Updates the color used for the user’s name in chat.",
	[
		"user:manage:chat_color"
	]
);

static var feature_category_chat: ScopedFeatureDefinitionCategory = ScopedFeatureDefinitionCategory.from(
	"Chat",
	[
		feature_get_chatters,
		feature_get_channel_emotes,
		feature_get_global_emotes,
		feature_get_emote_sets,
		feature_get_channel_chat_badges,
		feature_get_global_chat_badges,
		feature_get_chat_settings,
		feature_get_shared_chat_session,
		feature_get_user_emotes,
		feature_update_chat_settings,
		feature_send_chat_announcement,
		feature_send_a_shoutout,
		feature_send_chat_message,
		feature_get_user_chat_color,
		feature_update_user_chat_color
	]
);

#endregion Feature Category API Features

#region Feature Category API Features

static var feature_create_clip: ScopedFeatureDefinition = ScopedFeatureDefinition.from(
	"create-clip",
	"Create Clip",
	"https://dev.twitch.tv/docs/api/reference/#create-clip",
	"Creates a clip from the broadcaster’s stream.",
	[
		"clips:edit"
	]
);

static var feature_get_clips: ScopedFeatureDefinition = ScopedFeatureDefinition.from(
	"get-clips",
	"Get Clips",
	"https://dev.twitch.tv/docs/api/reference/#get-clips",
	"Gets one or more video clips.",
	[

	]
);

static var feature_category_clips: ScopedFeatureDefinitionCategory = ScopedFeatureDefinitionCategory.from(
	"Clips",
	[
		feature_create_clip,
		feature_get_clips
	]
);

#endregion Feature Category API Features

#region Feature Category API Features

static var feature_get_conduits: ScopedFeatureDefinition = ScopedFeatureDefinition.from(
	"get-conduits",
	"Get Conduits",
	"https://dev.twitch.tv/docs/api/reference/#get-conduits",
	"NEW  Gets the conduits for a client ID.",
	[

	]
);

static var feature_create_conduits: ScopedFeatureDefinition = ScopedFeatureDefinition.from(
	"create-conduits",
	"Create Conduits",
	"https://dev.twitch.tv/docs/api/reference/#create-conduits",
	"NEW Creates a new conduit.",
	[

	]
);

static var feature_update_conduits: ScopedFeatureDefinition = ScopedFeatureDefinition.from(
	"update-conduits",
	"Update Conduits",
	"https://dev.twitch.tv/docs/api/reference/#update-conduits",
	"NEW Updates a conduit’s shard count.",
	[

	]
);

static var feature_delete_conduit: ScopedFeatureDefinition = ScopedFeatureDefinition.from(
	"delete-conduit",
	"Delete Conduit",
	"https://dev.twitch.tv/docs/api/reference/#delete-conduit",
	"NEW Deletes a specified conduit.",
	[

	]
);

static var feature_get_conduit_shards: ScopedFeatureDefinition = ScopedFeatureDefinition.from(
	"get-conduit-shards",
	"Get Conduit Shards",
	"https://dev.twitch.tv/docs/api/reference/#get-conduit-shards",
	"NEW Gets a lists of all shards for a conduit.",
	[

	]
);

static var feature_update_conduit_shards: ScopedFeatureDefinition = ScopedFeatureDefinition.from(
	"update-conduit-shards",
	"Update Conduit Shards",
	"https://dev.twitch.tv/docs/api/reference/#update-conduit-shards",
	"NEW Updates shard(s) for a conduit.",
	[

	]
);

static var feature_category_conduits: ScopedFeatureDefinitionCategory = ScopedFeatureDefinitionCategory.from(
	"Conduits",
	[
		feature_get_conduits,
		feature_create_conduits,
		feature_update_conduits,
		feature_delete_conduit,
		feature_get_conduit_shards,
		feature_update_conduit_shards
	]
);

#endregion Feature Category API Features

#region Feature Category API Features

static var feature_get_content_classification_labels: ScopedFeatureDefinition = ScopedFeatureDefinition.from(
	"get-content-classification-labels",
	"Get Content Classification Labels",
	"https://dev.twitch.tv/docs/api/reference/#get-content-classification-labels",
	"Gets information about Twitch content classification labels.",
	[

	]
);

static var feature_category_ccls: ScopedFeatureDefinitionCategory = ScopedFeatureDefinitionCategory.from(
	"CCLs",
	[
		feature_get_content_classification_labels
	]
);

#endregion Feature Category API Features

#region Feature Category API Features

static var feature_get_drops_entitlements: ScopedFeatureDefinition = ScopedFeatureDefinition.from(
	"get-drops-entitlements",
	"Get Drops Entitlements",
	"https://dev.twitch.tv/docs/api/reference/#get-drops-entitlements",
	"Gets an organization’s list of entitlements that have been granted to a game, a user, or both.",
	[

	]
);

static var feature_update_drops_entitlements: ScopedFeatureDefinition = ScopedFeatureDefinition.from(
	"update-drops-entitlements",
	"Update Drops Entitlements",
	"https://dev.twitch.tv/docs/api/reference/#update-drops-entitlements",
	"Updates the Drop entitlement’s fulfillment status.",
	[

	]
);

static var feature_category_entitlements: ScopedFeatureDefinitionCategory = ScopedFeatureDefinitionCategory.from(
	"Entitlements",
	[
		feature_get_drops_entitlements,
		feature_update_drops_entitlements
	]
);

#endregion Feature Category API Features

#region Feature Category API Features

static var feature_get_extension_configuration_segment: ScopedFeatureDefinition = ScopedFeatureDefinition.from(
	"get-extension-configuration-segment",
	"Get Extension Configuration Segment",
	"https://dev.twitch.tv/docs/api/reference/#get-extension-configuration-segment",
	"Gets the specified configuration segment from the specified extension.",
	[

	]
);

static var feature_set_extension_configuration_segment: ScopedFeatureDefinition = ScopedFeatureDefinition.from(
	"set-extension-configuration-segment",
	"Set Extension Configuration Segment",
	"https://dev.twitch.tv/docs/api/reference/#set-extension-configuration-segment",
	"Updates a configuration segment.",
	[

	]
);

static var feature_set_extension_required_configuration: ScopedFeatureDefinition = ScopedFeatureDefinition.from(
	"set-extension-required-configuration",
	"Set Extension Required Configuration",
	"https://dev.twitch.tv/docs/api/reference/#set-extension-required-configuration",
	"Updates the extension’s required_configuration string.",
	[

	]
);

static var feature_send_extension_pubsub_message: ScopedFeatureDefinition = ScopedFeatureDefinition.from(
	"send-extension-pubsub-message",
	"Send Extension PubSub Message",
	"https://dev.twitch.tv/docs/api/reference/#send-extension-pubsub-message",
	"Sends a message to one or more viewers.",
	[

	]
);

static var feature_get_extension_live_channels: ScopedFeatureDefinition = ScopedFeatureDefinition.from(
	"get-extension-live-channels",
	"Get Extension Live Channels",
	"https://dev.twitch.tv/docs/api/reference/#get-extension-live-channels",
	"Gets a list of broadcasters that are streaming live and have installed or activated the extension.",
	[

	]
);

static var feature_get_extension_secrets: ScopedFeatureDefinition = ScopedFeatureDefinition.from(
	"get-extension-secrets",
	"Get Extension Secrets",
	"https://dev.twitch.tv/docs/api/reference/#get-extension-secrets",
	"Gets an extension’s list of shared secrets.",
	[

	]
);

static var feature_create_extension_secret: ScopedFeatureDefinition = ScopedFeatureDefinition.from(
	"create-extension-secret",
	"Create Extension Secret",
	"https://dev.twitch.tv/docs/api/reference/#create-extension-secret",
	"Creates a shared secret used to sign and verify JWT tokens.",
	[

	]
);

static var feature_send_extension_chat_message: ScopedFeatureDefinition = ScopedFeatureDefinition.from(
	"send-extension-chat-message",
	"Send Extension Chat Message",
	"https://dev.twitch.tv/docs/api/reference/#send-extension-chat-message",
	"Sends a message to the specified broadcaster’s chat room.",
	[

	]
);

static var feature_get_extensions: ScopedFeatureDefinition = ScopedFeatureDefinition.from(
	"get-extensions",
	"Get Extensions",
	"https://dev.twitch.tv/docs/api/reference/#get-extensions",
	"Gets information about an extension.",
	[

	]
);

static var feature_get_released_extensions: ScopedFeatureDefinition = ScopedFeatureDefinition.from(
	"get-released-extensions",
	"Get Released Extensions",
	"https://dev.twitch.tv/docs/api/reference/#get-released-extensions",
	"Gets information about a released extension.",
	[

	]
);

static var feature_get_extension_bits_products: ScopedFeatureDefinition = ScopedFeatureDefinition.from(
	"get-extension-bits-products",
	"Get Extension Bits Products",
	"https://dev.twitch.tv/docs/api/reference/#get-extension-bits-products",
	"Gets the list of Bits products that belongs to the extension.",
	[

	]
);

static var feature_update_extension_bits_product: ScopedFeatureDefinition = ScopedFeatureDefinition.from(
	"update-extension-bits-product",
	"Update Extension Bits Product",
	"https://dev.twitch.tv/docs/api/reference/#update-extension-bits-product",
	"Adds or updates a Bits product that the extension created.",
	[

	]
);

static var feature_category_extensions: ScopedFeatureDefinitionCategory = ScopedFeatureDefinitionCategory.from(
	"Extensions",
	[
		feature_get_extension_configuration_segment,
		feature_set_extension_configuration_segment,
		feature_set_extension_required_configuration,
		feature_send_extension_pubsub_message,
		feature_get_extension_live_channels,
		feature_get_extension_secrets,
		feature_create_extension_secret,
		feature_send_extension_chat_message,
		feature_get_extensions,
		feature_get_released_extensions,
		feature_get_extension_bits_products,
		feature_update_extension_bits_product
	]
);

#endregion Feature Category API Features

#region Feature Category API Features

static var feature_create_eventsub_subscription: ScopedFeatureDefinition = ScopedFeatureDefinition.from(
	"create-eventsub-subscription",
	"Create EventSub Subscription",
	"https://dev.twitch.tv/docs/api/reference/#create-eventsub-subscription",
	"Creates an EventSub subscription.",
	[

	]
);

static var feature_delete_eventsub_subscription: ScopedFeatureDefinition = ScopedFeatureDefinition.from(
	"delete-eventsub-subscription",
	"Delete EventSub Subscription",
	"https://dev.twitch.tv/docs/api/reference/#delete-eventsub-subscription",
	"Deletes an EventSub subscription.",
	[

	]
);

static var feature_get_eventsub_subscriptions: ScopedFeatureDefinition = ScopedFeatureDefinition.from(
	"get-eventsub-subscriptions",
	"Get EventSub Subscriptions",
	"https://dev.twitch.tv/docs/api/reference/#get-eventsub-subscriptions",
	"Gets a list of EventSub subscriptions that the client in the access token created.",
	[

	]
);

static var feature_category_eventsub: ScopedFeatureDefinitionCategory = ScopedFeatureDefinitionCategory.from(
	"EventSub",
	[
		feature_create_eventsub_subscription,
		feature_delete_eventsub_subscription,
		feature_get_eventsub_subscriptions
	]
);

#endregion Feature Category API Features

#region Feature Category API Features

static var feature_get_top_games: ScopedFeatureDefinition = ScopedFeatureDefinition.from(
	"get-top-games",
	"Get Top Games",
	"https://dev.twitch.tv/docs/api/reference/#get-top-games",
	"Gets information about all broadcasts on Twitch.",
	[

	]
);

static var feature_get_games: ScopedFeatureDefinition = ScopedFeatureDefinition.from(
	"get-games",
	"Get Games",
	"https://dev.twitch.tv/docs/api/reference/#get-games",
	"Gets information about specified games.",
	[

	]
);

static var feature_category_games: ScopedFeatureDefinitionCategory = ScopedFeatureDefinitionCategory.from(
	"Games",
	[
		feature_get_top_games,
		feature_get_games
	]
);

#endregion Feature Category API Features

#region Feature Category API Features

static var feature_get_creator_goals: ScopedFeatureDefinition = ScopedFeatureDefinition.from(
	"get-creator-goals",
	"Get Creator Goals",
	"https://dev.twitch.tv/docs/api/reference/#get-creator-goals",
	"Gets the broadcaster’s list of active goals.",
	[
		"channel:read:goals"
	]
);

static var feature_category_goals: ScopedFeatureDefinitionCategory = ScopedFeatureDefinitionCategory.from(
	"Goals",
	[
		feature_get_creator_goals
	]
);

#endregion Feature Category API Features

#region Feature Category API Features

static var feature_get_channel_guest_star_settings: ScopedFeatureDefinition = ScopedFeatureDefinition.from(
	"get-channel-guest-star-settings",
	"Get Channel Guest Star Settings",
	"https://dev.twitch.tv/docs/api/reference/#get-channel-guest-star-settings",
	"BETA Gets the channel settings for configuration of the Guest Star feature for a particular host.",
	[
		"channel:read:guest_star",
		"moderator:read:guest_star"
	]
);

static var feature_update_channel_guest_star_settings: ScopedFeatureDefinition = ScopedFeatureDefinition.from(
	"update-channel-guest-star-settings",
	"Update Channel Guest Star Settings",
	"https://dev.twitch.tv/docs/api/reference/#update-channel-guest-star-settings",
	"BETA Mutates the channel settings for configuration of the Guest Star feature for a particular host.",
	[
		"channel:manage:guest_star"
	]
);

static var feature_get_guest_star_session: ScopedFeatureDefinition = ScopedFeatureDefinition.from(
	"get-guest-star-session",
	"Get Guest Star Session",
	"https://dev.twitch.tv/docs/api/reference/#get-guest-star-session",
	"BETA Gets information about an ongoing Guest Star session for a particular channel.",
	[
		"channel:read:guest_star",
		"moderator:read:guest_star"
	]
);

static var feature_create_guest_star_session: ScopedFeatureDefinition = ScopedFeatureDefinition.from(
	"create-guest-star-session",
	"Create Guest Star Session",
	"https://dev.twitch.tv/docs/api/reference/#create-guest-star-session",
	"BETA Programmatically creates a Guest Star session on behalf of the broadcaster.",
	[
		"channel:manage:guest_star"
	]
);

static var feature_end_guest_star_session: ScopedFeatureDefinition = ScopedFeatureDefinition.from(
	"end-guest-star-session",
	"End Guest Star Session",
	"https://dev.twitch.tv/docs/api/reference/#end-guest-star-session",
	"BETA Programmatically ends a Guest Star session on behalf of the broadcaster.",
	[
		"channel:manage:guest_star"
	]
);

static var feature_get_guest_star_invites: ScopedFeatureDefinition = ScopedFeatureDefinition.from(
	"get-guest-star-invites",
	"Get Guest Star Invites",
	"https://dev.twitch.tv/docs/api/reference/#get-guest-star-invites",
	"BETA Provides the caller with a list of pending invites to a Guest Star session.",
	[
		"channel:read:guest_star",
		"moderator:read:guest_star"
	]
);

static var feature_send_guest_star_invite: ScopedFeatureDefinition = ScopedFeatureDefinition.from(
	"send-guest-star-invite",
	"Send Guest Star Invite",
	"https://dev.twitch.tv/docs/api/reference/#send-guest-star-invite",
	"BETA Sends an invite to a specified guest on behalf of the broadcaster for a Guest Star session in progress.",
	[
		"channel:manage:guest_star",
		"moderator:manage:guest_star"
	]
);

static var feature_delete_guest_star_invite: ScopedFeatureDefinition = ScopedFeatureDefinition.from(
	"delete-guest-star-invite",
	"Delete Guest Star Invite",
	"https://dev.twitch.tv/docs/api/reference/#delete-guest-star-invite",
	"BETA Revokes a previously sent invite for a Guest Star session.",
	[
		"channel:manage:guest_star",
		"moderator:manage:guest_star"
	]
);

static var feature_assign_guest_star_slot: ScopedFeatureDefinition = ScopedFeatureDefinition.from(
	"assign-guest-star-slot",
	"Assign Guest Star Slot",
	"https://dev.twitch.tv/docs/api/reference/#assign-guest-star-slot",
	"BETA Allows a previously invited user to be assigned a slot within the active Guest Star session.",
	[
		"channel:manage:guest_star",
		"moderator:manage:guest_star"
	]
);

static var feature_update_guest_star_slot: ScopedFeatureDefinition = ScopedFeatureDefinition.from(
	"update-guest-star-slot",
	"Update Guest Star Slot",
	"https://dev.twitch.tv/docs/api/reference/#update-guest-star-slot",
	"BETA Allows a user to update the assigned slot for a particular user within the active Guest Star session.",
	[
		"channel:manage:guest_star",
		"moderator:manage:guest_star"
	]
);

static var feature_delete_guest_star_slot: ScopedFeatureDefinition = ScopedFeatureDefinition.from(
	"delete-guest-star-slot",
	"Delete Guest Star Slot",
	"https://dev.twitch.tv/docs/api/reference/#delete-guest-star-slot",
	"BETA Allows a caller to remove a slot assignment from a user participating in an active Guest Star session.",
	[
		"channel:manage:guest_star",
		"moderator:manage:guest_star"
	]
);

static var feature_update_guest_star_slot_settings: ScopedFeatureDefinition = ScopedFeatureDefinition.from(
	"update-guest-star-slot-settings",
	"Update Guest Star Slot Settings",
	"https://dev.twitch.tv/docs/api/reference/#update-guest-star-slot-settings",
	"BETA Allows a user to update slot settings for a particular guest within a Guest Star session.",
	[
		"channel:manage:guest_star",
		"moderator:manage:guest_star"
	]
);

static var feature_category_guest_star: ScopedFeatureDefinitionCategory = ScopedFeatureDefinitionCategory.from(
	"Guest Star",
	[
		feature_get_channel_guest_star_settings,
		feature_update_channel_guest_star_settings,
		feature_get_guest_star_session,
		feature_create_guest_star_session,
		feature_end_guest_star_session,
		feature_get_guest_star_invites,
		feature_send_guest_star_invite,
		feature_delete_guest_star_invite,
		feature_assign_guest_star_slot,
		feature_update_guest_star_slot,
		feature_delete_guest_star_slot,
		feature_update_guest_star_slot_settings
	]
);

#endregion Feature Category API Features

#region Feature Category API Features

static var feature_get_hype_train_events: ScopedFeatureDefinition = ScopedFeatureDefinition.from(
	"get-hype-train-events",
	"Get Hype Train Events",
	"https://dev.twitch.tv/docs/api/reference/#get-hype-train-events",
	"Gets information about the broadcaster’s current or most recent Hype Train event.",
	[
		"channel:read:hype_train"
	]
);

static var feature_category_hype_train: ScopedFeatureDefinitionCategory = ScopedFeatureDefinitionCategory.from(
	"Hype Train",
	[
		feature_get_hype_train_events
	]
);

#endregion Feature Category API Features

#region Feature Category API Features

static var feature_check_automod_status: ScopedFeatureDefinition = ScopedFeatureDefinition.from(
	"check-automod-status",
	"Check AutoMod Status",
	"https://dev.twitch.tv/docs/api/reference/#check-automod-status",
	"Checks whether AutoMod would flag the specified message for review.",
	[
		"moderation:read"
	]
);

static var feature_manage_held_automod_messages: ScopedFeatureDefinition = ScopedFeatureDefinition.from(
	"manage-held-automod-messages",
	"Manage Held AutoMod Messages",
	"https://dev.twitch.tv/docs/api/reference/#manage-held-automod-messages",
	"Allow or deny the message that AutoMod flagged for review.",
	[
		"moderator:manage:automod"
	]
);

static var feature_get_automod_settings: ScopedFeatureDefinition = ScopedFeatureDefinition.from(
	"get-automod-settings",
	"Get AutoMod Settings",
	"https://dev.twitch.tv/docs/api/reference/#get-automod-settings",
	"Gets the broadcaster’s AutoMod settings.",
	[
		"moderator:read:automod_settings"
	]
);

static var feature_update_automod_settings: ScopedFeatureDefinition = ScopedFeatureDefinition.from(
	"update-automod-settings",
	"Update AutoMod Settings",
	"https://dev.twitch.tv/docs/api/reference/#update-automod-settings",
	"Updates the broadcaster’s AutoMod settings.",
	[
		"moderator:manage:automod_settings"
	]
);

static var feature_get_banned_users: ScopedFeatureDefinition = ScopedFeatureDefinition.from(
	"get-banned-users",
	"Get Banned Users",
	"https://dev.twitch.tv/docs/api/reference/#get-banned-users",
	"Gets all users that the broadcaster banned or put in a timeout.",
	[
		"moderation:read",
		"moderator:manage:banned_users"
	]
);

static var feature_ban_user: ScopedFeatureDefinition = ScopedFeatureDefinition.from(
	"ban-user",
	"Ban User",
	"https://dev.twitch.tv/docs/api/reference/#ban-user",
	"Bans a user from participating in a broadcaster’s chat room or puts them in a timeout.",
	[
		"moderator:manage:banned_users"
	]
);

static var feature_unban_user: ScopedFeatureDefinition = ScopedFeatureDefinition.from(
	"unban-user",
	"Unban User",
	"https://dev.twitch.tv/docs/api/reference/#unban-user",
	"Removes the ban or timeout that was placed on the specified user.",
	[
		"moderator:manage:banned_users"
	]
);

static var feature_get_unban_requests: ScopedFeatureDefinition = ScopedFeatureDefinition.from(
	"get-unban-requests",
	"Get Unban Requests",
	"https://dev.twitch.tv/docs/api/reference/#get-unban-requests",
	"NEW Gets a list of unban requests for a broadcaster’s channel.",
	[
		"moderator:read:unban_requests"
	]
);

static var feature_resolve_unban_requests: ScopedFeatureDefinition = ScopedFeatureDefinition.from(
	"resolve-unban-requests",
	"Resolve Unban Requests",
	"https://dev.twitch.tv/docs/api/reference/#resolve-unban-requests",
	"NEW Resolves an unban request by approving or denying it.",
	[
		"moderator:manage:unban_requests"
	]
);

static var feature_get_blocked_terms: ScopedFeatureDefinition = ScopedFeatureDefinition.from(
	"get-blocked-terms",
	"Get Blocked Terms",
	"https://dev.twitch.tv/docs/api/reference/#get-blocked-terms",
	"Gets the broadcaster’s list of non-private, blocked words or phrases.",
	[
		"moderator:read:blocked_terms",
		"moderator:manage:blocked_terms"
	]
);

static var feature_add_blocked_term: ScopedFeatureDefinition = ScopedFeatureDefinition.from(
	"add-blocked-term",
	"Add Blocked Term",
	"https://dev.twitch.tv/docs/api/reference/#add-blocked-term",
	"Adds a word or phrase to the broadcaster’s list of blocked terms.",
	[
		"moderator:manage:blocked_terms"
	]
);

static var feature_remove_blocked_term: ScopedFeatureDefinition = ScopedFeatureDefinition.from(
	"remove-blocked-term",
	"Remove Blocked Term",
	"https://dev.twitch.tv/docs/api/reference/#remove-blocked-term",
	"Removes the word or phrase from the broadcaster’s list of blocked terms.",
	[
		"moderator:manage:blocked_terms"
	]
);

static var feature_delete_chat_messages: ScopedFeatureDefinition = ScopedFeatureDefinition.from(
	"delete-chat-messages",
	"Delete Chat Messages",
	"https://dev.twitch.tv/docs/api/reference/#delete-chat-messages",
	"Removes a single chat message or all chat messages from the broadcaster’s chat room.",
	[
		"moderator:manage:chat_messages"
	]
);

static var feature_get_moderated_channels: ScopedFeatureDefinition = ScopedFeatureDefinition.from(
	"get-moderated-channels",
	"Get Moderated Channels",
	"https://dev.twitch.tv/docs/api/reference/#get-moderated-channels",
	"Gets a list of channels that the specified user has moderator privileges in.",
	[
		"user:read:moderated_channels"
	]
);

static var feature_get_moderators: ScopedFeatureDefinition = ScopedFeatureDefinition.from(
	"get-moderators",
	"Get Moderators",
	"https://dev.twitch.tv/docs/api/reference/#get-moderators",
	"Gets all users allowed to moderate the broadcaster’s chat room.",
	[
		"channel:manage:moderators",
		"moderation:read"
	]
);

static var feature_add_channel_moderator: ScopedFeatureDefinition = ScopedFeatureDefinition.from(
	"add-channel-moderator",
	"Add Channel Moderator",
	"https://dev.twitch.tv/docs/api/reference/#add-channel-moderator",
	"Adds a moderator to the broadcaster’s chat room.",
	[
		"channel:manage:moderators"
	]
);

static var feature_remove_channel_moderator: ScopedFeatureDefinition = ScopedFeatureDefinition.from(
	"remove-channel-moderator",
	"Remove Channel Moderator",
	"https://dev.twitch.tv/docs/api/reference/#remove-channel-moderator",
	"Removes a moderator from the broadcaster’s chat room.",
	[
		"channel:manage:moderators"
	]
);

static var feature_get_vips: ScopedFeatureDefinition = ScopedFeatureDefinition.from(
	"get-vips",
	"Get VIPs",
	"https://dev.twitch.tv/docs/api/reference/#get-vips",
	"Gets a list of the broadcaster’s VIPs.",
	[
		"channel:read:vips",
		"channel:manage:vips"
	]
);

static var feature_add_channel_vip: ScopedFeatureDefinition = ScopedFeatureDefinition.from(
	"add-channel-vip",
	"Add Channel VIP",
	"https://dev.twitch.tv/docs/api/reference/#add-channel-vip",
	"Adds the specified user as a VIP in the broadcaster’s channel.",
	[
		"channel:manage:vips"
	]
);

static var feature_remove_channel_vip: ScopedFeatureDefinition = ScopedFeatureDefinition.from(
	"remove-channel-vip",
	"Remove Channel VIP",
	"https://dev.twitch.tv/docs/api/reference/#remove-channel-vip",
	"Removes the specified user as a VIP in the broadcaster’s channel.",
	[
		"channel:manage:vips"
	]
);

static var feature_update_shield_mode_status: ScopedFeatureDefinition = ScopedFeatureDefinition.from(
	"update-shield-mode-status",
	"Update Shield Mode Status",
	"https://dev.twitch.tv/docs/api/reference/#update-shield-mode-status",
	"Activates or deactivates the broadcaster’s Shield Mode.",
	[
		"moderator:manage:shield_mode"
	]
);

static var feature_get_shield_mode_status: ScopedFeatureDefinition = ScopedFeatureDefinition.from(
	"get-shield-mode-status",
	"Get Shield Mode Status",
	"https://dev.twitch.tv/docs/api/reference/#get-shield-mode-status",
	"Gets the broadcaster’s Shield Mode activation status.",
	[
		"moderator:read:shield_mode"
	]
);

static var feature_warn_chat_user: ScopedFeatureDefinition = ScopedFeatureDefinition.from(
	"warn-chat-user",
	"Warn Chat User",
	"https://dev.twitch.tv/docs/api/reference/#warn-chat-user",
	"NEW Warns a user in the specified broadcaster’s chat room, preventing them from chat interaction until the warning is acknowledged.",
	[
		"moderator:manage:warnings"
	]
);

static var feature_category_moderation: ScopedFeatureDefinitionCategory = ScopedFeatureDefinitionCategory.from(
	"Moderation",
	[
		feature_check_automod_status,
		feature_manage_held_automod_messages,
		feature_get_automod_settings,
		feature_update_automod_settings,
		feature_get_banned_users,
		feature_ban_user,
		feature_unban_user,
		feature_get_unban_requests,
		feature_resolve_unban_requests,
		feature_get_blocked_terms,
		feature_add_blocked_term,
		feature_remove_blocked_term,
		feature_delete_chat_messages,
		feature_get_moderated_channels,
		feature_get_moderators,
		feature_add_channel_moderator,
		feature_remove_channel_moderator,
		feature_get_vips,
		feature_add_channel_vip,
		feature_remove_channel_vip,
		feature_update_shield_mode_status,
		feature_get_shield_mode_status,
		feature_warn_chat_user
	]
);

#endregion Feature Category API Features

#region Feature Category API Features

static var feature_get_polls: ScopedFeatureDefinition = ScopedFeatureDefinition.from(
	"get-polls",
	"Get Polls",
	"https://dev.twitch.tv/docs/api/reference/#get-polls",
	"Gets a list of polls that the broadcaster created.",
	[
		"channel:read:polls",
		"channel:manage:polls"
	]
);

static var feature_create_poll: ScopedFeatureDefinition = ScopedFeatureDefinition.from(
	"create-poll",
	"Create Poll",
	"https://dev.twitch.tv/docs/api/reference/#create-poll",
	"Creates a poll that viewers in the broadcaster’s channel can vote on.",
	[
		"channel:manage:polls"
	]
);

static var feature_end_poll: ScopedFeatureDefinition = ScopedFeatureDefinition.from(
	"end-poll",
	"End Poll",
	"https://dev.twitch.tv/docs/api/reference/#end-poll",
	"End an active poll.",
	[
		"channel:manage:polls"
	]
);

static var feature_category_polls: ScopedFeatureDefinitionCategory = ScopedFeatureDefinitionCategory.from(
	"Polls",
	[
		feature_get_polls,
		feature_create_poll,
		feature_end_poll
	]
);

#endregion Feature Category API Features

#region Feature Category API Features

static var feature_get_predictions: ScopedFeatureDefinition = ScopedFeatureDefinition.from(
	"get-predictions",
	"Get Predictions",
	"https://dev.twitch.tv/docs/api/reference/#get-predictions",
	"Gets a list of Channel Points Predictions that the broadcaster created.",
	[
		"channel:read:predictions",
		"channel:manage:predictions"
	]
);

static var feature_create_prediction: ScopedFeatureDefinition = ScopedFeatureDefinition.from(
	"create-prediction",
	"Create Prediction",
	"https://dev.twitch.tv/docs/api/reference/#create-prediction",
	"Create a Channel Points Prediction.",
	[
		"channel:manage:predictions"
	]
);

static var feature_end_prediction: ScopedFeatureDefinition = ScopedFeatureDefinition.from(
	"end-prediction",
	"End Prediction",
	"https://dev.twitch.tv/docs/api/reference/#end-prediction",
	"Locks, resolves, or cancels a Channel Points Prediction.",
	[
		"channel:manage:predictions"
	]
);

static var feature_category_predictions: ScopedFeatureDefinitionCategory = ScopedFeatureDefinitionCategory.from(
	"Predictions",
	[
		feature_get_predictions,
		feature_create_prediction,
		feature_end_prediction
	]
);

#endregion Feature Category API Features

#region Feature Category API Features

static var feature_start_a_raid: ScopedFeatureDefinition = ScopedFeatureDefinition.from(
	"start-a-raid",
	"Start a raid",
	"https://dev.twitch.tv/docs/api/reference/#start-a-raid",
	"Raid another channel by sending the broadcaster’s viewers to the targeted channel.",
	[
		"channel:manage:raids"
	]
);

static var feature_cancel_a_raid: ScopedFeatureDefinition = ScopedFeatureDefinition.from(
	"cancel-a-raid",
	"Cancel a raid",
	"https://dev.twitch.tv/docs/api/reference/#cancel-a-raid",
	"Cancel a pending raid.",
	[
		"channel:manage:raids"
	]
);

static var feature_category_raids: ScopedFeatureDefinitionCategory = ScopedFeatureDefinitionCategory.from(
	"Raids",
	[
		feature_start_a_raid,
		feature_cancel_a_raid
	]
);

#endregion Feature Category API Features

#region Feature Category API Features

static var feature_get_channel_stream_schedule: ScopedFeatureDefinition = ScopedFeatureDefinition.from(
	"get-channel-stream-schedule",
	"Get Channel Stream Schedule",
	"https://dev.twitch.tv/docs/api/reference/#get-channel-stream-schedule",
	"Gets the broadcaster’s streaming schedule.",
	[

	]
);

static var feature_get_channel_icalendar: ScopedFeatureDefinition = ScopedFeatureDefinition.from(
	"get-channel-icalendar",
	"Get Channel iCalendar",
	"https://dev.twitch.tv/docs/api/reference/#get-channel-icalendar",
	"Gets the broadcaster’s streaming schedule as an iCalendar.",
	[

	]
);

static var feature_update_channel_stream_schedule: ScopedFeatureDefinition = ScopedFeatureDefinition.from(
	"update-channel-stream-schedule",
	"Update Channel Stream Schedule",
	"https://dev.twitch.tv/docs/api/reference/#update-channel-stream-schedule",
	"Updates the broadcaster’s schedule settings, such as scheduling a vacation.",
	[
		"channel:manage:schedule"
	]
);

static var feature_create_channel_stream_schedule_segment: ScopedFeatureDefinition = ScopedFeatureDefinition.from(
	"create-channel-stream-schedule-segment",
	"Create Channel Stream Schedule Segment",
	"https://dev.twitch.tv/docs/api/reference/#create-channel-stream-schedule-segment",
	"Adds a single or recurring broadcast to the broadcaster’s streaming schedule.",
	[
		"channel:manage:schedule"
	]
);

static var feature_update_channel_stream_schedule_segment: ScopedFeatureDefinition = ScopedFeatureDefinition.from(
	"update-channel-stream-schedule-segment",
	"Update Channel Stream Schedule Segment",
	"https://dev.twitch.tv/docs/api/reference/#update-channel-stream-schedule-segment",
	"Updates a scheduled broadcast segment.",
	[
		"channel:manage:schedule"
	]
);

static var feature_delete_channel_stream_schedule_segment: ScopedFeatureDefinition = ScopedFeatureDefinition.from(
	"delete-channel-stream-schedule-segment",
	"Delete Channel Stream Schedule Segment",
	"https://dev.twitch.tv/docs/api/reference/#delete-channel-stream-schedule-segment",
	"Deletes a broadcast from the broadcaster’s streaming schedule.",
	[
		"channel:manage:schedule"
	]
);

static var feature_category_schedule: ScopedFeatureDefinitionCategory = ScopedFeatureDefinitionCategory.from(
	"Schedule",
	[
		feature_get_channel_stream_schedule,
		feature_get_channel_icalendar,
		feature_update_channel_stream_schedule,
		feature_create_channel_stream_schedule_segment,
		feature_update_channel_stream_schedule_segment,
		feature_delete_channel_stream_schedule_segment
	]
);

#endregion Feature Category API Features

#region Feature Category API Features

static var feature_search_categories: ScopedFeatureDefinition = ScopedFeatureDefinition.from(
	"search-categories",
	"Search Categories",
	"https://dev.twitch.tv/docs/api/reference/#search-categories",
	"Gets the games or categories that match the specified query.",
	[

	]
);

static var feature_search_channels: ScopedFeatureDefinition = ScopedFeatureDefinition.from(
	"search-channels",
	"Search Channels",
	"https://dev.twitch.tv/docs/api/reference/#search-channels",
	"Gets the channels that match the specified query and have streamed content within the past 6 months.",
	[

	]
);

static var feature_category_search: ScopedFeatureDefinitionCategory = ScopedFeatureDefinitionCategory.from(
	"Search",
	[
		feature_search_categories,
		feature_search_channels
	]
);

#endregion Feature Category API Features

#region Feature Category API Features

static var feature_get_stream_key: ScopedFeatureDefinition = ScopedFeatureDefinition.from(
	"get-stream-key",
	"Get Stream Key",
	"https://dev.twitch.tv/docs/api/reference/#get-stream-key",
	"Gets the channel’s stream key.",
	[
		"channel:read:stream_key"
	]
);

static var feature_get_streams: ScopedFeatureDefinition = ScopedFeatureDefinition.from(
	"get-streams",
	"Get Streams",
	"https://dev.twitch.tv/docs/api/reference/#get-streams",
	"Gets a list of all streams.",
	[

	]
);

static var feature_get_followed_streams: ScopedFeatureDefinition = ScopedFeatureDefinition.from(
	"get-followed-streams",
	"Get Followed Streams",
	"https://dev.twitch.tv/docs/api/reference/#get-followed-streams",
	"Gets the list of broadcasters that the user follows and that are streaming live.",
	[
		"user:read:follows"
	]
);

static var feature_create_stream_marker: ScopedFeatureDefinition = ScopedFeatureDefinition.from(
	"create-stream-marker",
	"Create Stream Marker",
	"https://dev.twitch.tv/docs/api/reference/#create-stream-marker",
	"Adds a marker to a live stream.",
	[
		"channel:manage:broadcast"
	]
);

static var feature_get_stream_markers: ScopedFeatureDefinition = ScopedFeatureDefinition.from(
	"get-stream-markers",
	"Get Stream Markers",
	"https://dev.twitch.tv/docs/api/reference/#get-stream-markers",
	"Gets a list of markers from the user’s most recent stream or from the specified VOD/video.",
	[
		"user:read:broadcast"
	]
);

static var feature_category_streams: ScopedFeatureDefinitionCategory = ScopedFeatureDefinitionCategory.from(
	"Streams",
	[
		feature_get_stream_key,
		feature_get_streams,
		feature_get_followed_streams,
		feature_create_stream_marker,
		feature_get_stream_markers
	]
);

#endregion Feature Category API Features

#region Feature Category API Features

static var feature_get_broadcaster_subscriptions: ScopedFeatureDefinition = ScopedFeatureDefinition.from(
	"get-broadcaster-subscriptions",
	"Get Broadcaster Subscriptions",
	"https://dev.twitch.tv/docs/api/reference/#get-broadcaster-subscriptions",
	"Gets a list of users that subscribe to the specified broadcaster.",
	[
		"channel:read:subscriptions"
	]
);

static var feature_check_user_subscription: ScopedFeatureDefinition = ScopedFeatureDefinition.from(
	"check-user-subscription",
	"Check User Subscription",
	"https://dev.twitch.tv/docs/api/reference/#check-user-subscription",
	"Checks whether the user subscribes to the broadcaster’s channel.",
	[
		"user:read:subscriptions"
	]
);

static var feature_category_subscriptions: ScopedFeatureDefinitionCategory = ScopedFeatureDefinitionCategory.from(
	"Subscriptions",
	[
		feature_get_broadcaster_subscriptions,
		feature_check_user_subscription
	]
);

#endregion Feature Category API Features

#region Feature Category API Features

static var feature_get_all_stream_tags: ScopedFeatureDefinition = ScopedFeatureDefinition.from(
	"get-all-stream-tags",
	"Get All Stream Tags",
	"https://dev.twitch.tv/docs/api/reference/#get-all-stream-tags",
	"Gets the list of all stream tags that Twitch defines. You can also filter the list by one or more tag IDs.",
	[

	]
);

static var feature_get_stream_tags: ScopedFeatureDefinition = ScopedFeatureDefinition.from(
	"get-stream-tags",
	"Get Stream Tags",
	"https://dev.twitch.tv/docs/api/reference/#get-stream-tags",
	"Gets the list of stream tags that the broadcaster or Twitch added to their channel.",
	[

	]
);

static var feature_category_tags: ScopedFeatureDefinitionCategory = ScopedFeatureDefinitionCategory.from(
	"Tags",
	[
		feature_get_all_stream_tags,
		feature_get_stream_tags
	]
);

#endregion Feature Category API Features

#region Feature Category API Features

static var feature_get_channel_teams: ScopedFeatureDefinition = ScopedFeatureDefinition.from(
	"get-channel-teams",
	"Get Channel Teams",
	"https://dev.twitch.tv/docs/api/reference/#get-channel-teams",
	"Gets the list of Twitch teams that the broadcaster is a member of.",
	[

	]
);

static var feature_get_teams: ScopedFeatureDefinition = ScopedFeatureDefinition.from(
	"get-teams",
	"Get Teams",
	"https://dev.twitch.tv/docs/api/reference/#get-teams",
	"Gets information about the specified Twitch team.",
	[

	]
);

static var feature_category_teams: ScopedFeatureDefinitionCategory = ScopedFeatureDefinitionCategory.from(
	"Teams",
	[
		feature_get_channel_teams,
		feature_get_teams
	]
);

#endregion Feature Category API Features

#region Feature Category API Features

static var feature_get_users: ScopedFeatureDefinition = ScopedFeatureDefinition.from(
	"get-users",
	"Get Users",
	"https://dev.twitch.tv/docs/api/reference/#get-users",
	"Gets information about one or more users.",
	[
		"user:read:email"
	]
);

static var feature_update_user: ScopedFeatureDefinition = ScopedFeatureDefinition.from(
	"update-user",
	"Update User",
	"https://dev.twitch.tv/docs/api/reference/#update-user",
	"Updates the user’s information.",
	[
		"user:edit",
		"user:read:email"
	]
);

static var feature_get_user_block_list: ScopedFeatureDefinition = ScopedFeatureDefinition.from(
	"get-user-block-list",
	"Get User Block List",
	"https://dev.twitch.tv/docs/api/reference/#get-user-block-list",
	"Gets the list of users that the broadcaster has blocked.",
	[
		"user:read:blocked_users"
	]
);

static var feature_block_user: ScopedFeatureDefinition = ScopedFeatureDefinition.from(
	"block-user",
	"Block User",
	"https://dev.twitch.tv/docs/api/reference/#block-user",
	"Blocks the specified user from interacting with or having contact with the broadcaster.",
	[
		"user:manage:blocked_users"
	]
);

static var feature_unblock_user: ScopedFeatureDefinition = ScopedFeatureDefinition.from(
	"unblock-user",
	"Unblock User",
	"https://dev.twitch.tv/docs/api/reference/#unblock-user",
	"Removes the user from the broadcaster’s list of blocked users.",
	[
		"user:manage:blocked_users"
	]
);

static var feature_get_user_extensions: ScopedFeatureDefinition = ScopedFeatureDefinition.from(
	"get-user-extensions",
	"Get User Extensions",
	"https://dev.twitch.tv/docs/api/reference/#get-user-extensions",
	"Gets a list of all extensions (both active and inactive) that the broadcaster has installed.",
	[
		"user:edit:broadcast",
		"user:read:broadcast"
	]
);

static var feature_get_user_active_extensions: ScopedFeatureDefinition = ScopedFeatureDefinition.from(
	"get-user-active-extensions",
	"Get User Active Extensions",
	"https://dev.twitch.tv/docs/api/reference/#get-user-active-extensions",
	"Gets the active extensions that the broadcaster has installed for each configuration.",
	[
		"channel:manage:extensions",
		"user:edit:broadcast",
		"user:read:broadcast"
	]
);

static var feature_update_user_extensions: ScopedFeatureDefinition = ScopedFeatureDefinition.from(
	"update-user-extensions",
	"Update User Extensions",
	"https://dev.twitch.tv/docs/api/reference/#update-user-extensions",
	"Updates an installed extension’s information.",
	[
		"channel:manage:extensions",
		"user:edit:broadcast"
	]
);

static var feature_category_users: ScopedFeatureDefinitionCategory = ScopedFeatureDefinitionCategory.from(
	"Users",
	[
		feature_get_users,
		feature_update_user,
		feature_get_user_block_list,
		feature_block_user,
		feature_unblock_user,
		feature_get_user_extensions,
		feature_get_user_active_extensions,
		feature_update_user_extensions
	]
);

#endregion Feature Category API Features

#region Feature Category API Features

static var feature_get_videos: ScopedFeatureDefinition = ScopedFeatureDefinition.from(
	"get-videos",
	"Get Videos",
	"https://dev.twitch.tv/docs/api/reference/#get-videos",
	"Gets information about one or more published videos.",
	[

	]
);

static var feature_delete_videos: ScopedFeatureDefinition = ScopedFeatureDefinition.from(
	"delete-videos",
	"Delete Videos",
	"https://dev.twitch.tv/docs/api/reference/#delete-videos",
	"Deletes one or more videos.",
	[
		"channel:manage:videos"
	]
);

static var feature_category_videos: ScopedFeatureDefinitionCategory = ScopedFeatureDefinitionCategory.from(
	"Videos",
	[
		feature_get_videos,
		feature_delete_videos
	]
);

#endregion Feature Category API Features

#region Feature Category API Features

static var feature_send_whisper: ScopedFeatureDefinition = ScopedFeatureDefinition.from(
	"send-whisper",
	"Send Whisper",
	"https://dev.twitch.tv/docs/api/reference/#send-whisper",
	"Sends a whisper message to the specified user.",
	[
		"user:manage:whispers"
	]
);

static var feature_category_whispers: ScopedFeatureDefinitionCategory = ScopedFeatureDefinitionCategory.from(
	"Whispers",
	[
		feature_send_whisper
	]
);

#endregion Feature Category API Features

static var feature_set_api: ScopedFeatureSet = ScopedFeatureSet.from(
	"api",
	"API Features",
	[
		feature_category_ads,
		feature_category_analytics,
		feature_category_bits,
		feature_category_channels,
		feature_category_channel_points,
		feature_category_charity,
		feature_category_chat,
		feature_category_clips,
		feature_category_conduits,
		feature_category_ccls,
		feature_category_entitlements,
		feature_category_extensions,
		feature_category_eventsub,
		feature_category_games,
		feature_category_goals,
		feature_category_guest_star,
		feature_category_hype_train,
		feature_category_moderation,
		feature_category_polls,
		feature_category_predictions,
		feature_category_raids,
		feature_category_schedule,
		feature_category_search,
		feature_category_streams,
		feature_category_subscriptions,
		feature_category_tags,
		feature_category_teams,
		feature_category_users,
		feature_category_videos,
		feature_category_whispers
	]
);

#endregion Feature Set API Features

#region Feature Set EventSub Features

#region Feature Category EventSub Features

static var feature_automod_message_hold: ScopedFeatureDefinition = ScopedFeatureDefinition.from(
	"automod.message.hold",
	"Automod Message Hold",
	"https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/#automodmessagehold",
	"A user is notified if a message is caught by automod for review.",
	[
		"moderator:manage:automod"
	]
);

static var feature_automod_message_update: ScopedFeatureDefinition = ScopedFeatureDefinition.from(
	"automod.message.update",
	"Automod Message Update",
	"https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/#automodmessageupdate",
	"A message in the automod queue had its status changed.",
	[
		"moderator:manage:automod"
	]
);

static var feature_automod_settings_update: ScopedFeatureDefinition = ScopedFeatureDefinition.from(
	"automod.settings.update",
	"Automod Settings Update",
	"https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/#automodsettingsupdate",
	"A notification is sent when a broadcaster’s automod settings are updated.",
	[
		"moderator:read:automod_settings"
	]
);

static var feature_automod_terms_update: ScopedFeatureDefinition = ScopedFeatureDefinition.from(
	"automod.terms.update",
	"Automod Terms Update",
	"https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/#automodtermsupdate",
	"A notification is sent when a broadcaster’s automod terms are updated. Changes to private terms are not sent.",
	[

	]
);

static var feature_category_automod: ScopedFeatureDefinitionCategory = ScopedFeatureDefinitionCategory.from(
	"Automod",
	[
		feature_automod_message_hold,
		feature_automod_message_update,
		feature_automod_settings_update,
		feature_automod_terms_update
	]
);

#endregion Feature Category EventSub Features

#region Feature Category EventSub Features

static var feature_channel_update: ScopedFeatureDefinition = ScopedFeatureDefinition.from(
	"channel.update",
	"Channel Update",
	"https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/#channelupdate",
	"A broadcaster updates their channel properties e.g., category, title, content classification labels, broadcast, or language.",
	[

	]
);

static var feature_channel_follow: ScopedFeatureDefinition = ScopedFeatureDefinition.from(
	"channel.follow",
	"Channel Follow",
	"https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/#channelfollow",
	"A specified channel receives a follow.",
	[
		"moderator:read:followers"
	]
);

static var feature_channel_ad_break_begin: ScopedFeatureDefinition = ScopedFeatureDefinition.from(
	"channel.ad_break.begin",
	"Channel Ad Break Begin",
	"https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/#channelad_breakbegin",
	"A midroll commercial break has started running.",
	[
		"channel:read:ads"
	]
);

static var feature_channel_chat_clear: ScopedFeatureDefinition = ScopedFeatureDefinition.from(
	"channel.chat.clear",
	"Channel Chat Clear",
	"https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/#channelchatclear",
	"A moderator or bot has cleared all messages from the chat room.",
	[
		"channel:bot",
		"user:bot",
		"user:read:chat"
	]
);

static var feature_channel_chat_clear_user_messages: ScopedFeatureDefinition = ScopedFeatureDefinition.from(
	"channel.chat.clear_user_messages",
	"Channel Chat Clear User Messages",
	"https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/#channelchatclear_user_messages",
	"A moderator or bot has cleared all messages from a specific user.",
	[
		"channel:bot",
		"user:bot",
		"user:read:chat"
	]
);

static var feature_channel_chat_message: ScopedFeatureDefinition = ScopedFeatureDefinition.from(
	"channel.chat.message",
	"Channel Chat Message",
	"https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/#channelchatmessage",
	"Any user sends a message to a specific chat room.",
	[
		"channel:bot",
		"user:bot",
		"user:read:chat"
	]
);

static var feature_channel_chat_message_delete: ScopedFeatureDefinition = ScopedFeatureDefinition.from(
	"channel.chat.message_delete",
	"Channel Chat Message Delete",
	"https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/#channelchatmessage_delete",
	"A moderator has removed a specific message.",
	[
		"channel:bot",
		"user:bot",
		"user:read:chat"
	]
);

static var feature_channel_chat_notification: ScopedFeatureDefinition = ScopedFeatureDefinition.from(
	"channel.chat.notification",
	"Channel Chat Notification",
	"https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/#channelchatnotification",
	"A notification for when an event that appears in chat has occurred.",
	[
		"channel:bot",
		"user:bot",
		"user:read:chat"
	]
);

static var feature_channel_chat_settings_update: ScopedFeatureDefinition = ScopedFeatureDefinition.from(
	"channel.chat_settings.update",
	"Channel Chat Settings Update",
	"https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/#channelchat_settingsupdate",
	"A notification for when a broadcaster’s chat settings are updated.",
	[
		"channel:bot",
		"user:bot",
		"user:read:chat"
	]
);

static var feature_channel_chat_user_message_hold: ScopedFeatureDefinition = ScopedFeatureDefinition.from(
	"channel.chat.user_message_hold",
	"Channel Chat User Message Hold",
	"https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/#channelchatuser_message_hold",
	"A user is notified if their message is caught by automod.",
	[
		"user:read:chat"
	]
);

static var feature_channel_chat_user_message_update: ScopedFeatureDefinition = ScopedFeatureDefinition.from(
	"channel.chat.user_message_update",
	"Channel Chat User Message Update",
	"https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/#channelchatuser_message_update",
	"A user is notified if their message’s automod status is updated.",
	[
		"user:bot",
		"user:read:chat"
	]
);

static var feature_channel_shared_chat_session_begin: ScopedFeatureDefinition = ScopedFeatureDefinition.from(
	"channel.shared_chat.begin",
	"Channel Shared Chat Session Begin",
	"https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/#channelshared_chatbegin",
	"A notification when a channel becomes active in an active shared chat session.",
	[

	]
);

static var feature_channel_shared_chat_session_update: ScopedFeatureDefinition = ScopedFeatureDefinition.from(
	"channel.shared_chat.update",
	"Channel Shared Chat Session Update",
	"https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/#channelshared_chatupdate",
	"A notification when the active shared chat session the channel is in changes.",
	[

	]
);

static var feature_channel_shared_chat_session_end: ScopedFeatureDefinition = ScopedFeatureDefinition.from(
	"channel.shared_chat.end",
	"Channel Shared Chat Session End",
	"https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/#channelshared_chatend",
	"A notification when a channel leaves a shared chat session or the session ends.",
	[

	]
);

static var feature_channel_subscribe: ScopedFeatureDefinition = ScopedFeatureDefinition.from(
	"channel.subscribe",
	"Channel Subscribe",
	"https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/#channelsubscribe",
	"A notification is sent when a specified channel receives a subscriber. This does not include resubscribes.",
	[
		"channel:read:subscriptions"
	]
);

static var feature_channel_subscription_end: ScopedFeatureDefinition = ScopedFeatureDefinition.from(
	"channel.subscription.end",
	"Channel Subscription End",
	"https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/#channelsubscriptionend",
	"A notification when a subscription to the specified channel ends.",
	[
		"channel:read:subscriptions"
	]
);

static var feature_channel_subscription_gift: ScopedFeatureDefinition = ScopedFeatureDefinition.from(
	"channel.subscription.gift",
	"Channel Subscription Gift",
	"https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/#channelsubscriptiongift",
	"A notification when a viewer gives a gift subscription to one or more users in the specified channel.",
	[
		"channel:read:subscriptions"
	]
);

static var feature_channel_subscription_message: ScopedFeatureDefinition = ScopedFeatureDefinition.from(
	"channel.subscription.message",
	"Channel Subscription Message",
	"https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/#channelsubscriptionmessage",
	"A notification when a user sends a resubscription chat message in a specific channel.",
	[
		"channel:read:subscriptions"
	]
);

static var feature_channel_cheer: ScopedFeatureDefinition = ScopedFeatureDefinition.from(
	"channel.cheer",
	"Channel Cheer",
	"https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/#channelcheer",
	"A user cheers on the specified channel.",
	[
		"bits:read"
	]
);

static var feature_channel_raid: ScopedFeatureDefinition = ScopedFeatureDefinition.from(
	"channel.raid",
	"Channel Raid",
	"https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/#channelraid",
	"A broadcaster raids another broadcaster’s channel.",
	[

	]
);

static var feature_channel_ban: ScopedFeatureDefinition = ScopedFeatureDefinition.from(
	"channel.ban",
	"Channel Ban",
	"https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/#channelban",
	"A viewer is banned from the specified channel.",
	[

	]
);

static var feature_channel_unban: ScopedFeatureDefinition = ScopedFeatureDefinition.from(
	"channel.unban",
	"Channel Unban",
	"https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/#channelunban",
	"A viewer is unbanned from the specified channel.",
	[

	]
);

static var feature_channel_unban_request_create: ScopedFeatureDefinition = ScopedFeatureDefinition.from(
	"channel.unban_request.create",
	"Channel Unban Request Create",
	"https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/#channelunban_requestcreate",
	"A user creates an unban request.",
	[
		"moderator:read:unban_requests",
		"moderator:manage:unban_requests"
	]
);

static var feature_channel_unban_request_resolve: ScopedFeatureDefinition = ScopedFeatureDefinition.from(
	"channel.unban_request.resolve",
	"Channel Unban Request Resolve",
	"https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/#channelunban_requestresolve",
	"An unban request has been resolved.",
	[
		"moderator:read:unban_requests",
		"moderator:manage:unban_requests"
	]
);

static var feature_channel_moderate: ScopedFeatureDefinition = ScopedFeatureDefinition.from(
	"channel.moderate",
	"Channel Moderate",
	"https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/#channelmoderate",
	"A moderator performs a moderation action in a channel.",
	[
		"moderator:read:banned_users",
		"moderator:manage:banned_users",
		"moderator:read:blocked_terms",
		"moderator:read:chat_messages",
		"moderator:manage:blocked_terms",
		"moderator:manage:chat_messages",
		"moderator:read:chat_settings",
		"moderator:manage:chat_settings",
		"moderator:read:moderators",
		"moderator:read:unban_requests",
		"moderator:manage:unban_requests",
		"moderator:read:vips"
	]
);

static var feature_channel_moderate_v2: ScopedFeatureDefinition = ScopedFeatureDefinition.from(
	"channel.moderate",
	"Channel Moderate V2",
	"https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/#channelmoderate-v2",
	"A moderator performs a moderation action in a channel. Includes warnings.",
	[
		"moderator:read:banned_users",
		"moderator:manage:banned_users",
		"moderator:read:moderators",
		"moderator:read:vips",
		"moderator:read:warnings",
		"moderator:manage:warnings"
	]
);

static var feature_channel_moderator_add: ScopedFeatureDefinition = ScopedFeatureDefinition.from(
	"channel.moderator.add",
	"Channel Moderator Add",
	"https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/#channelmoderatoradd",
	"Moderator privileges were added to a user on a specified channel.",
	[
		"moderation:read"
	]
);

static var feature_channel_moderator_remove: ScopedFeatureDefinition = ScopedFeatureDefinition.from(
	"channel.moderator.remove",
	"Channel Moderator Remove",
	"https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/#channelmoderatorremove",
	"Moderator privileges were removed from a user on a specified channel.",
	[
		"moderation:read"
	]
);

static var feature_channel_guest_star_session_begin: ScopedFeatureDefinition = ScopedFeatureDefinition.from(
	"channel.guest_star_session.begin",
	"Channel Guest Star Session Begin",
	"https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/#channelguest_star_sessionbegin",
	"The host began a new Guest Star session.",
	[
		"channel:read:guest_star",
		"channel:manage:guest_star",
		"moderator:read:guest_star",
		"moderator:manage:guest_star"
	]
);

static var feature_channel_guest_star_session_end: ScopedFeatureDefinition = ScopedFeatureDefinition.from(
	"channel.guest_star_session.end",
	"Channel Guest Star Session End",
	"https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/#channelguest_star_sessionend",
	"A running Guest Star session has ended.",
	[
		"channel:read:guest_star",
		"channel:manage:guest_star",
		"moderator:read:guest_star",
		"moderator:manage:guest_star"
	]
);

static var feature_channel_guest_star_guest_update: ScopedFeatureDefinition = ScopedFeatureDefinition.from(
	"channel.guest_star_guest.update",
	"Channel Guest Star Guest Update",
	"https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/#channelguest_star_guestupdate",
	"A guest or a slot is updated in an active Guest Star session.",
	[
		"channel:read:guest_star",
		"channel:manage:guest_star",
		"moderator:read:guest_star",
		"moderator:manage:guest_star"
	]
);

static var feature_channel_guest_star_settings_update: ScopedFeatureDefinition = ScopedFeatureDefinition.from(
	"channel.guest_star_settings.update",
	"Channel Guest Star Settings Update",
	"https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/#channelguest_star_settingsupdate",
	"The host preferences for Guest Star have been updated.",
	[
		"channel:read:guest_star",
		"channel:manage:guest_star",
		"moderator:read:guest_star",
		"moderator:manage:guest_star"
	]
);

static var feature_channel_points_automatic_reward_redemption: ScopedFeatureDefinition = ScopedFeatureDefinition.from(
	"channel.channel_points_automatic_reward_redemption.add",
	"Channel Points Automatic Reward Redemption",
	"https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/#channelchannel_points_automatic_reward_redemptionadd",
	"A viewer has redeemed an automatic channel points reward on the specified channel.",
	[
		"channel:read:redemptions",
		"channel:manage:redemptions"
	]
);

static var feature_channel_points_custom_reward_add: ScopedFeatureDefinition = ScopedFeatureDefinition.from(
	"channel.channel_points_custom_reward.add",
	"Channel Points Custom Reward Add",
	"https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/#channelchannel_points_custom_rewardadd",
	"A custom channel points reward has been created for the specified channel.",
	[
		"channel:read:redemptions",
		"channel:manage:redemptions"
	]
);

static var feature_channel_points_custom_reward_update: ScopedFeatureDefinition = ScopedFeatureDefinition.from(
	"channel.channel_points_custom_reward.update",
	"Channel Points Custom Reward Update",
	"https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/#channelchannel_points_custom_rewardupdate",
	"A custom channel points reward has been updated for the specified channel.",
	[
		"channel:read:redemptions",
		"channel:manage:redemptions"
	]
);

static var feature_channel_points_custom_reward_remove: ScopedFeatureDefinition = ScopedFeatureDefinition.from(
	"channel.channel_points_custom_reward.remove",
	"Channel Points Custom Reward Remove",
	"https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/#channelchannel_points_custom_rewardremove",
	"A custom channel points reward has been removed from the specified channel.",
	[
		"channel:read:redemptions",
		"channel:manage:redemptions"
	]
);

static var feature_channel_points_custom_reward_redemption_add: ScopedFeatureDefinition = ScopedFeatureDefinition.from(
	"channel.channel_points_custom_reward_redemption.add",
	"Channel Points Custom Reward Redemption Add",
	"https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/#channelchannel_points_custom_reward_redemptionadd",
	"A viewer has redeemed a custom channel points reward on the specified channel.",
	[
		"channel:read:redemptions",
		"channel:manage:redemptions"
	]
);

static var feature_channel_points_custom_reward_redemption_update: ScopedFeatureDefinition = ScopedFeatureDefinition.from(
	"channel.channel_points_custom_reward_redemption.update",
	"Channel Points Custom Reward Redemption Update",
	"https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/#channelchannel_points_custom_reward_redemptionupdate",
	"A redemption of a channel points custom reward has been updated for the specified channel.",
	[
		"channel:read:redemptions",
		"channel:manage:redemptions"
	]
);

static var feature_channel_poll_begin: ScopedFeatureDefinition = ScopedFeatureDefinition.from(
	"channel.poll.begin",
	"Channel Poll Begin",
	"https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/#channelpollbegin",
	"A poll started on a specified channel.",
	[
		"channel:read:polls",
		"channel:manage:polls"
	]
);

static var feature_channel_poll_progress: ScopedFeatureDefinition = ScopedFeatureDefinition.from(
	"channel.poll.progress",
	"Channel Poll Progress",
	"https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/#channelpollprogress",
	"Users respond to a poll on a specified channel.",
	[
		"channel:read:polls",
		"channel:manage:polls"
	]
);

static var feature_channel_poll_end: ScopedFeatureDefinition = ScopedFeatureDefinition.from(
	"channel.poll.end",
	"Channel Poll End",
	"https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/#channelpollend",
	"A poll ended on a specified channel.",
	[
		"channel:read:polls",
		"channel:manage:polls"
	]
);

static var feature_channel_prediction_begin: ScopedFeatureDefinition = ScopedFeatureDefinition.from(
	"channel.prediction.begin",
	"Channel Prediction Begin",
	"https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/#channelpredictionbegin",
	"A Prediction started on a specified channel.",
	[
		"channel:read:predictions",
		"channel:manage:predictions"
	]
);

static var feature_channel_prediction_progress: ScopedFeatureDefinition = ScopedFeatureDefinition.from(
	"channel.prediction.progress",
	"Channel Prediction Progress",
	"https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/#channelpredictionprogress",
	"Users participated in a Prediction on a specified channel.",
	[
		"channel:read:predictions",
		"channel:manage:predictions"
	]
);

static var feature_channel_prediction_lock: ScopedFeatureDefinition = ScopedFeatureDefinition.from(
	"channel.prediction.lock",
	"Channel Prediction Lock",
	"https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/#channelpredictionlock",
	"A Prediction was locked on a specified channel.",
	[
		"channel:read:predictions",
		"channel:manage:predictions"
	]
);

static var feature_channel_prediction_end: ScopedFeatureDefinition = ScopedFeatureDefinition.from(
	"channel.prediction.end",
	"Channel Prediction End",
	"https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/#channelpredictionend",
	"A Prediction ended on a specified channel.",
	[
		"channel:read:predictions",
		"channel:manage:predictions"
	]
);

static var feature_channel_suspicious_user_message: ScopedFeatureDefinition = ScopedFeatureDefinition.from(
	"channel.suspicious_user.message",
	"Channel Suspicious User Message",
	"https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/#channelsuspicious_usermessage",
	"A chat message has been sent by a suspicious user.",
	[
		"moderator:read:suspicious_users"
	]
);

static var feature_channel_suspicious_user_update: ScopedFeatureDefinition = ScopedFeatureDefinition.from(
	"channel.suspicious_user.update",
	"Channel Suspicious User Update",
	"https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/#channelsuspicious_userupdate",
	"A suspicious user has been updated.",
	[
		"moderator:read:suspicious_users"
	]
);

static var feature_channel_vip_add: ScopedFeatureDefinition = ScopedFeatureDefinition.from(
	"channel.vip.add",
	"Channel VIP Add",
	"https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/#channelvipadd",
	"A VIP is added to the channel.",
	[
		"channel:read:vips",
		"channel:manage:vips"
	]
);

static var feature_channel_vip_remove: ScopedFeatureDefinition = ScopedFeatureDefinition.from(
	"channel.vip.remove",
	"Channel VIP Remove",
	"https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/#channelvipremove",
	"A VIP is removed from the channel.",
	[
		"channel:read:vips",
		"channel:manage:vips"
	]
);

static var feature_channel_warning_acknowledgement: ScopedFeatureDefinition = ScopedFeatureDefinition.from(
	"channel.warning.acknowledge",
	"Channel Warning Acknowledgement",
	"https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/#channelwarningacknowledge",
	"A user awknowledges a warning. Broadcasters and moderators can see the warning’s details.",
	[
		"moderator:read:warnings",
		"moderator:manage:warnings"
	]
);

static var feature_channel_warning_send: ScopedFeatureDefinition = ScopedFeatureDefinition.from(
	"channel.warning.send",
	"Channel Warning Send",
	"https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/#channelwarningsend",
	"A user is sent a warning. Broadcasters and moderators can see the warning’s details.",
	[
		"moderator:read:warnings",
		"moderator:manage:warnings"
	]
);

static var feature_charity_donation: ScopedFeatureDefinition = ScopedFeatureDefinition.from(
	"channel.charity_campaign.donate",
	"Charity Donation",
	"https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/#channelcharity_campaigndonate",
	"Sends an event notification when a user donates to the broadcaster’s charity campaign.",
	[
		"channel:read:charity"
	]
);

static var feature_charity_campaign_start: ScopedFeatureDefinition = ScopedFeatureDefinition.from(
	"channel.charity_campaign.start",
	"Charity Campaign Start",
	"https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/#channelcharity_campaignstart",
	"Sends an event notification when the broadcaster starts a charity campaign.",
	[
		"channel:read:charity"
	]
);

static var feature_charity_campaign_progress: ScopedFeatureDefinition = ScopedFeatureDefinition.from(
	"channel.charity_campaign.progress",
	"Charity Campaign Progress",
	"https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/#channelcharity_campaignprogress",
	"Sends an event notification when progress is made towards the campaign’s goal or when the broadcaster changes the fundraising goal.",
	[
		"channel:read:charity"
	]
);

static var feature_charity_campaign_stop: ScopedFeatureDefinition = ScopedFeatureDefinition.from(
	"channel.charity_campaign.stop",
	"Charity Campaign Stop",
	"https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/#channelcharity_campaignstop",
	"Sends an event notification when the broadcaster stops a charity campaign.",
	[
		"channel:read:charity"
	]
);

static var feature_goal_begin: ScopedFeatureDefinition = ScopedFeatureDefinition.from(
	"channel.goal.begin",
	"Goal Begin",
	"https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/#channelgoalbegin",
	"Get notified when a broadcaster begins a goal.",
	[
		"channel:read:goals"
	]
);

static var feature_goal_progress: ScopedFeatureDefinition = ScopedFeatureDefinition.from(
	"channel.goal.progress",
	"Goal Progress",
	"https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/#channelgoalprogress",
	"Get notified when progress (either positive or negative) is made towards a broadcaster’s goal.",
	[
		"channel:read:goals"
	]
);

static var feature_goal_end: ScopedFeatureDefinition = ScopedFeatureDefinition.from(
	"channel.goal.end",
	"Goal End",
	"https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/#channelgoalend",
	"Get notified when a broadcaster ends a goal.",
	[
		"channel:read:goals"
	]
);

static var feature_hype_train_begin: ScopedFeatureDefinition = ScopedFeatureDefinition.from(
	"channel.hype_train.begin",
	"Hype Train Begin",
	"https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/#channelhype_trainbegin",
	"A Hype Train begins on the specified channel.",
	[
		"channel:read:hype_train"
	]
);

static var feature_hype_train_progress: ScopedFeatureDefinition = ScopedFeatureDefinition.from(
	"channel.hype_train.progress",
	"Hype Train Progress",
	"https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/#channelhype_trainprogress",
	"A Hype Train makes progress on the specified channel.",
	[
		"channel:read:hype_train"
	]
);

static var feature_hype_train_end: ScopedFeatureDefinition = ScopedFeatureDefinition.from(
	"channel.hype_train.end",
	"Hype Train End",
	"https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/#channelhype_trainend",
	"A Hype Train ends on the specified channel.",
	[
		"channel:read:hype_train"
	]
);

static var feature_shield_mode_begin: ScopedFeatureDefinition = ScopedFeatureDefinition.from(
	"channel.shield_mode.begin",
	"Shield Mode Begin",
	"https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/#channelshield_modebegin",
	"Sends a notification when the broadcaster activates Shield Mode.",
	[
		"moderator:read:shield_mode",
		"moderator:manage:shield_mode"
	]
);

static var feature_shield_mode_end: ScopedFeatureDefinition = ScopedFeatureDefinition.from(
	"channel.shield_mode.end",
	"Shield Mode End",
	"https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/#channelshield_modeend",
	"Sends a notification when the broadcaster deactivates Shield Mode.",
	[
		"moderator:read:shield_mode",
		"moderator:manage:shield_mode"
	]
);

static var feature_shoutout_create: ScopedFeatureDefinition = ScopedFeatureDefinition.from(
	"channel.shoutout.create",
	"Shoutout Create",
	"https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/#channelshoutoutcreate",
	"Sends a notification when the specified broadcaster sends a Shoutout.",
	[
		"moderator:read:shoutouts",
		"moderator:manage:shoutouts"
	]
);

static var feature_shoutout_received: ScopedFeatureDefinition = ScopedFeatureDefinition.from(
	"channel.shoutout.receive",
	"Shoutout Received",
	"https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/#channelshoutoutreceive",
	"Sends a notification when the specified broadcaster receives a Shoutout.",
	[
		"moderator:read:shoutouts",
		"moderator:manage:shoutouts"
	]
);

static var feature_category_channel: ScopedFeatureDefinitionCategory = ScopedFeatureDefinitionCategory.from(
	"Channel",
	[
		feature_channel_update,
		feature_channel_follow,
		feature_channel_ad_break_begin,
		feature_channel_chat_clear,
		feature_channel_chat_clear_user_messages,
		feature_channel_chat_message,
		feature_channel_chat_message_delete,
		feature_channel_chat_notification,
		feature_channel_chat_settings_update,
		feature_channel_chat_user_message_hold,
		feature_channel_chat_user_message_update,
		feature_channel_shared_chat_session_begin,
		feature_channel_shared_chat_session_update,
		feature_channel_shared_chat_session_end,
		feature_channel_subscribe,
		feature_channel_subscription_end,
		feature_channel_subscription_gift,
		feature_channel_subscription_message,
		feature_channel_cheer,
		feature_channel_raid,
		feature_channel_ban,
		feature_channel_unban,
		feature_channel_unban_request_create,
		feature_channel_unban_request_resolve,
		feature_channel_moderate,
		feature_channel_moderate_v2,
		feature_channel_moderator_add,
		feature_channel_moderator_remove,
		feature_channel_guest_star_session_begin,
		feature_channel_guest_star_session_end,
		feature_channel_guest_star_guest_update,
		feature_channel_guest_star_settings_update,
		feature_channel_points_automatic_reward_redemption,
		feature_channel_points_custom_reward_add,
		feature_channel_points_custom_reward_update,
		feature_channel_points_custom_reward_remove,
		feature_channel_points_custom_reward_redemption_add,
		feature_channel_points_custom_reward_redemption_update,
		feature_channel_poll_begin,
		feature_channel_poll_progress,
		feature_channel_poll_end,
		feature_channel_prediction_begin,
		feature_channel_prediction_progress,
		feature_channel_prediction_lock,
		feature_channel_prediction_end,
		feature_channel_suspicious_user_message,
		feature_channel_suspicious_user_update,
		feature_channel_vip_add,
		feature_channel_vip_remove,
		feature_channel_warning_acknowledgement,
		feature_channel_warning_send,
		feature_charity_donation,
		feature_charity_campaign_start,
		feature_charity_campaign_progress,
		feature_charity_campaign_stop,
		feature_goal_begin,
		feature_goal_progress,
		feature_goal_end,
		feature_hype_train_begin,
		feature_hype_train_progress,
		feature_hype_train_end,
		feature_shield_mode_begin,
		feature_shield_mode_end,
		feature_shoutout_create,
		feature_shoutout_received
	]
);

#endregion Feature Category EventSub Features

#region Feature Category EventSub Features

static var feature_conduit_shard_disabled: ScopedFeatureDefinition = ScopedFeatureDefinition.from(
	"conduit.shard.disabled",
	"Conduit Shard Disabled",
	"https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/#conduitsharddisabled",
	"Sends a notification when EventSub disables a shard due to the status of the underlying transport changing.",
	[

	]
);

static var feature_category_conduit: ScopedFeatureDefinitionCategory = ScopedFeatureDefinitionCategory.from(
	"Conduit",
	[
		feature_conduit_shard_disabled
	]
);

#endregion Feature Category EventSub Features

#region Feature Category EventSub Features

static var feature_drop_entitlement_grant: ScopedFeatureDefinition = ScopedFeatureDefinition.from(
	"drop.entitlement.grant",
	"Drop Entitlement Grant",
	"https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/#dropentitlementgrant",
	"An entitlement for a Drop is granted to a user.",
	[

	]
);

static var feature_category_drop: ScopedFeatureDefinitionCategory = ScopedFeatureDefinitionCategory.from(
	"Drop",
	[
		feature_drop_entitlement_grant
	]
);

#endregion Feature Category EventSub Features

#region Feature Category EventSub Features

static var feature_extension_bits_transaction_create: ScopedFeatureDefinition = ScopedFeatureDefinition.from(
	"extension.bits_transaction.create",
	"Extension Bits Transaction Create",
	"https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/#extensionbits_transactioncreate",
	"A Bits transaction occurred for a specified Twitch Extension.",
	[

	]
);

static var feature_category_extension: ScopedFeatureDefinitionCategory = ScopedFeatureDefinitionCategory.from(
	"Extension",
	[
		feature_extension_bits_transaction_create
	]
);

#endregion Feature Category EventSub Features

#region Feature Category EventSub Features

static var feature_stream_online: ScopedFeatureDefinition = ScopedFeatureDefinition.from(
	"stream.online",
	"Stream Online",
	"https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/#streamonline",
	"The specified broadcaster starts a stream.",
	[

	]
);

static var feature_stream_offline: ScopedFeatureDefinition = ScopedFeatureDefinition.from(
	"stream.offline",
	"Stream Offline",
	"https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/#streamoffline",
	"The specified broadcaster stops a stream.",
	[

	]
);

static var feature_category_stream: ScopedFeatureDefinitionCategory = ScopedFeatureDefinitionCategory.from(
	"Stream",
	[
		feature_stream_online,
		feature_stream_offline
	]
);

#endregion Feature Category EventSub Features

#region Feature Category EventSub Features

static var feature_user_authorization_grant: ScopedFeatureDefinition = ScopedFeatureDefinition.from(
	"user.authorization.grant",
	"User Authorization Grant",
	"https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/#userauthorizationgrant",
	"A user’s authorization has been granted to your client id.",
	[

	]
);

static var feature_user_authorization_revoke: ScopedFeatureDefinition = ScopedFeatureDefinition.from(
	"user.authorization.revoke",
	"User Authorization Revoke",
	"https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/#userauthorizationrevoke",
	"A user’s authorization has been revoked for your client id.",
	[

	]
);

static var feature_user_update: ScopedFeatureDefinition = ScopedFeatureDefinition.from(
	"user.update",
	"User Update",
	"https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/#userupdate",
	"A user has updated their account.",
	[
		"user:read:email"
	]
);

static var feature_whisper_received: ScopedFeatureDefinition = ScopedFeatureDefinition.from(
	"user.whisper.message",
	"Whisper Received",
	"https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/#userwhispermessage",
	"A user receives a whisper.",
	[
		"user:read:whispers",
		"user:manage:whispers"
	]
);

static var feature_category_user: ScopedFeatureDefinitionCategory = ScopedFeatureDefinitionCategory.from(
	"User",
	[
		feature_user_authorization_grant,
		feature_user_authorization_revoke,
		feature_user_update,
		feature_whisper_received
	]
);

#endregion Feature Category EventSub Features

static var feature_set_eventsub: ScopedFeatureSet = ScopedFeatureSet.from(
	"eventsub",
	"EventSub Features",
	[
		feature_category_automod,
		feature_category_channel,
		feature_category_conduit,
		feature_category_drop,
		feature_category_extension,
		feature_category_stream,
		feature_category_user
	]
);

#endregion Feature Set EventSub Features
